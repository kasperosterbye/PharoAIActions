Class {
	#name : 'AilienApiWithTools',
	#superclass : 'Ailien0Api',
	#category : 'AIAZipArchive-AIApiArhive',
	#package : 'AIAZipArchive',
	#tag : 'AIApiArhive'
}

{ #category : 'adding' }
AilienApiWithTools >> addJsonHistory: jsonHistory for: item [
	"Adds a message to the JSON history based on its role and content"

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

{ #category : 'adding' }
AilienApiWithTools >> callLLM [
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

{ #category : 'adding' }
AilienApiWithTools >> continueToolCall: parsed orWrite: aHistory [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
	(parsed includesKey: 'error') ifTrue: [ 
		self responseError: parsed hist: aHistory. 
		^ nil ].
	message := (parsed at: 'choices') first at: 'message'.
	content := message at: 'content'.
	(content isNotNil and: [ content isNotEmpty  ]) ifTrue: [
			aHistory assistant: content" from: self".
			^ nil ].
	^ message.
]

{ #category : 'adding' }
AilienApiWithTools >> executeToolNamed: name withArgs: args [
	"Executes a tool with the given name and arguments, returning the result"
	AilienApiTool subclasses do: [ :tool | 
		| instance |
		instance := tool new.
		instance name = name ifTrue:[
			^ instance executeTool: args
			] ].
    ^ 'Unknown tool: ', name
]

{ #category : 'adding' }
AilienApiWithTools >> handleToolCall: toolCall [
	(toolCall at: 'tool_calls') do: [ :call | self messageList add: (self processToolCall: call) ]
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
AilienApiWithTools >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item | self addJsonHistory: jsonHistory for: item ].
    ^ jsonHistory asArray
]

{ #category : 'adding' }
AilienApiWithTools >> loadResponse: aHistory [
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

{ #category : 'adding' }
AilienApiWithTools >> messageListAddResponse: response andTool: toolCall [
	self messageList add: 'assistant' -> toolCall. 
]

{ #category : 'adding' }
AilienApiWithTools >> processToolCall: call [
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

{ #category : 'adding' }
AilienApiWithTools >> responseError: parsed hist: aHistory [
	"Handles API error responses by adding the error message to the conversation history"

	| error |
	error := parsed at: 'error'.
	aHistory assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message') "from: self".
	^ self
]

{ #category : 'adding' }
AilienApiWithTools >> toolSpecification [
	"Returns a collection of tool specifications for all registered API tool subclasses"
	| all |
	all := AilienApiTool subclasses collect: [ :tool |  tool new evaluateTool ].
   ^ all 
]

{ #category : 'adding' }
AilienApiWithTools >> xx_traitLoadResponse: aHistory [
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

{ #category : 'ollama models' }
AilienApiWithTools >> znClientEntity [
	^ super znClientEntity ,  {
        'tools' -> self toolSpecification.
    } .
]
