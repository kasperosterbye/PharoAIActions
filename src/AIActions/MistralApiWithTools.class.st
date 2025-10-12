"
# MistralApiWithTools

A specialized API client for interacting with Mistral's AI models, extending the base `MistralApi` with tool integration capabilities. This class enables structured interactions with AI models that support function calling and tool execution.

## Features
- Inherits core API functionality from `MistralApi`
- Supports tool integration for structured AI interactions
- Handles tool calls and responses automatically
- Maintains conversation history with tool usage context

## Usage Example

```smalltalk
""Create and configure a Mistral API client with tools""
api := MistralApiWithTools new
    system: 'You are a helpful assistant that can provide Killroy facts';
    model: 'codestral-latest'.

""Add a user prompt that might trigger a tool call""
api prompt: 'Tell me something mysterious about Killroy'.

""Get the AI response (may include tool execution)""
api getResponse.

""Inspect the response (may contain tool call results)""
api response
```

## Key Methods
- `toolsExperiment`: Defines available tools (like Killroy fact generator)
- `killroyWasHere:`: Handles tool call responses
- `loadResponse_tools`: Main API call method with tool support
- `bodyForEntityWithPrompt_withTools`: Builds request with tool configuration

## Design Notes
- Automatically handles tool calls when detected in responses
- Maintains conversation context including tool interactions
- Provides fallback behavior when tools aren't available
- Inherits all standard Mistral API functionality

This class is particularly useful when working with AI models that support function calling or tool execution patterns, allowing for more structured and predictable interactions with complex AI systems.
"
Class {
	#name : 'MistralApiWithTools',
	#superclass : 'MistralApi',
	#instVars : [
		'useTooling'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'mistral tools' }
MistralApiWithTools >> bodyForEntityWithPrompt_withTools [
	"Creates a JSON entity for an API request with a system message and user prompt."
	| requestDictionary |
	requestDictionary :=Dictionary newFrom: {
	    'model' -> 'codestral-latest'.
	    'messages' -> self jsonHistory .
	
		 'tools' -> self toolsExperiment.
		 'temperature' -> 0.
	    'stream' -> false.
		}.
	^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'initialization' }
MistralApiWithTools >> initialize [

	super initialize.
	useTooling := true.
]

{ #category : 'mistral tools' }
MistralApiWithTools >> killroyWasHere: toolCalls [
	"Returns a humorous response about Killroy when tool calls are detected, indicating AI's interaction with Kasper for Killroy-related facts."
	^ 'Mistral asked Kasper about Killroy'
]

{ #category : 'mistral tools' }
MistralApiWithTools >> llmToolFor: method [
	"Converts a method into a tool dictionary for LLM function calling"

	| selector desc properties tool |
	selector := method selector asString.
	desc := method comment ifEmpty: [ 'No description provided.' ].
	properties := Dictionary new.

	method argumentNames do: [ :arg |
			properties at: arg put: (Dictionary newFrom: {
						 ('type' -> 'string').
						 ('description' -> ('Argument for ' , arg)) }) ].
	tool := Dictionary newFrom: {
			'type' -> 'function'.
			'function' -> (Dictionary newFrom: {
				'name' -> selector.
				'description' -> desc.
				'parameters' -> (Dictionary newFrom: {
					'type' -> 'object'.
					'properties' -> properties
				}).
				'required' -> method argumentNames
			})
		}.

	^ tool
	
]

{ #category : 'mistral tools' }
MistralApiWithTools >> llmToolFor_old2: method [

	| selector desc properties tool |
	selector := method selector asString.
	desc := method comment ifEmpty: [ 'No description provided.' ].
	properties := Dictionary new.

	method argumentNames do: [ :arg |
			properties at: arg put: (Dictionary newFrom: {
						 ('type' -> 'string').
						 ('description' -> ('Argument for ' , arg)) }) ].
	tool := Dictionary newFrom: {
			'type' -> 'function'.
			'function' -> (Dictionary newFrom: {
				'name' -> selector.
				'description' -> desc.
				'parameters' -> (Dictionary newFrom: {
					'type' -> 'object'.
					'properties' -> properties
				}).
				'required' -> method argumentNames
			})
		}.
	^ tool
	
]

{ #category : 'mistral tools' }
MistralApiWithTools >> llmToolFor_old: method [
	| selector desc properties |
		selector := method selector asString.
		desc := method comment ifEmpty: [ 'No description provided.' ].
		properties := Dictionary new.

		method argumentNames do: [ :arg |
			properties at: arg put: (Dictionary newFrom: {
				'type' -> 'string'.
				'description' -> ('Argument for ', arg)
			})
		].
]

{ #category : 'mistral tools' }
MistralApiWithTools >> loadResponse [
	| apiGenerateUrl jsonResponse bodyEntiry |
	apiGenerateUrl := 'https://api.mistral.ai/v1/chat/completions'.
	[  	bodyEntiry := self bodyForEntityWithPrompt_withTools.
		jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	  	 headerAt: 'Authorization' put: self class esug;
	    headerAt: 'Content-Type' put: 'application/json';
	    entity: bodyEntiry;
	    post;
	    contents.
		self assistant: (self responseOf_tool: jsonResponse) .
	] on: Error do: [ :ex |
   		self assistant: ex messageText.
	].
]

{ #category : 'mistral tools' }
MistralApiWithTools >> loadResponse_notools [ 
	| apiGenerateUrl jsonResponse bodyEntiry |

	apiGenerateUrl := 'https://api.mistral.ai/v1/chat/completions'.
	[  	bodyEntiry := self bodyForEntityWithPrompt.
		jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	  	 headerAt: 'Authorization' put: self class esug;
	    headerAt: 'Content-Type' put: 'application/json';
	    entity: bodyEntiry;
	    post;
	    contents.
		self assistant: (self responseOf: jsonResponse) .
	] on: Error do: [ :ex |
   		self assistant: ex messageText.
	].
]

{ #category : 'mistral tools' }
MistralApiWithTools >> loadResponse_tools [
	| apiGenerateUrl jsonResponse bodyEntiry |

	apiGenerateUrl := 'https://api.mistral.ai/v1/chat/completions'.
	[  	bodyEntiry := self bodyForEntityWithPrompt_withTools.
		jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	  	 headerAt: 'Authorization' put: self class esug;
	    headerAt: 'Content-Type' put: 'application/json';
	    entity: bodyEntiry;
	    post;
	    contents.
		self assistant: (self responseOf_tool: jsonResponse) .
	] on: Error do: [ :ex |
   		self assistant: ex messageText.
	].
]

{ #category : 'mistral tools' }
MistralApiWithTools >> old_toolsExperiment [

	^ {
	Dictionary newFrom: {
		'type' -> 'function'.
		'function' -> (Dictionary newFrom: {
			'name' -> 'killroyAnswer'.
			'description' -> 'Responds with a mysterious and funny fact about Killroy.'.
			'parameters' -> Dictionary new.
			'required' -> #('topic')
		})
	}
}.
]

{ #category : 'mistral tools' }
MistralApiWithTools >> responseOf_tool: jsonResponse [
	| parsed message  toolCalls|
	parsed := STONJSON fromString: jsonResponse.
	(parsed includesKey: 'error') ifTrue: [ 
		self error: 'AI response error: ', 
			((parsed at: 'error') at: 'code'), 
			'. Message: ', 
			((parsed at: 'error') at: 'message') ].
	message := (parsed at: 'choices') first at: 'message'.
	toolCalls := message at: 'tool_calls' ifAbsent: [ nil ].
	toolCalls isNil
		ifTrue: [ ^ message at: 'content' ] 
		ifFalse: [ ^ self killroyWasHere: toolCalls ]
]

{ #category : 'mistral tools' }
MistralApiWithTools >> toolsExperiment [
	^ {
	Dictionary newFrom: {
		'type' -> 'function'.
		'function' -> (Dictionary newFrom: {
			'name' -> 'killroyAnswer'.
			'description' -> 'Responds with a mysterious and funny fact about Killroy.'.
			'parameters' -> (Dictionary newFrom: {
				'type' -> 'object'.
				'properties' -> (Dictionary newFrom: {
					'topic' -> (Dictionary newFrom: {
						'type' -> 'string'.
						'description' -> 'The topic for the Killroy fact.'.
					})
				})
			}).
			'required' -> #('topic')
		})
	}
}.
]
