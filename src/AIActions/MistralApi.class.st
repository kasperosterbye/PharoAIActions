"
# Class Comment for MistralApi

The `MistralApi` class provides an interface to interact with the Mistral AI API for generating chat completions. It extends the `AilienApi` class, inheriting core functionalities for managing AI interactions, including setting models, handling message lists, and managing conversation history.

## Key Features

- **API Endpoint Management**: Provides the specific URL for the Mistral AI API endpoint for generating chat completions.
- **Model Handling**: Offers a predefined list of available models for use with the Mistral API.
- **Token Management**: Reads and manages API tokens required for authenticating requests to the Mistral API.
- **Request Handling**: Facilitates the creation and sending of JSON requests to the Mistral API, including setting appropriate headers and handling responses.

## Usage Example

```st
""Create an instance of MistralApi and set the model""
mistralApi := MistralApi new.
mistralApi model: 'codestral-latest'.

""Set the message list for the API interaction""
mistralApi messageList: { 'role' -> 'user'. 'content' -> 'Hello, how are you?' } asDictionary.

""Inspect the MistralApi instance""
mistralApi inspect.
```

This example demonstrates how to create an instance of `MistralApi`, set the desired model, and configure the message list for an API interaction. The final expression inspects the `MistralApi` instance, allowing you to explore its state and methods interactively in the Pharo Playground.
"
Class {
	#name : 'MistralApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
MistralApi class >> apiGenerateUrl [ 
	"Returns the URL for the Mistral AI API endpoint for generating chat completions"
	^ 'https://api.mistral.ai/v1/chat/completions'.
	
]

{ #category : 'accessing' }
MistralApi class >> esug [
	"Return the API token for Mistral, read from a maarumlam https file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ ZnClient new url: 'https://maarumlam.dk/pharoCommentsByMistral.txt'; get.
]

{ #category : 'accessing' }
MistralApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://docs.mistral.ai/getting-started/models/models_overview/ to see the list"
	
	^ #('codestral-latest'  'devstral-latest' 'labs-devstral-small-2512' 'mistral-large-latest') 
]

{ #category : 'accessing' }
MistralApi class >> token [
	"Return the API token for Mistral, read from a local file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ (FileSystem disk workingDirectory / '../../mistralcode.txt')
		readStream contents trimBoth.
]

{ #category : 'accessing' }
MistralApi class >> znClientHeaders: jsonPrompt [

	jsonPrompt
		headerAt: 'Authorization' put: self esug;
		headerAt: 'Content-Type' put: 'application/json'.
]
