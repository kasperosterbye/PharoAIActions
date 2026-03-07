Class {
	#name : 'ClaudeApiWithTools',
	#superclass : 'Claude0Api',
	#category : 'AIActions-AIApiTools',
	#package : 'AIActions',
	#tag : 'AIApiTools'
}

{ #category : 'responses' }
ClaudeApiWithTools >> callLLM [
	| jsonPrompt rawResponse parsed |
	jsonPrompt := ZnClient new.
	self znClientBasic: jsonPrompt.
	self class znClientHeaders: jsonPrompt.
	rawResponse := jsonPrompt
		               post;
		               contents.
	parsed := STONJSON fromString: rawResponse.
	^ parsed
]

{ #category : 'trait tools support' }
ClaudeApiWithTools >> continueToolCall: parsed orWrite: aHistory [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
	(parsed includesKey: 'error') ifTrue: [ 
		self responseError: parsed hist: aHistory.
		^ nil ].
	message := parsed at: 'content'.
	content := message select: [ :block | (block at: 'type') = 'tool_use' ].
	content isEmpty ifTrue: [
			aHistory assistant: ((message detect: [ :b | (b at: 'type') = 'text' ]) at: 'text'). " from: self"
			^ nil ].
	^ message 
]

{ #category : 'trait tools support' }
ClaudeApiWithTools >> executeToolNamed: name withArgs: args [
    AilienApiTool subclasses do: [ :tool | 
        | instance |
        instance := tool new.
        instance name = name ifTrue: [
            ^ instance executeTool: args
        ] ].
    ^ 'Unknown tool: ', name
]

{ #category : 'responses' }
ClaudeApiWithTools >> handleToolCall: toolCall [
	(toolCall at: 'tool_calls') do: [ :call | self messageList add: (self processToolCall: call) ]
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
ClaudeApiWithTools >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item |
        item value isDictionary
            ifTrue: [ jsonHistory add: item value ]
            ifFalse: [
                jsonHistory add: (Dictionary newFrom: {
                    'role' -> item key.
                    'content' -> item value }) ] ].
    ^ jsonHistory asArray
]

{ #category : 'responses' }
ClaudeApiWithTools >> lll_loadResponse: aHistory [ 
    | maxTurns |
    maxTurns := 50.
    1 to: maxTurns do: [ :turn |
        | jsonPrompt rawResponse parsed contentBlocks toolCalls |
        jsonPrompt := ZnClient new.
        self znClientBasic: jsonPrompt.
        self class znClientHeaders: jsonPrompt.
        rawResponse := jsonPrompt post; contents.
        parsed := STONJSON fromString: rawResponse.
        (parsed includesKey: 'error') ifTrue: [ ^ self responseError: parsed hist: aHistory ].
        contentBlocks := parsed at: 'content'.
        toolCalls := contentBlocks select: [ :block | (block at: 'type') = 'tool_use' ].
        toolCalls isEmpty ifTrue: [
            aHistory assistant: ((contentBlocks detect: [ :b | (b at: 'type') = 'text' ]) at: 'text')" from: self".
            ^ self ].
        Transcript << '## ' << self class name asString << ': ' << turn asString << String lf.
        
		  self messageList add: 'assistant' -> (Dictionary newFrom: {
			    'role' -> 'assistant'.
    			'content' -> (parsed at: 'content') }).
        toolCalls do: [ :call | self messageList add: (self processToolCall: call) ] ].
    ^ aHistory assistant: ('API Error: tried more than the {1} allowed TOOLS calls' format: { maxTurns })
]

{ #category : 'responses' }
ClaudeApiWithTools >> loadResponse: aHistory [

	self traitLoadResponse: aHistory  
]

{ #category : 'as yet unclassified' }
ClaudeApiWithTools >> messageListAddResponse: response andTool: toolCall [

	self messageList add: 'assistant' -> (Dictionary newFrom: {
				 ('role' -> 'assistant').
				 ('content' -> (response at: 'content')) })
]

{ #category : 'trait tools support' }
ClaudeApiWithTools >> processToolCall: call [
    | result |
    result := self 
        executeToolNamed: (call at: 'name')
        withArgs: (call at: 'input').
    ^ 'user' -> (Dictionary newFrom: {
        'role' -> 'user'.
        'content' -> { Dictionary newFrom: {
            'type' -> 'tool_result'.
            'tool_use_id' -> (call at: 'id').
            'content' -> result } } })
]

{ #category : 'trait tools support' }
ClaudeApiWithTools >> responseError: parsed hist: aHistory [
    | error |
    error := parsed at: 'error'.
    aHistory assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message')" from: self".
    ^ self
]

{ #category : 'trait tools support' }
ClaudeApiWithTools >> toolSpecification [
    ^ AilienApiTool subclasses collect: [ :tool |
        | openAI func params |
        openAI := tool new evaluateTool.
        func := openAI at: 'function'.
        params := func at: 'parameters'.
        Dictionary newFrom: {
            'name' -> (func at: 'name').
            'description' -> (func at: 'description').
            'input_schema' -> params } ]
]

{ #category : 'responses' }
ClaudeApiWithTools >> traitLoadResponse: aHistory [
	| maxTurns |
	maxTurns := 50.
	1 to: maxTurns do: [ :turn |
			| response toolCall |
			response := self callLLM .
			toolCall := self continueToolCall: response orWrite: aHistory. 
			toolCall ifNil: [ ^ self ].
			Transcript << '## ' << self class name asString << ': ' << turn asString << String lf.
			self messageListAddResponse: response andTool: toolCall. 
			self handleToolCall: toolCall.
			].
	^ aHistory assistant: ('API Error: tried more than the {1} allowed TOOLS calls' format: { maxTurns })
]

{ #category : 'accessing' }
ClaudeApiWithTools >> znClientEntity [
    ^ super znClientEntity , {
        'tools' -> self toolSpecification.
    }
]
