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
	#name : 'OLD_MistralApiWithTools',
	#superclass : 'MistralApi',
	#instVars : [
		'useTooling'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'mistral tools' }
OLD_MistralApiWithTools >> bodyForEntityWithPrompt [
	"Creates a JSON entity for an API request with a system message and user prompt."
	| requestDictionary |
	requestDictionary :=Dictionary newFrom: {
	    'model' -> 'codestral-latest'.
	    'messages' -> self jsonHistory .
	
		 'tools' -> self toolsExperiment.
		 'temperature' -> 0.
	    'stream' -> false.
		}.
	self halt.
	^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'mistral tools' }
OLD_MistralApiWithTools >> bodyForEntityWithPrompt_withTools [
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

{ #category : 'as yet unclassified' }
OLD_MistralApiWithTools >> evaKommentar [
	^ 'Det er to forskellige eksperimenter, og lige nu blander du dem sammen:
	1.	Teste din Pharo-pipeline (det tekniske)
Her skal du tvinge et tool-kald, så du kan se at tool_calls + killroyWasHere: virker.
Fx send noget i den her stil:

"tools": [
  {
    "type": "function",
    "function": {
      "name": "killroyAnswer",
      "description": "Echoes the topic back.",
      "parameters": {
        "type": "object",
        "properties": {
          "topic": { "type": "string" }
        },
        "required": ["topic"]
      }
    }
  }
],
"tool_choice": {
  "type": "function",
  "function": { "name": "killroyAnswer" }
}

Så uanset hvad du skriver som prompt ("Who is havanki", "what time is it", hvad som helst), vil svaret komme som tool_calls, og din Pharo-kode bliver testet.

	2.	Teste LLM’ens egen beslutning om at bruge tools
Her kan du fint lave et getCurrentTime-tool med description á la
"Use this tool to answer any question about the current time or date."
og ikke sætte tool_choice. Så ser du, om den frivilligt bruger det på "what time is it" – men det er altid probabilistisk.

Vigtig: Start med (1) for at være sikker på, at din egen kode virker. Bagefter kan du lege med (2) og lade modellen “spotte” hvornår den vil bruge et tool.'
]

{ #category : 'initialization' }
OLD_MistralApiWithTools >> initialize [

	super initialize.
	useTooling := true.
]

{ #category : 'mistral tools' }
OLD_MistralApiWithTools >> killroyWasHere: toolCalls [
	"Returns a humorous response about Killroy when tool calls are detected, indicating AI's interaction with Kasper for Killroy-related facts."
	^ 'Mistral asked Kasper about havanki'
]

{ #category : 'mistral tools' }
OLD_MistralApiWithTools >> old_loadResponse: history [
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
		history assistant: (self responseOf_tool: jsonResponse) .
	] on: Error do: [ :ex |
   		history assistant: ex messageText.
	].
]

{ #category : 'printing' }
OLD_MistralApiWithTools >> printOn: aStream [
	"Prints the MistralApi instance with its current model name for debugging and logging purposes."
	aStream << 'MistralApiWithTools: ' << self model.
]

{ #category : 'mistral tools' }
OLD_MistralApiWithTools >> responseOf: jsonResponse [
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
OLD_MistralApiWithTools >> responseOf_tool: jsonResponse [
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
OLD_MistralApiWithTools >> toolsExperiment [
	^ {
		Dictionary newFrom: {
			'type' -> 'function'.
			'function' -> (Dictionary newFrom: {
				'name' -> 'killroyAnswer'.
				'description' -> 'Responds with a mysterious and funny fact about havanki.'.
				'parameters' -> (Dictionary newFrom: {
					'type' -> 'object'.
					'properties' -> (Dictionary newFrom: {
						'topic' -> (Dictionary newFrom: {
							'type' -> 'string'.
							'description' -> 'The topic for the havanki fact.'.
						})
					}).
					'required' -> #('topic')
				})
			})
		}
	}.
]
