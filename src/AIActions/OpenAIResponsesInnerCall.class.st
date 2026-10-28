"
Handles OpenAI Responses API replies, coordinating tool execution and recording assistant responses in the conversation history.
"
Class {
	#name : 'OpenAIResponsesInnerCall',
	#superclass : 'AilienInnerCall',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'checking' }
OpenAIResponsesInnerCall >> check [
	| output message content text |
	((llmReply includesKey: 'error') 
		and: [ (llmReply at: 'error') isNotNil ]) 
		ifTrue: [ 
		self responseError.
		^ '*notool*' ].

	output := llmReply at: 'output'.

	message := output
		detect: [ :item | (item at: 'type') = 'message' ]
		ifNone: [ ^ output ].

	content := message at: 'content'.

	text := content
		detect: [ :item | (item at: 'type') = 'output_text' ]
		ifNone: [ ^ output ].

	outer history assistant: (text at: 'text').
	^ '*notool*'
]

{ #category : 'adding' }
OpenAIResponsesInnerCall >> handleToolCall [
    "Execute OpenAI Responses API tool calls, record their
    interactions in AIAHistory, and return results to the API."

    toolCall do: [ :call |
        (call at: 'type') = 'function_call' ifTrue: [
            | name arguments args result output |

            name := call at: 'name'.
            arguments := call at: 'arguments'.
            args := STONJSON fromString: arguments.

            result := self
                executeToolNamed: name
                withArgs: args.

            outer history
                toolCall: name
                arguments: arguments
                result: result.

            output := Dictionary newFrom: {
                'type' -> 'function_call_output'.
                'call_id' -> (call at: 'call_id').
                'output' -> result }.

            outer messageList add: 'assistant' -> output ] ]

]

{ #category : 'adding' }
OpenAIResponsesInnerCall >> messageListAdd [
	toolCall do: [ :item |
		outer messageList add: 'assistant' -> item ]
]
