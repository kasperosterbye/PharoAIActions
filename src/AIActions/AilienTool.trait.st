Trait {
	#name : 'AilienTool',
	#category : 'AIActions-AIApiTools',
	#package : 'AIActions',
	#tag : 'AIApiTools'
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
AilienTool >> clientCall [

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
AilienTool >> continueToolCall: parsed orWrite: aHistory [

	| message |
	(parsed includesKey: 'error') ifTrue: [ self responseError: parsed hist: aHistory. ^ nil ].
	message := (parsed at: 'choices') first at: 'message'.
	(message includesKey: 'tool_calls') ifFalse: [
			aHistory assistant: (message at: 'content') from: self.
			^ nil ].
	^ message.
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
self halt. "Cannot be in a Trait"
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
			| parsed message |
			Transcript << '## ' << self class name asString << ': ' << turn asString << String lf.
			parsed := self clientCall.
			(message := self continueToolCall: parsed orWrite: aHistory) ifNil: [ ^ self ].
			self messageList add: 'assistant' -> message. "Execute each tool and add results"
			(message at: 'tool_calls') do: [ :call | 
				self messageList add: (self processToolCall: call) ] ].
	^ aHistory assistant: ('API Error: tried more than the {1} allowed TOOLS calls' format: { maxTurns })
]
