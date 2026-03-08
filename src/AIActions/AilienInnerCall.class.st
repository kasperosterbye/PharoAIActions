"
# Class: AilienInnerCall

## Class Comment

The `AilienInnerCall` class is responsible for managing the interaction between the language model and the tools within the AI API framework. It handles the configuration of the ZnClient, the processing of tool calls, and the management of the conversation history.

### Responsibilities

- **Configuration**: Configures the ZnClient with the necessary timeout and URL settings.
- **Tool Execution**: Executes tools based on the tool calls received from the language model.
- **Response Handling**: Processes the responses from the language model, including handling errors and tool calls.
- **Conversation Management**: Manages the conversation history by adding messages and tool call results.

### Usage Example

```st
| outer turn innerCall |
outer := AilienOuter new.
outer apiGenerateUrl: 'https://api.example.com/generate'.
outer responseWaitingInSecs: 30.
outer znClientEntity: Dictionary newFrom: {'key' -> 'value'}.
outer znClientHeaders: Dictionary newFrom: {'Authorization' -> 'Bearer token'}.

turn := 1.
innerCall := AilienInnerCall on: outer turn: turn.
innerCall innerCall.

innerCall
```

This example demonstrates how to create and use an instance of `AilienInnerCall` to interact with the language model and process tool calls. The `innerCall` method initiates the process, and the instance can be inspected to verify the results.
"
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
	"Creates and initialises a new instance of AilienInnerCall with specified outer and turn parameters"
	| instance |
	instance := self new.
	instance outer: outer.
	instance turn: turn.
	^ instance
]

{ #category : 'adding' }
AilienInnerCall >> callLLM [
	"Calls the language model with the current prompt and processes the response"
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
	content := message at: 'content' ifAbsent: [ nil ].
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
	"Handles the tool calls by processing each call and adding the result to the message list."
	(toolCall at: 'tool_calls') do: [ :call | 
		outer messageList add: (self processToolCall: call) ]
]

{ #category : 'as yet unclassified' }
AilienInnerCall >> innerCall [
	"Initiates the language model call, checks for tool calls, and processes them or handles the response"

	self callLLM.
	toolCall := self check.
	toolCall = '*notool*' ifTrue: [ ^ self ].
	Transcript << '## ' << outer class name asString << ': ' << turn asString << String lf.
	self messageListAdd.
	self handleToolCall
]

{ #category : 'as yet unclassified' }
AilienInnerCall >> messageListAdd [
	"Adds the tool call to the message list for the outer object"
	outer messageList add: 'assistant' -> toolCall. 
]

{ #category : 'accessing' }
AilienInnerCall >> outer [
	"Returns the outer object associated with this instance"
	^ outer
]

{ #category : 'accessing' }
AilienInnerCall >> outer: o [
	"Sets the outer object associated with this instance"
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
	"Returns the turn associated with this instance"

	^ turn
]

{ #category : 'accessing' }
AilienInnerCall >> turn: anObject [
	"Sets the turn associated with this instance"

	turn := anObject
]

{ #category : 'accessing' }
AilienInnerCall >> znClientBasic: jsonPrompt [
	"Configures the ZnClient with timeout and URL, and sets the entity for the JSON prompt"

	|  entityPrompt entity|
	jsonPrompt
		timeout: outer responseWaitingInSecs;
		url: outer apiGenerateUrl.
	entity := outer znClientEntity deepCopy asDictionary .
	entityPrompt := ZnEntity json: (STONJSON toString: entity).
	jsonPrompt 
		entity: entityPrompt .
	
]
