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
	
	^ self models collect: [ :model | model at: 'name' ]
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
					'role' -> 'system'.
					'content' -> self system
				}. 
		      Dictionary newFrom: { 
		         'role' -> 'user'. 
		         'content' -> prompt 
		      } 
	    }.
		'temperature' -> 0.
	    'stream' -> false.
		}.
	requestBody := (STONJSON toString: requestDictionary).
	[ | mistralKode |
	mistralKode := (FileSystem disk workingDirectory / '../../mistralkode.txt' readStream contents trimBoth) 
			readStream contents.
	jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	  	 headerAt: 'Authorization' put: mistralKode;
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

{ #category : 'initialization' }
MistralApi >> initialize [ 
	super initialize.
	"self model: (self class modelNames) first."
	self model: 'codestral-latest'.
	self system: ''.
	self promptPrefix: ''.
]

{ #category : 'accessing' }
MistralApi >> model [

	^ model
]

{ #category : 'accessing' }
MistralApi >> model: anObject [

	model := anObject
]

{ #category : 'printing' }
MistralApi >> printOn: string [
	string << 'MistralApi: ' << self model.
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
