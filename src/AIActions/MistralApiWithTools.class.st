Class {
	#name : 'MistralApiWithTools',
	#superclass : 'MistralApi',
	#instVars : [
		'toolExecutor'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
MistralApiWithTools >> bodyForEntityWithPrompt [
    | requestDictionary |
    requestDictionary := Dictionary newFrom: {
        'model' -> self model.
        'messages' -> self jsonHistory.
        'tools' -> self toolSpecification.
        'temperature' -> 0.0.
        'stream' -> false
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary)
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> browseImplementorsTool [
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> 'browseImplementors'.
            'description' -> 'Returns list of classes implementing a given selector.'.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'selector' -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> 'Method selector to find implementors of'
                    })
                }).
                'required' -> #('selector')
            })
        })
    }
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> evaluateExpressionTool [
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> 'evaluatePharoExpression'.
            'description' -> 'Evaluates Pharo Smalltalk expression. Returns printString of result. Handles arithmetic, object creation, collection operations.'.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'expression' -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> 'Pharo expression to evaluate'
                    })
                }).
                'required' -> #('expression')
            })
        })
    }
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> executeExpression: expr [
    [ ^ (OpalCompiler new evaluate: expr) printString ]
        on: Error
        do: [ :ex | ^ 'Error: ', ex messageText ]

]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> executeGetClassInfo: className [
    | cls |
    cls := Smalltalk globals at: className asSymbol ifAbsent: [ ^ 'Class not found' ].
    ^ String streamContents: [ :s |
        s << '## ' << className << String cr.
        s << 'Slots: ' << (cls instVarNames joinUsing: ' ') << String cr.
        s << 'Comment: ' << (cls comment ifEmpty: [ 'None' ]) ]
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> executeImplementors: selector [
    | implementors |
    implementors := SystemNavigation default allImplementorsOf: selector asSymbol.
    implementors ifEmpty: [ ^ 'No implementors found' ].
    ^ (implementors collect: [ :m | m methodClass name ]) joinUsing: ', '
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> executeToolNamed: name withArgs: args [
    name = 'evaluatePharoExpression' ifTrue: [
        ^ self executeExpression: (args at: 'expression') ].
    name = 'getClassInfo' ifTrue: [
        ^ self executeGetClassInfo: (args at: 'className') ].
    name = 'browseImplementors' ifTrue: [
        ^ self executeImplementors: (args at: 'selector') ].
    ^ 'Unknown tool: ', name
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> getClassInfoTool [
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> 'getClassInfo'.
            'description' -> 'Returns class comment, instance variables, and method selectors for a Pharo class.'.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'className' -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> 'Name of the Pharo class'
                    })
                }).
                'required' -> #('className')
            })
        })
    }
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item |
        item key = 'assistant'
            ifTrue: [ jsonHistory add: item value ]  "Already a dict from API"
            ifFalse: [
                item key = 'tool'
                    ifTrue: [ jsonHistory add: (Dictionary newFrom: {
                        'role' -> 'tool'.
                        'tool_call_id' -> (item value at: 'tool_call_id').
                        'content' -> (item value at: 'content') }) ]
                    ifFalse: [ jsonHistory add: (Dictionary newFrom: {
                        'role' -> item key.
                        'content' -> item value }) ] ] ].
    ^ jsonHistory asArray
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> loadResponse: aHistory [
    | maxTurns |
    maxTurns := 5.
    1 to: maxTurns do: [ :turn |
        | rawResponse parsed message toolCalls |
        rawResponse := ZnClient new
            timeout: self responseWaitingInSecs;
            url: self apiGenerateUrl;
            entity: self bodyForEntityWithPrompt.
        self headers: rawResponse.
        rawResponse := rawResponse post; contents.
        parsed := STONJSON fromString: rawResponse.
		  (parsed includesKey: 'error') ifTrue: [
            | error |
            error := parsed at: 'error'.
            aHistory assistant: ('API Error: ', (error at: 'type'), ' - ', (error at: 'message')).
            ^ self ].

        message := (parsed at: 'choices') first at: 'message'.
        toolCalls := message at: 'tool_calls' ifAbsent: [ nil ].
        
        toolCalls ifNil: [
            aHistory assistant: (message at: 'content').
            ^ self ].
        
        "Add assistant's tool request to history"
        messageList add: 'assistant' -> message.
        
        "Execute each tool and add results"
        toolCalls do: [ :call |
            | funcName funcArgs result |
            funcName := (call at: 'function') at: 'name'.
            funcArgs := STONJSON fromString: ((call at: 'function') at: 'arguments').
            result := self executeToolNamed: funcName withArgs: funcArgs.
            messageList add: 'tool' -> (Dictionary newFrom: {
                'tool_call_id' -> (call at: 'id').
                'content' -> result
            }) ] ]
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> old_loadResponse: aHistory [
    | maxTurns |
    maxTurns := 5.
    1 to: maxTurns do: [ :turn |
        | rawResponse parsed message toolCalls |
        rawResponse := ZnClient new
            timeout: self responseWaitingInSecs;
            url: self apiGenerateUrl;
            entity: self bodyForEntityWithPrompt.
        self headers: rawResponse.
        rawResponse := rawResponse post; contents.
        parsed := STONJSON fromString: rawResponse.
		  (parsed includesKey: 'error') ifTrue: [
            | error |
            error := parsed at: 'error'.
            aHistory assistant: ('API Error: ', (error at: 'type'), ' - ', (error at: 'message')).
            ^ self ].

        message := (parsed at: 'choices') first at: 'message'.
        toolCalls := message at: 'tool_calls' ifAbsent: [ nil ].
        
        toolCalls ifNil: [
            aHistory assistant: (message at: 'content').
            ^ self ].
        
        "Add assistant's tool request to history"
        messageList add: 'assistant' -> message.
        
        "Execute each tool and add results"
        toolCalls do: [ :call |
            | funcName funcArgs result |
            funcName := (call at: 'function') at: 'name'.
            funcArgs := STONJSON fromString: ((call at: 'function') at: 'arguments').
            result := self executeToolNamed: funcName withArgs: funcArgs.
            messageList add: 'tool' -> (Dictionary newFrom: {
                'tool_call_id' -> (call at: 'id').
                'content' -> result
            }) ] ]
]

{ #category : 'printing' }
MistralApiWithTools >> printOn: aStream [
	"Prints the MistralApi instance with its current model name for debugging and logging purposes."
	aStream << 'MistralApiWithTools: ' << self model.
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> toolSpecification [
    ^ {
        self evaluateExpressionTool.
        self getClassInfoTool.
        self browseImplementorsTool
    }
]
