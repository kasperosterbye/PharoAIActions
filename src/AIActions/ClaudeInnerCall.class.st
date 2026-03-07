"
# ClaudeInnerCall

A specialised inner call handler for Claude AI API interactions, extending the base `AilienInnerCall` functionality with Claude-specific response processing and tool call management.

## Purpose

`ClaudeInnerCall` manages the execution flow of Claude API calls, handling tool use responses, processing assistant messages, and managing conversation state. It serves as the bridge between the outer AI context and Claude's specific response format, particularly for tool-based interactions.

## Key Responsibilities

- **Tool Call Processing**: Handles Claude's `tool_use` content blocks and executes corresponding tools
- **Response Management**: Processes Claude API responses, extracting text content and tool calls
- **Error Handling**: Manages API errors and provides appropriate fallback behaviour
- **Conversation Flow**: Maintains conversation history with proper role assignments and content formatting

## Usage

```smalltalk
""Create a Claude inner call for processing tool interactions""
outer := AilienOuter new.
innerCall := ClaudeInnerCall on: outer turn: 1.

""The inner call will automatically process Claude responses and handle tool calls""
innerCall innerCall.

""Inspect the conversation history after processing""
outer history
```

## Implementation Notes

The class overrides the `check` method to handle Claude's specific response format, particularly the distinction between text content and tool use blocks. When tool calls are present, it processes each one and adds the results to the conversation history with proper `tool_result` formatting.

The `processToolCall:` method creates properly formatted tool result entries that Claude can understand in subsequent interactions, maintaining the conversation flow for multi-turn tool-assisted dialogues.
"
Class {
	#name : 'ClaudeInnerCall',
	#superclass : 'AilienInnerCall',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'adding' }
ClaudeInnerCall >> check [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
	(llmReply includesKey: 'error') ifTrue: [ 
		self responseError.
		^ '*notool*' ].
	message := llmReply at: 'content'.
	content := message select: [ :block | (block at: 'type') = 'tool_use' ].
	content isEmpty ifTrue: [
			outer history assistant: ((message detect: [ :b | (b at: 'type') = 'text' ]) at: 'text'). " from: self"
			^ '*notool*' ].
	^ message 
]

{ #category : 'adding' }
ClaudeInnerCall >> handleToolCall [
	"Handles the tool calls by processing each call and adding the result to the message list"
    (toolCall select: [ :call | (call at: 'type') = 'tool_use' ])
        do: [ :call | outer messageList add: (self processToolCall: call) ]
]

{ #category : 'adding' }
ClaudeInnerCall >> processToolCall: call [
	"Processes a single tool call, executes the corresponding tool with its arguments, and returns the result formatted for the conversation history"
    | result encoded|
    result := self 
        executeToolNamed: (call at: 'name')
        withArgs: (call at: 'input').
    encoded := 'user' -> (Dictionary newFrom: {
        'role' -> 'user'.
        'content' -> { Dictionary newFrom: {
            'type' -> 'tool_result'.
            'tool_use_id' -> (call at: 'id').
            'content' -> result } } }).
	^ encoded 
]
