Class {
	#name : 'ClaudeApiWithTools',
	#superclass : 'ClaudeApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

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
ClaudeApiWithTools >> loadResponse: aHistory [ 
    | maxTurns |
    maxTurns := 50.
    1 to: maxTurns do: [ :turn |
        | jsonPrompt rawResponse parsed contentBlocks toolCalls |
        Transcript << '## ' << self class name asString << ': ' << turn asString << String lf.
        jsonPrompt := ZnClient new.
        self znClientBasic: jsonPrompt.
        self class znClientHeaders: jsonPrompt.
        rawResponse := jsonPrompt post; contents.
        parsed := STONJSON fromString: rawResponse.
        (parsed includesKey: 'error') ifTrue: [ ^ self responseError: parsed hist: aHistory ].
        contentBlocks := parsed at: 'content'.
        toolCalls := contentBlocks select: [ :block | (block at: 'type') = 'tool_use' ].
        toolCalls isEmpty ifTrue: [
            aHistory assistant: ((contentBlocks detect: [ :b | (b at: 'type') = 'text' ]) at: 'text') from: self.
            ^ self ].
        self messageList add: 'assistant' -> parsed.
        toolCalls do: [ :call | self messageList add: (self processToolCall: call) ] ].
    ^ aHistory assistant: ('API Error: tried more than the {1} allowed TOOLS calls' format: { maxTurns })
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
    aHistory assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message') from: self.
    ^ self
]
