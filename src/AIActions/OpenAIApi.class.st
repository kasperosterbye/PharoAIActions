"
# Class: OpenAIApi

A subclass of `AilienApi` designed to interact with the OpenAI API for generating chat completions. This class provides methods to configure and execute requests to the OpenAI API, manage conversation history, and handle responses.

## Usage Example

```st
""Create an instance of OpenAIApi and set the model""
openAI := OpenAIApi new.
openAI model: 'gpt-5.1'.

""Add a message to the message list""
openAI messageList: {('user' -> 'Hello, how are you?').}.

""Generate the API URL""
url := openAI apiGenerateUrl.

""Create a ZnClient entity with the JSON prompt""
jsonPrompt := openAI znClientEntity.

""Set the necessary headers for the ZnClient""
openAI znClientHeaders: jsonPrompt.

""Inspect the JSON prompt""
jsonPrompt
```

This example demonstrates how to create an instance of `OpenAIApi`, set the model, add a message to the message list, generate the API URL, create a ZnClient entity with the JSON prompt, set the necessary headers for the ZnClient, and inspect the JSON prompt.
"
Class {
	#name : 'OpenAIApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
OpenAIApi class >> apiGenerateUrl [
	"Method to generate the API URL for OpenAIApi."
    ^ 'https://api.openai.com/v1/chat/completions'
]

{ #category : 'accessing' }
OpenAIApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://platform.openai.com/docs/models to see the list"
	
	^ #('gpt-5.2-2025-12-11' 'gpt-5.1' 'gpt-5.3-codex'  'gpt-5-mini' )
]

{ #category : 'accessing' }
OpenAIApi class >> openAI01 [
	"Method to read and trim the contents of a file named Eva01.txt."
	^ (FileSystem disk workingDirectory / '../../Eva01.txt')
		readStream contents trimBoth.
]

{ #category : 'accessing' }
OpenAIApi class >> znClientHeaders: jsonPrompt [
	"Sets the necessary headers for the ZnClient to interact with the OpenAI API, including authorization and content type."
	jsonPrompt
		headerAt: 'Authorization' put: self openAI01;
		headerAt: 'OpenAI-Organization' put: 'org-XmWYpGR0EsRqkASrs8HE3hy6';
		headerAt: 'OpenAI-Project' put: 'proj_2QRIZLNVevImlaU0bMVzafGt';
		headerAt: 'Content-Type' put: 'application/json'.
]
