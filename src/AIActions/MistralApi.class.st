"
# Class Comment for MistralApi

## Overview

The `MistralApi` class is designed to interact with the Mistral AI API, allowing users to send prompts and receive responses from various AI models. This class handles the initialization, configuration, and communication with the Mistral API, including sending requests and processing responses.

## Key Features

- **Initialization**: The class initializes with the latest model (`codestral-latest`) by default.
- **Prompt Handling**: Users can send prompts to the API and receive responses.
- **Model Management**: The class provides methods to retrieve available models from the API and manage model configurations.
- **Error Handling**: The class includes error handling to manage exceptions that may occur during API communication.

## Methods

### Initialization

- **`initialize`**: Initializes the `MistralApi` instance with the latest model.

### Prompt Handling

- **`getResponseForPrompt:`**: Sends a user prompt to the Mistral API and returns the response. This method handles the construction of the request, sending it to the API, and processing the JSON response.
- **`bodyForEntityWithPrompt`**: Constructs the JSON body for the API request based on the user prompt.

### Model Management

- **`models`**: Retrieves a list of available Mistral models from the API and returns them as a sorted collection.
- **`models_old`**: An older version of the `models` method that returns the raw list of models from the API.
- **`modelsBy:`**: Returns an array with one item per model, based on a specified key.
- **`modelNames`**: Returns an array of model names. This method is a placeholder that currently calls the superclass method.
- **`modelNames_old`**: Returns an array of model names, including various Mistral models.

### Utility Methods

- **`responseOf:`**: Extracts the 'content' from the first 'message' in the 'choices' array of a JSON response.
- **`token`**: Returns the API token for Mistral, read from a local file.

### Printing

- **`printOn:`**: Prints a string representation of the `MistralApi` instance, including the model name.

## Usage Example

```smalltalk
| api response |
api := MistralApi new.
response := api getResponseForPrompt: 'What is the capital of France?'.
Transcript show: response; cr.
```

This example initializes the `MistralApi` class, sends a prompt to the API, and prints the response to the Transcript.

## Dependencies

- **ZnClient**: Used for making HTTP requests to the Mistral API.
- **STONJSON**: Used for parsing and constructing JSON data.

## Notes

- Ensure that the API token is correctly stored in the specified file (`../../mistralkode.txt`) for authentication.
- The class is part of the `AIActions` package and is tagged with `AIApi`.

By following this class comment, users can understand the purpose, features, and usage of the `MistralApi` class, making it easier to integrate and utilize in their projects.
"
Class {
	#name : 'MistralApi',
	#superclass : 'AilienApi',
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

{ #category : 'initialization' }
MistralApi >> initialize [ 
	"Initialises the MistralApi instance with the latest model."
	super initialize.
	self model: 'codestral-latest'.
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
