Class {
	#name : 'GeminiApiWithTools',
	#superclass : 'GeminiApi',
	#category : 'AIActions-AIApiTools',
	#package : 'AIActions',
	#tag : 'AIApiTools'
}

{ #category : 'trait tools support' }
GeminiApiWithTools >> executeToolNamed: name withArgs: args [
    AilienApiTool subclasses do: [ :tool | 
        | instance |
        instance := tool new.
        instance name = name ifTrue: [
            ^ instance executeTool: args ] ].
    
    "Returnér en Dictionary for at overholde Geminis forventning om JSON-respons"
    ^ Dictionary newFrom: { 
        'error' -> ('Unknown tool: ' , name).
        'status' -> 'failed' }
]

{ #category : 'ollama models' }
GeminiApiWithTools >> jsonHistory [
    ^ messageList collect: [ :item |
        item value isDictionary 
            ifTrue: [ item value ] "Allerede formateret af processToolCall:"
            ifFalse: [ 
                | correctedRole |
                correctedRole := item key = 'assistant' ifTrue: [ 'model' ] ifFalse: [ item key ].
                Dictionary newFrom: {
                    'role' -> correctedRole.
                    'parts' -> { Dictionary newFrom: { 'text' -> item value } }
                } ] ]
]

{ #category : 'responses' }
GeminiApiWithTools >> loadResponse: aHistory [
    | maxTurns |
    maxTurns := 50.
    1 to: maxTurns do: [ :turn |
        | jsonPrompt rawResponse parsed candidates content toolCalls |
        Transcript << '## ' << self class name asString << ': ' << turn asString << String lf.
        jsonPrompt := ZnClient new.
        self znClientBasic: jsonPrompt.
        self class znClientHeaders: jsonPrompt.
        rawResponse := jsonPrompt post; contents.
        parsed := STONJSON fromString: rawResponse.
        (parsed includesKey: 'error') ifTrue: [ ^ self responseError: parsed hist: aHistory ].
        
        candidates := parsed at: 'candidates'.
        content := candidates first at: 'content'.
        "Gemini returnerer tool_calls i 'parts' arrayet"
        toolCalls := (content at: 'parts') select: [ :part | part includesKey: 'functionCall' ].

        toolCalls isEmpty ifTrue: [ 
				| textPart |
    			textPart := (content at: 'parts') detect: [ :p | p includesKey: 'text' ] ifNone: [ nil ].
    			textPart ifNotNil: [ 
        			aHistory assistant: (textPart at: 'text') from: self.
        			^ self ].
    		"Håndter tomme svar her"
		  ].

        "Gemini kræver at vi gemmer modellens functionCall i historikken før vi svarer"
        self messageList add: 'assistant' -> content.

        "Processér alle kald og tilføj dem som functionResponse"
        toolCalls do: [ :call | 
            self messageList add: (self processToolCall: (call at: 'functionCall')) ] ].
    ^ aHistory assistant: ('API Error: exceed {1} tool turns' format: { maxTurns })
]

{ #category : 'trait tools support' }
GeminiApiWithTools >> processToolCall: functionCall [
    | result name |
    name := functionCall at: 'name'.
    result := self 
        executeToolNamed: name
        withArgs: (functionCall at: 'args' ifAbsent: [ Dictionary new ]).
    
    "Gemini kræver rollen 'function' og en specifik 'functionResponse' nøgle"
    ^ 'function' -> (Dictionary newFrom: {
        'role' -> 'function'.
        'parts' -> { 
            Dictionary newFrom: {
                'functionResponse' -> (Dictionary newFrom: {
                    'name' -> name.
                    'response' -> (Dictionary newFrom: { 'content' -> result })
                })
            }
        }
    })
]

{ #category : 'trait tools support' }
GeminiApiWithTools >> responseError: parsed hist: aHistory [
    | error message code |
    error := parsed at: 'error'.
    message := error at: 'message' ifAbsent: [ 'Unknown API error' ].
    code := error at: 'code' ifAbsent: [ 'No code provided' ].
    
    "Hvis fejlen indeholder status (f.eks. INVALID_ARGUMENT), inkluderer vi den"
    (error includesKey: 'status') ifTrue: [ 
        message := (error at: 'status') , ': ' , message ].

    aHistory assistant: ('Gemini API Error {1}: {2}' format: { code. message }) from: self.
    ^ self
]

{ #category : 'trait tools support' }
GeminiApiWithTools >> toolSpecification [
    ^ AilienApiTool subclasses collect: [ :tool |
        | spec func params required |
        spec := tool new evaluateTool.
        func := spec at: 'function'.
        params := func at: 'parameters'.
        required := (params at: 'required') asArray.
        Dictionary newFrom: {
            'name' -> (func at: 'name').
            'description' -> (func at: 'description').
            'parameters' -> (Dictionary newFrom: {
                'type' -> (params at: 'type').
                'properties' -> (params at: 'properties').
                'required' -> required }) } ]
]

{ #category : 'ollama models' }
GeminiApiWithTools >> znClientEntity [
    | entity |
    "Vi bygger en ny dictionary baseret på værdierne fra super"
    entity := Dictionary newFrom: {
        'model' -> model.
        'contents' -> self jsonHistory.
        'generationConfig' -> (Dictionary newFrom: { 'temperature' -> 0 }).
        'tools' -> { Dictionary newFrom: { 'function_declarations' -> self toolSpecification } }
    }.
    ^ entity
]
