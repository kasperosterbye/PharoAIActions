Class {
	#name : 'MistralApi',
	#superclass : 'Object',
	#instVars : [
		'model',
		'system',
		'promptPrefix',
		'response'
	],
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'ollama models' }
MistralApi class >> modelNames [
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

{ #category : 'ollama models' }
MistralApi >> getResponseForPrompt: prompt [
	"Sends a prompt to an API, receives JSON response, and extracts the 'response' value"
	"Split the method into parts, it is a bit too long now..."
	| apiGenerateUrl jsonResponse requestDictionary requestBody|
	apiGenerateUrl := 'https://api.mistral.ai/v1/chat/completions'.
	"apiGenerateUrl := 'https://api.mistral.ai/v1/completions'."
	requestDictionary := Dictionary newFrom: {
	    'model' -> 'codestral-latest'.
	    'messages' -> { 
	        Dictionary newFrom: { 
	            'role' -> 'user'. 
	            'content' -> prompt 
	        } 
	    }.
	    'stream' -> false.
		}.
	requestBody := (STONJSON toString: requestDictionary).
	[ 
	jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	  	 headerAt: 'Authorization' put: 'Bearer 1rQmOK2ugF9ekIQFexfgjYJejP8tzuFL';
	    headerAt: 'Content-Type' put: 'application/json';
	    entity: (ZnEntity json: requestBody);
	    post;
	    contents.
		"self response: ((STONJSON fromString: jsonResponse) at: 'response') contents ."
		self response: ((((STONJSON fromString: jsonResponse) at: 'choices') first at: 'message') at: 'content').
	] on: Error do: [ :ex |
   		self response: ex messageText.
	].
	^ self response.
]

{ #category : 'accessing' }
MistralApi >> model [

	^ model
]

{ #category : 'accessing' }
MistralApi >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
MistralApi >> promptPrefix [

	^ promptPrefix
]

{ #category : 'accessing' }
MistralApi >> promptPrefix: anObject [

	promptPrefix := anObject
]

{ #category : 'accessing' }
MistralApi >> response [

	^ response
]

{ #category : 'accessing' }
MistralApi >> response: anObject [

	response := anObject
]

{ #category : 'accessing' }
MistralApi >> system [

	^ system
]

{ #category : 'accessing' }
MistralApi >> system: anObject [

	system := anObject
]
