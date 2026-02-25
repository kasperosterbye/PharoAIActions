Trait {
	#name : 'AilienTool',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'adding' }
AilienTool >> addJsonHistory: jsonHistory for: item [

	item key = 'assistant'
		ifTrue: [ "Handle both dict (from tool loop) and string (from aHistory assistant:)"
				item value isDictionary
					ifTrue: [ jsonHistory add: item value ]
					ifFalse: [
							jsonHistory add: (Dictionary newFrom: {
										 ('role' -> 'assistant').
										 ('content' -> item value) }) ] ]
		ifFalse: [
				item key = 'tool'
					ifTrue: [
							jsonHistory add: (Dictionary newFrom: {
										 ('role' -> 'tool').
										 ('tool_call_id' -> (item value at: 'tool_call_id')).
										 ('content' -> (item value at: 'content')) }) ]
					ifFalse: [
							jsonHistory add: (Dictionary newFrom: {
										 ('role' -> item key).
										 ('content' -> item value) }) ] ]
]

{ #category : 'trait tools support' }
AilienTool >> executeToolNamed: name withArgs: args [
	AilienApiTool subclasses do: [ :tool | 
		| instance |
		instance := tool new.
		instance name = name ifTrue:[
			^ instance executeTool: args
			] ].
    ^ 'Unknown tool: ', name
]

{ #category : 'trait tools support' }
AilienTool >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    self messageList do: [ :item | self addJsonHistory: jsonHistory for: item ].
    ^ jsonHistory asArray
]

{ #category : 'trait tools support' }
AilienTool >> processToolCall: call [
	"Processes a single tool call, executes the corresponding tool with its arguments, and returns the result formatted for the conversation history."
    | func result |
    func := call at: 'function'. 
    result := self 
        executeToolNamed: (func at: 'name') 
        withArgs: (STONJSON fromString: (func at: 'arguments')).
    ^ 'tool' -> (Dictionary newFrom: {
        'tool_call_id' -> (call at: 'id').
        'content' -> result })
]

{ #category : 'trait tools support' }
AilienTool >> responseError: parsed hist: aHistory [

	| error |
	error := parsed at: 'error'.
	aHistory assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message') from: self.
	^ self
]

{ #category : 'trait tools support' }
AilienTool >> toolSpecification [
	| all |
	all := AilienApiTool subclasses collect: [ :tool |  tool new evaluateTool ].
   ^ all 
]

{ #category : 'trait tools support' }
AilienTool >> traitLoadResponse: aHistory [

	| maxTurns |
	maxTurns := 50.
	1 to: maxTurns do: [ :turn |
			| jsonPrompt rawResponse parsed message toolCalls |
			jsonPrompt := ZnClient new.
			self znClientBasic: jsonPrompt.
			self class znClientHeaders: jsonPrompt.
			rawResponse := jsonPrompt 
				               post;
				               contents.
			parsed := STONJSON fromString: rawResponse.
			(parsed includesKey: 'error') ifTrue: [ ^ self responseError: parsed hist: aHistory ].

			message := (parsed at: 'choices') first at: 'message'.
			toolCalls := message at: 'tool_calls' ifAbsent: [ nil ].
			toolCalls ifNil: [
					aHistory assistant: (message at: 'content') from: self.
					^ self ]. "Add assistant's tool request to history"
			self messageList add: 'assistant' -> message. "Execute each tool and add results"
			toolCalls do: [ :call | self messageList add: (self processToolCall: call) ] ]
]
