"
# Class: OllamaApi

AilienApi << #OllamaApi
    slots: {}
    tag: 'AIApi'
    package: 'AIActions'

## Class comment

The `OllamaApi` class provides an interface to interact with the Ollama API, allowing users to generate responses from various AI models. This class extends the `AilienApi` superclass and is designed to handle specific interactions with the Ollama API, including model management, message processing, and response handling.

### Usage Example

```st
""Create an instance of OllamaApi and set the model""
ollamaApi := OllamaApi newModel: 1.

""Set the message list for the API interaction""
ollamaApi messageList: { 'user' -> 'Hello, how are you?' }.

""Load the response from the API""
ollamaApi loadResponse: 'http://localhost:11434/api/chat'.

""Inspect the response""
ollamaApi history
```

This example demonstrates how to create an instance of `OllamaApi`, set the model, and interact with the API to generate a response. The `history` method is used to inspect the conversation history after the response is loaded.
"
Class {
	#name : 'OllamaApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
OllamaApi class >> apiGenerateUrl [ 
	"Returns the URL for the Ollama API chat endpoint"
	^ 'http://localhost:11434/api/chat'.
	
]

{ #category : 'accessing' }
OllamaApi class >> modelNames [
	"returns an array with one item per model."
	^ self models collect: [ :ollamaModel | ollamaModel at: 'name' ]
]

{ #category : 'accessing' }
OllamaApi class >> models [
	"returns an array with one item per model. Each item has nested informations, and some arrays"
	| response  |

	[response := ZnClient new get: 'http://localhost:11434/api/tags'.
	^ (STONJSON fromString: response) at: 'models' ]
	on: Error
	do: [ ^ #() ] .
]

{ #category : 'accessing' }
OllamaApi class >> newModel: modelNumber [
	"make an instance of OllamaApi based on a specfic Ollama model installed"
	| selectedModel |
	selectedModel := self modelNames 
		at: modelNumber 
		ifAbsent: [ self modelNames at: 1 ]. "Select the first one"
	^ self new model: selectedModel 
]

{ #category : 'accessing' }
OllamaApi class >> ollamaVersion [
	"Retrieve the Ollama version"
	| response  |
	
	response := ZnClient new get: 'http://localhost:11434/api/version'.
	^ (STONJSON fromString: response) at: 'version'  .
]

{ #category : 'accessing' }
OllamaApi class >> znClientHeaders: foo [
	"ignore me"
]

{ #category : 'adding' }
OllamaApi >> continueToolCall: parsed orWrite: aHistory [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
self halt.
	(parsed includesKey: 'error') ifTrue: [ 
		self responseError: parsed hist: aHistory. 
		^ nil ].
	message := parsed at: 'message'.
	content := message at: 'content'.
	(content isNotNil and: [ content isNotEmpty  ]) ifTrue: [
			aHistory assistant: content" from: self".
			^ nil ].
	^ message.
]

{ #category : 'responses' }
OllamaApi >> loadResponse: aHistory [
	"Loads and processes the response from the AI API, updating the conversation history with the assistant's reply."
	| maxTurns  |
	history := aHistory.
	maxTurns := 50.
	1 to: maxTurns do: [ :turn |
			(OllamaInnerCall on: self turn: turn) innerCall.
			].
	^ history assistant: 
		('API Error: tried more than the {1} allowed TOOLS calls' format: { maxTurns })
]
