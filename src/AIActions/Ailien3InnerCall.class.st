Class {
	#name : 'Ailien3InnerCall',
	#superclass : 'Object',
	#instVars : [
		'outer',
		'llmReply',
		'toolCall',
		'turn'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'instance creation' }
Ailien3InnerCall class >> on: outer turn: turn [
	| instance |
	instance := self new.
	instance outer: outer.
	instance turn: turn.
	^ instance
]

{ #category : 'adding' }
Ailien3InnerCall >> callLLM [
	| jsonPrompt rawResponse |
	jsonPrompt := ZnClient new.
	self znClientBasic: jsonPrompt.
	outer class znClientHeaders: jsonPrompt.
	rawResponse := jsonPrompt
		               post;
		               contents.
	llmReply := STONJSON fromString: rawResponse.
]

{ #category : 'checking' }
Ailien3InnerCall >> check [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
	(llmReply includesKey: 'error') ifTrue: [ 
		self responseError. 
		^ '*notool*'].
	message := (llmReply at: 'choices') first at: 'message'.
	content := message at: 'content'.
	(content isNotNil and: [ content isNotEmpty  ]) ifTrue: [
			outer history assistant: content" from: self".
			^ '*notool*'].
	^ message.
]

{ #category : 'trait tools support' }
Ailien3InnerCall >> executeToolNamed: name withArgs: args [
	"Executes a tool with the given name and arguments, returning the result"
	AilienApiTool subclasses do: [ :tool | 
		| instance |
		instance := tool new.
		instance name = name ifTrue:[
			^ instance executeTool: args
			] ].
    ^ 'Unknown tool: ', name
]

{ #category : 'as yet unclassified' }
Ailien3InnerCall >> handleToolCall [
	(toolCall at: 'tool_calls') do: [ :call | 
		outer messageList add: (self processToolCall: call) ]
]

{ #category : 'as yet unclassified' }
Ailien3InnerCall >> innerCall [

	self callLLM.
	toolCall := self check.
	toolCall = '*notool*' ifTrue: [ ^ self ].
	Transcript << '## ' << outer class name asString << ': ' << turn asString << String lf.
	self messageListAdd.
	self handleToolCall
]

{ #category : 'as yet unclassified' }
Ailien3InnerCall >> messageListAdd [
	outer messageList add: 'assistant' -> toolCall. 
]

{ #category : 'accessing' }
Ailien3InnerCall >> outer [
	^ outer
]

{ #category : 'accessing' }
Ailien3InnerCall >> outer: o [
	outer := o
]

{ #category : 'adding' }
Ailien3InnerCall >> processToolCall: call [
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
Ailien3InnerCall >> responseError [
	"Handles API error responses by adding the error message to the conversation history"

	| error |
	error := llmReply at: 'error'.
	outer history assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message') "from: self".
	^ self
]

{ #category : 'accessing' }
Ailien3InnerCall >> turn [

	^ turn
]

{ #category : 'accessing' }
Ailien3InnerCall >> turn: anObject [

	turn := anObject
]

{ #category : 'accessing' }
Ailien3InnerCall >> znClientBasic: jsonPrompt [

	|  entityPrompt entity|
	jsonPrompt
		timeout: outer responseWaitingInSecs;
		url: outer apiGenerateUrl.
	entity := outer znClientEntity deepCopy asDictionary .
	entityPrompt := ZnEntity json: (STONJSON toString: entity).
	jsonPrompt 
		entity: entityPrompt .
	
]
