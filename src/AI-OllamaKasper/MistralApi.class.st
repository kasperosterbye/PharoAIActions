"
MistralApi is a class designed to interact with the Mistral AI API.

This class provides methods to send prompts to the Mistral AI API, retrieve responses, and manage available models. It handles authentication using a Bearer token stored in a local file and supports various operations such as fetching model information and generating responses based on user prompts.

Instance Variables:
    prompt: <String> - The user prompt to be sent to the API.

Class Variables:
    None

Usage:
    | api response models token|
    api := MistralApi new.
    response := api getResponseForPrompt: 'What is the capital of France?'.
    Transcript show: response; cr.

    models := MistralApi models.
    Transcript show: models; cr.

    token := MistralApi token.
    Transcript show: token; cr.

"
Class {
	#name : 'MistralApi',
	#superclass : 'AilienApi',
	#instVars : [
		'prompt'
	],
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'ollama models' }
MistralApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://docs.mistral.ai/getting-started/models/models_overview/ to see the list"
	
	^ super modelNames 
]

{ #category : 'ollama models' }
MistralApi class >> modelNames_old [
	"returns an array with one item per model."
	"Look at https://docs.mistral.ai/getting-started/models/models_overview/ to see the list"
	^ #(
  'codestral-latest'
  'mistral-large-latest'
  'pixtral-large-latest'
  'mistral-saba-latest'
  'ministral-3b-latest'
  'ministral-8b-latest'
  'mistral-embed'
  'mistral-moderation-latest'
  'mistral-ocr-latest'
  'mistral-small-latest'
  'pixtral-12b-2409'
  'open-mistral-nemo'
  'open-codestral-mamba'
)
]

{ #category : 'accessing' }
MistralApi class >> models [
	"Return a list of available Mistral models from the API"
	| url response sorted |
	url := 'https://api.mistral.ai/v1/models'.
	response := ZnClient new
		url: url;
		headerAt: 'Authorization' put: self token;
		get;
		contents.
	sorted := Dictionary new.
	((STONJSON fromString: response) at: 'data') do: [ :model | 
		sorted at: (model at: 'name') put: model
		].
	^ sorted values
]

{ #category : 'as yet unclassified' }
MistralApi class >> modelsBy: id [
	"returns an array with one item per model."
	^ self models collect: [ :model | model at: id ]
]

{ #category : 'accessing' }
MistralApi class >> models_old [
	"Return a list of available Mistral models from the API"
	| url response |
	url := 'https://api.mistral.ai/v1/models'.
	response := ZnClient new
		url: url;
		headerAt: 'Authorization' put: self token;
		get;
		contents.
	^ (STONJSON fromString: response) at: 'data'
]

{ #category : 'accessing' }
MistralApi class >> token [
	"Return the API token for Mistral, read from a local file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ (FileSystem disk workingDirectory / '../../mistralkode.txt')
		readStream contents trimBoth.
]

{ #category : 'mistral models' }
MistralApi >> bodyForEntityWithPrompt [
	| requestDictionary |
	requestDictionary :=Dictionary newFrom: {
	    'model' -> 'codestral-latest'.
	    'messages' -> {
				Dictionary newFrom: {
					'role' -> 'system'.
					'content' -> system
				}. 
		      Dictionary newFrom: { 
		         'role' -> 'user'. 
		         'content' -> prompt 
		      } 
	    }.
		'temperature' -> 0.
	    'stream' -> false.
		}.
	^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'mistral models' }
MistralApi >> getResponseForPrompt: userPrompt [
	"Sends a prompt to an API, receives JSON response, and extracts the 'response' value"
	"Split the method into parts, it is a bit too long now..."
	| apiGenerateUrl jsonResponse |
	apiGenerateUrl := 'https://api.mistral.ai/v1/chat/completions'.
	prompt := userPrompt.
	[  jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	  	 headerAt: 'Authorization' put: self class token;
	    headerAt: 'Content-Type' put: 'application/json';
	    entity: self bodyForEntityWithPrompt;
	    post;
	    contents.
		response := self responseOf: jsonResponse .
	] on: Error do: [ :ex |
   		response := ex messageText.
	].
	^ response.
]

{ #category : 'initialization' }
MistralApi >> initialize [ 
	super initialize.
]

{ #category : 'mistral models' }
MistralApi >> responseOf: jsonResponse [
	^ ((((STONJSON fromString: jsonResponse) at: 'choices') first at: 'message') at: 'content')
]
