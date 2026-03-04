Class {
	#name : 'GeminiApiWithTools',
	#superclass : 'GeminiApi',
	#category : 'AIActions-AIApiTools',
	#package : 'AIActions',
	#tag : 'AIApiTools'
}

{ #category : 'ollama models' }
GeminiApiWithTools >> aaa_znClientEntity [
    | entity |
    entity := super znClientEntity.
    entity add: 'tools' -> { self toolSpecification }.
    ^ entity
]

{ #category : 'trait tools support' }
GeminiApiWithTools >> executeToolNamed: aName withArgs: args [
    AilienApiTool subclasses do: [ :toolClass |
        | instance |
        instance := toolClass new.
        instance name = aName ifTrue: [ ^ instance executeTool: args ] ].
    ^ 'Unknown tool: ', aName
]

{ #category : 'accessing' }
GeminiApiWithTools >> jsonHistory [
    "Gemini kræver en flad liste af contents. Tool-interaktioner skal gemmes som 
    henholdsvis 'model' (med functionCall) og 'functionResponse'."
    | jsonHistory correctedRole |
    correctedRole := { 'user'->'user'. 'assistant'->'model' } asDictionary.
    jsonHistory := OrderedCollection new.
    messageList do: [ :item |
        item value isDictionary
            ifTrue: [ jsonHistory add: item value ]
            ifFalse: [
                jsonHistory add: (Dictionary newFrom: {
                    'role' -> (correctedRole at: item key).
                    'parts' -> { { 'text' -> item value } asDictionary } }) ] ].
    ^ jsonHistory asArray


]

{ #category : 'responses' }
GeminiApiWithTools >> loadResponse: aHistory [
    | maxTurns |
    maxTurns := 20.
    1 to: maxTurns do: [ :turn |
        | jsonPrompt rawResponse parsed candidate content parts toolCalls |
        jsonPrompt := ZnClient new.
        self znClientBasic: jsonPrompt.
        self class znClientHeaders: jsonPrompt.
        rawResponse := jsonPrompt post; contents.
        parsed := STONJSON fromString: rawResponse.
        
        candidate := (parsed at: 'candidates') first.
        content := candidate at: 'content'.
        parts := content at: 'parts'.
        
        "Tjek for tool calls"
        toolCalls := parts select: [ :p | p includesKey: 'functionCall' ].
        
        toolCalls isEmpty ifTrue: [
            | text |
            text := (parts detect: [ :p | p includesKey: 'text' ]) at: 'text'.
            aHistory assistant: text.
            ^ self ].

        "Gem modellens tool call i historikken"
        self messageList add: 'assistant' -> content.
        
        "Udfør værktøjer og tilføj svar som 'functionResponse' parts"
        toolCalls do: [ :call |
            | callData result |
            callData := call at: 'functionCall'.
            result := self executeToolNamed: (callData at: 'name') 
                           withArgs: (callData at: 'args').
            
            self messageList add: 'user' -> (Dictionary newFrom: {
                'role' -> 'user'.
                'parts' -> { { 'functionResponse' -> (Dictionary newFrom: {
                    'name' -> (callData at: 'name').
                    'response' -> (Dictionary newFrom: { 'content' -> result })
                }) } asDictionary }
            }) ].
    ].
    aHistory assistant: 'Fejl: For mange tool-vendinger.'
]

{ #category : 'trait tools support' }
GeminiApiWithTools >> toolSpecification [
    ^ { 'function_declarations' -> (AilienApiTool subclasses collect: [ :toolClass |
        | toolInstance dict func |
        toolInstance := toolClass new.
        dict := toolInstance evaluateTool.
        func := dict at: 'function'.
        Dictionary newFrom: {
            'name' -> (func at: 'name').
            'description' -> (func at: 'description').
            'parameters' -> (func at: 'parameters') } ]) } asDictionary


]

{ #category : 'ollama models' }
GeminiApiWithTools >> znClientEntity [
	| base |
	base := super znClientEntity.
	^ base union: { 
		'tools' -> { self toolSpecification }.
		'tool_config' -> (Dictionary newFrom: {
			'function_calling_config' -> (Dictionary newFrom: {
				'mode' -> 'AUTO'
			})
		})
	} asDictionary
]
