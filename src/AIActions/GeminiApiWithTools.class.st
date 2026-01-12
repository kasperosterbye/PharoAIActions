Class {
	#name : 'GeminiApiWithTools',
	#superclass : 'GeminiApi',
	#instVars : [
		'toolExecutor'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'ollama models' }
GeminiApiWithTools >> bodyForEntityWithPrompt [
    | requestDictionary |
self halt.
    requestDictionary := super bodyForEntityWithPrompt.
    requestDictionary at: 'tools' put: self toolSpecification.
    ^ requestDictionary
]

{ #category : 'as yet unclassified' }
GeminiApiWithTools >> executeGetClassMarkdown: aClassName [
    | targetClass |
    targetClass := Smalltalk globals at: aClassName asSymbol ifAbsent: [ nil ].
    ^ targetClass
        ifNil: [ 'Error: Class named ' , aClassName , ' not found.' ]
        ifNotNil: [ self generateMarkdownFor: targetClass ].

]

{ #category : 'ollama models' }
GeminiApiWithTools >> extractFunctionCallFrom: parsedResponse [
    ^ parsedResponse at: 'candidates' ifPresent: [ :candidates |
        candidates ifNotEmpty: [
            (candidates first at: 'content' ifPresent: [ :content |
                (content at: 'parts' ifPresent: [ :parts |
                    parts ifNotEmpty: [
                        parts first at: 'functionCall' ifAbsent: [ nil ] ]
                ])
            ])
        ]
    ] ifAbsent: [ nil ]
]

{ #category : 'ollama models' }
GeminiApiWithTools >> extractTextFrom: parsedResponse [
self halt.
    ^ parsedResponse at: 'candidates' ifPresent: [ :candidates |
        candidates ifNotEmpty: [
            (candidates first at: 'content' ifPresent: [ :content |
                (content at: 'parts' ifPresent: [ :parts |
                    parts ifNotEmpty: [
                        parts first at: 'text' ifAbsent: [ 'Error: No text.' ] ]
                ])
            ])
        ]
    ] ifAbsent: [ 'Error: No candidates.' ]
]

{ #category : 'as yet unclassified' }
GeminiApiWithTools >> generateMarkdownFor: aClass [
    "Placeholder for your comprehensive markdown generation logic."
    ^ '## Class: ' , aClass name asString, String cr,
      '### Instance variables: ', (aClass instVarNames joinUsing: ' '), String cr,
      '### Class comment:', String cr, aClass comment.
]

{ #category : 'ollama models' }
GeminiApiWithTools >> handleFunctionCall: functionCall inHistory: aHistory [
    | functionName args result |
    functionName := functionCall at: 'name'.
    args := functionCall at: 'args'.
    "Log the model's request to call a function"
    aHistory messages add: 'assistant' -> functionCall.

    result := self executeGetClassMarkdown: (args at: 'className').

    "Add tool result back to history with the 'function' role"
    aHistory messages add: 'function' -> (Dictionary newFrom: {
        'functionResponse' -> (Dictionary newFrom: {
            'name' -> functionName.
            'response' -> (Dictionary newFrom: { 'content' -> result })
        })
    }).
]

{ #category : 'ollama models' }
GeminiApiWithTools >> jsonHistory [
    | jsonHistory correctedRole |
    correctedRole := { 'user'->'user'. 'assistant'->'model'. 'function'->'function' } asDictionary.
    jsonHistory := OrderedCollection new.
    messageList do: [ :item |
        | role content |
        role := correctedRole at: item key.
        content := item value.
        jsonHistory add: (role = 'function'
            ifTrue: [ Dictionary newFrom: {
                'role' -> role.
                'parts' -> { content } } ]
            ifFalse: [ Dictionary newFrom: {
                'role' -> role.
                'parts' -> { Dictionary newFrom: { 'text' -> content } } } ])
    ].
    ^ jsonHistory asArray
]

{ #category : 'ollama models' }
GeminiApiWithTools >> loadResponse: aHistory [
    | maxTurns |
    maxTurns := 5. "Safety break to prevent infinite loops"
    1 to: maxTurns do: [ :turn |
        | rawResponse parsedResponse functionCall |
        [
            rawResponse := ZnClient new
                timeout: self responseWaitingInSecs;
                url: self apiGenerateUrl;
                entity: self bodyForEntityWithPrompt;
                headers: [ :req | self headers: req ].
				rawResponse := rawResponse 
                post; contents.

            parsedResponse := STONJSON fromString: rawResponse.
            functionCall := self extractFunctionCallFrom: parsedResponse.

            functionCall
                ifNil: [ "Final text response from model"
                    | responseText |
                    responseText := self extractTextFrom: parsedResponse.
                    aHistory assistant: responseText.
                    ^ self ]
                ifNotNil: [ "Model requested a tool call"
                    self
                        handleFunctionCall: functionCall
                        inHistory: aHistory ]
        ] on: Error do: [ :ex |
            aHistory assistant: 'GeminiApiWothTools API Error: ', ex messageText.
            ^ self ]
    ].
    aHistory assistant: 'Error: Tool execution loop timed out.'.
]

{ #category : 'as yet unclassified' }
GeminiApiWithTools >> toolSpecification [
    ^ {
        Dictionary newFrom: {
            'functionDeclarations' -> {
                Dictionary newFrom: {
                    'name' -> 'getClassMarkdown'.
                    'description' -> 'Retrieves the markdown documentation for a given Pharo class.'.
                    'parameters' -> (Dictionary newFrom: {
                        'type' -> 'OBJECT'.
                        'properties' -> (Dictionary newFrom: {
                            'className' -> (Dictionary newFrom: { 'type' -> 'STRING' })
                        }).
                        'required' -> #('className')
                    })
                }
            }
        }
    } asArray
]
