Class {
	#name : 'AilienInnerCall',
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
AilienInnerCall class >> on: outer turn: turn [
	| instance |
	instance := self new.
	instance outer: outer.
	instance turn: turn.
	^ instance
]

{ #category : 'adding' }
AilienInnerCall >> callLLM [
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
AilienInnerCall >> check [
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
AilienInnerCall >> executeToolNamed: name withArgs: args [
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
AilienInnerCall >> handleToolCall [
	(toolCall at: 'tool_calls') do: [ :call | 
		outer messageList add: (self processToolCall: call) ]
]

{ #category : 'as yet unclassified' }
AilienInnerCall >> innerCall [

	self callLLM.
	toolCall := self check.
	toolCall = '*notool*' ifTrue: [ ^ self ].
	Transcript << '## ' << outer class name asString << ': ' << turn asString << String lf.
	self messageListAdd.
	self handleToolCall
]

{ #category : 'as yet unclassified' }
AilienInnerCall >> messageListAdd [
	outer messageList add: 'assistant' -> toolCall. 
]

{ #category : 'accessing' }
AilienInnerCall >> outer [
	^ outer
]

{ #category : 'accessing' }
AilienInnerCall >> outer: o [
	outer := o
]

{ #category : 'adding' }
AilienInnerCall >> processToolCall: call [
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
AilienInnerCall >> responseError [
	"Handles API error responses by adding the error message to the conversation history"

	| error |
	error := llmReply at: 'error'.
	outer history assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message') "from: self".
	^ self
]

{ #category : 'accessing' }
AilienInnerCall >> turn [

	^ turn
]

{ #category : 'accessing' }
AilienInnerCall >> turn: anObject [

	turn := anObject
]

{ #category : 'accessing' }
AilienInnerCall >> znClientBasic: jsonPrompt [

	|  entityPrompt entity|
	jsonPrompt
		timeout: outer responseWaitingInSecs;
		url: outer apiGenerateUrl.
	entity := outer znClientEntity deepCopy asDictionary .
	entityPrompt := ZnEntity json: (STONJSON toString: entity).
	jsonPrompt 
		entity: entityPrompt .
	
]
