"
OllamaInnerCall handles the processing of tool calls within the AI API framework, executing specified tools and managing the interaction with the language model.
"
Class {
	#name : 'OllamaInnerCall',
	#superclass : 'AilienInnerCall',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'checking' }
OllamaInnerCall >> check [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
	(llmReply includesKey: 'error') ifTrue: [ 
		self responseError. 
		^ '*notool*'].
	message := llmReply at: 'message'.
	content := message at: 'content' ifAbsent: [ nil ].
	(content isNotNil and: [ content isNotEmpty  ]) ifTrue: [
			outer history assistant: content" from: self".
			^ '*notool*'].
	^ message.
]

{ #category : 'adding' }
OllamaInnerCall >> processToolCall: call history: aHistory [
    "Execute an Ollama tool call, record it, and return a native tool result."
    | function name arguments result |

    function := call at: 'function'.
    name := function at: 'name'.
    arguments := function at: 'arguments'.

    result := AilienApiTool
        executeToolNamed: name
        withArgs: arguments.

    aHistory
        toolCall: name
        arguments: (STONJSON toString: arguments)
        result: result.

    ^ 'tool' -> (Dictionary newFrom: {
        'tool_call_id' -> (call at: 'id').
        'content' -> result })
]
