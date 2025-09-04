"
# Class Comment for MistralApi

The `MistralApi` class provides an interface to interact with the Mistral AI API, allowing users to send prompts and receive responses from the AI model. It extends the `AilienApi` superclass and is designed to work with the Mistral AI's chat completion endpoint.

## Key Features

- **Model Interaction**: Communicates with Mistral AI's API to generate responses based on user prompts.
- **Tool Integration**: Supports tool-based interactions, allowing the AI to call specific functions based on the context.
- **Response Handling**: Processes JSON responses from the API and extracts relevant content or tool calls.
- **Error Management**: Handles API errors gracefully and provides meaningful error messages.

## Usage Example

The following example demonstrates how to create and use a `MistralApi` instance in the Pharo Playground:

```st
""Create a new MistralApi instance""
mistral := MistralApi new.

""Set the system message and user prompt""
mistral system: 'You are a helpful assistant.';
mistral prompt: 'Tell me a joke about programming'.

""Get the AI's response""
mistral getResponse.

""Inspect the assistant's response""
mistral assistant
```

This example initialises a `MistralApi` instance, sets a system message and user prompt, retrieves the AI's response, and then inspects the response using the `assistant` method.

## Design Decisions

- **Fluid Interface**: The class is designed with a fluid interface, allowing method chaining for a more expressive API.
- **Tool Support**: The class includes methods to handle tool-based interactions, such as `toolsExperiment` and `killroyWasHere`.
- **Error Handling**: Comprehensive error handling is implemented to manage API errors and provide feedback to the user.
- **Configuration**: The class is initialised with the latest Mistral model and supports tooling by default.

The `MistralApi` class is part of the `AIActions` package and is tagged with 'AIApi', indicating its role in AI-related functionality within the system.
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
	
	^ super modelNames 
]

{ #category : 'accessing' }
MistralApi class >> models [
	"Returns a sorted collection of models from the Mistral API, authenticated using a token from a local file."
	| url response sorted |
	url := 'https://api.mistral.ai/v1/models'.
	response := ZnClient new
		url: url;
		headerAt: 'Authorization' put: self esug;
		get;
		contents.
	sorted := Dictionary new.
	((STONJSON fromString: response) at: 'data') do: [ :model | 
		sorted at: (model at: 'name') put: model
		].
	^ sorted values
]

{ #category : 'AI models' }
MistralApi class >> modelsBy: id [
	"returns an array with one item per model."
	^ self models collect: [ :model | model at: id ]
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

{ #category : 'mistral models' }
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
	"Initialises the MistralApi instance with the latest model."
	super initialize.
	self model: 'codestral-latest'.
	useTooling := true
]

{ #category : 'as yet unclassified' }
MistralApi >> killroyWasHere: toolCalls [
	^ 'Mistral asked Kasper about Killroy'
]

{ #category : 'mistral models' }
MistralApi >> loadResponse [
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

{ #category : 'mistral models' }
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

{ #category : 'mistral models' }
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

{ #category : 'as yet unclassified' }
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
	aStream << 'MistralApi: ' << self model.
]

{ #category : 'mistral models' }
MistralApi >> responseOf: jsonResponse [
	| parsed message  |
	parsed := STONJSON fromString: jsonResponse.
	(parsed includesKey: 'error') ifTrue: [ 
		self error: 'AI response error: ', 
			((parsed at: 'error') at: 'code'), 
			'. Message: ', 
			((parsed at: 'error') at: 'message') ].
	message := (parsed at: 'choices') first at: 'message'.
	^ message at: 'content' 
]

{ #category : 'mistral models' }
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

{ #category : 'as yet unclassified' }
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
