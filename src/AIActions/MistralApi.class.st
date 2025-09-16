"
# Class Comment for MistralApi

The `MistralApi` class provides an interface to interact with Mistral's AI models, enabling developers to send prompts, receive responses, and utilise tooling capabilities. It extends the `AilienApi` superclass, inheriting core conversation management functionality while specialising in Mistral-specific implementations.

## Key Features

- **Model Interaction**: Supports multiple Mistral models (e.g., 'codestral-latest', 'mistral-small-latest')
- **Tool Integration**: Optional tooling capabilities for enhanced functionality
- **Conversation Management**: Maintains and formats chat history
- **Error Handling**: Robust error management for API responses

## Usage Example

```smalltalk
""Create and configure a Mistral API instance""
mistral := MistralApi new.
mistral model: 'mistral-small-latest'.  ""Set the model""
mistral system: 'You are a helpful assistant'.  ""Set system message""
mistral user: 'Tell me about Pharo'.  ""Add user prompt""
mistral getResponse.  ""Get AI response""
mistral response  ""Inspect the response""
```

## Implementation Notes

- Requires valid API credentials stored in a file
- Handles both standard and tool-enhanced API requests
- Maintains conversation history in chronological order
- Provides formatted output for debugging and display purposes

The class is designed for integration with Pharo's Smalltalk environment, offering a clean interface for AI interactions while handling the complexities of API communication and response processing.
```
"
Class {
	#name : 'MistralApi',
	#superclass : 'AilienApi',
	#instVars : [
		'useTooling'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
MistralApi class >> esug [
	"Return the API token for Mistral, read from a maarumlam https file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ ZnClient new url: 'https://maarumlam.dk/pharoCommentsByMistral.txt'; get.
]

{ #category : 'AI models' }
MistralApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://docs.mistral.ai/getting-started/models/models_overview/ to see the list"
	
	^ #('codestral-latest'  'mistral-small-latest' 'devstral-medium-2507' 'mistral-medium-2508') 
]

{ #category : 'accessing' }
MistralApi class >> token [
	"Return the API token for Mistral, read from a local file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ (FileSystem disk workingDirectory / '../../mistralcode.txt')
		readStream contents trimBoth.
]

{ #category : 'mistral models' }
MistralApi >> bodyForEntityWithPrompt [
	"Creates a JSON entity for an API request with a system message and user prompt."
	| requestDictionary |
	requestDictionary :=Dictionary newFrom: {
	    'model' -> 'codestral-latest'.
	    'messages' -> self jsonHistory .
		 'temperature' -> 0.
	    'stream' -> false.
		}.
	^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'mistral tools' }
MistralApi >> bodyForEntityWithPrompt_withTools [
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
MistralApi >> initialize [ 
	"Initialises a new MistralApi instance with default model and tooling enabled, ready for AI interactions. Sets up conversation management and response handling."
    super initialize.
    self model: self class defaultModel .  "eller second, third etc."
    useTooling := true
]

{ #category : 'mistral tools' }
MistralApi >> killroyWasHere: toolCalls [
	"Returns a humorous response about Killroy when tool calls are detected, indicating AI's interaction with Kasper for Killroy-related facts."
	^ 'Mistral asked Kasper about Killroy'
]

{ #category : 'mistral models' }
MistralApi >> loadResponse [

	| apiGenerateUrl jsonResponse bodyEntiry |
	apiGenerateUrl := 'https://api.mistral.ai/v1/chat/completions'.
	[
		bodyEntiry := self bodyForEntityWithPrompt.
		jsonResponse := ZnClient new
			                url: apiGenerateUrl;
			                headerAt: 'Authorization' put: self class esug;
			                headerAt: 'Content-Type' put: 'application/json';
			                entity: bodyEntiry;
			                post;
			                contents.
		self assistant: (self responseOf: jsonResponse) ]
		on: Error
		do: [ :ex | self assistant: ex messageText ]
]

{ #category : 'mistral tools' }
MistralApi >> loadResponse_notools [ 
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
MistralApi >> loadResponse_tools [
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
MistralApi >> old_toolsExperiment [

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

{ #category : 'printing' }
MistralApi >> printOn: aStream [
	"Prints the MistralApi instance with its current model name for debugging and logging purposes."
	aStream << 'MistralApi: ' << self model.
]

{ #category : 'mistral models' }
MistralApi >> responseOf: jsonResponse [
	| parsed   |
	parsed := STONJSON fromString: jsonResponse.
	[^ ((parsed at: 'choices') first at: 'message') at: 'content' ]
		on: Error 
		do: [ ^ 'Error bla bla: ', jsonResponse  ].
]

{ #category : 'mistral tools' }
MistralApi >> responseOf_tool: jsonResponse [
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
MistralApi >> toolsExperiment [
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
