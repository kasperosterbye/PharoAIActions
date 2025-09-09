Class {
	#name : 'OllamaApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'ollama models' }
OllamaApi class >> modelNames [
	"returns an array with one item per model."
	^ self models collect: [ :ollamaModel | ollamaModel at: 'name' ]
]

{ #category : 'AI models' }
OllamaApi class >> models [
	"returns an array with one item per model. Each item has nested informations, and some arrays"
	| response  |

	response := ZnClient new get: 'http://localhost:11434/api/tags'.
	^ (STONJSON fromString: response) at: 'models'  .
]

{ #category : 'instance creation' }
OllamaApi class >> newModel: modelNumber [
	"make an instance of OllamaApi based on a specfic Ollama model installed"
	| selectedModel |
	selectedModel := self modelNames 
		at: modelNumber 
		ifAbsent: [ self modelNames at: 5 ]. "Select the first one"
	^ self new model: selectedModel 
]

{ #category : 'AI models' }
OllamaApi class >> ollamaVersion [
	"Retrieve the Ollama version"
	| response  |
	
	response := ZnClient new get: 'http://localhost:11434/api/version'.
	^ (STONJSON fromString: response) at: 'version'  .
]

{ #category : 'ollama models' }
OllamaApi >> bodyForEntityWithPrompt [
	"Returns the body of an entity with a given prompt by sending a POST request to the Ollama API."
	|  requestDictionary |
	requestDictionary := Dictionary newFrom:  { 
		'model' -> model.
		'messages' -> self jsonHistory .
		#stream -> false.
		#options -> (Dictionary newFrom: {
    		#temperature -> 0})
	} .
	^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'initialization' }
OllamaApi >> initialize [

	super initialize.
	self model: self class defaultModel
]

{ #category : 'ollama models' }
OllamaApi >> loadResponse [ 
	"Send POST request to Ollama API to retrieve response content from parsed JSON."
	| apiGenerateUrl jsonResponse |
	apiGenerateUrl := 'http://localhost:11434/api/chat'.
	[  jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	    entity: self bodyForEntityWithPrompt;
	    post;
	    contents.
		self assistant: (self responseOf: jsonResponse) .
	] on: Error do: [ :ex |
   		self assistant: ex messageText.
	].
]

{ #category : 'ollama models' }
OllamaApi >> modelInformation [
	"Returns detailed information about the current model by querying the Ollama API and parsing the JSON response."
	| url jsonResponse requestBody |
	url := 'http://localhost:11434/api/show'.

	requestBody := STONJSON toString: { 
		#model -> model.
	} asDictionary.
	jsonResponse := ZnClient new
	    url: url;
	    entity: (ZnEntity with: requestBody);
	    post;
	    contents.
	^ (STONJSON fromString: jsonResponse) contents.
]

{ #category : 'ollama models' }
OllamaApi >> modelShortInfo [	
	"Returns a dictionary with the model's name, architecture, parameter count in billions, and context length."
	| info architecture parameters context_length |
	info := self modelInformation at: 'model_info'.
	architecture := info at: 'general.architecture'.
	parameters := ((info keys 
		select: [ :k | k endsWith: '.parameter_count' ]
		thenCollect: [ :k | info at: k ]) first asFloat / 1e9) roundTo: 0.1.
	context_length := (info keys 
		select: [ :k | k endsWith: '.context_length' ]
		thenCollect: [ :k | info at: k ]) first.
	^ { 'Model' -> model.  
		'Architecture' -> architecture. 
		'Parameter count' -> parameters. 
		'Context length' -> context_length}
]

{ #category : 'initialization' }
OllamaApi >> old_initialize [ 
	super initialize.
	self model: (self class modelNames) third .
]

{ #category : 'printing' }
OllamaApi >> printOn: string [
	"Prints the model name of OllamaModelsApi instance"
	string << 'OllamaModelsApi: ' << self model.
]

{ #category : 'mistral models' }
OllamaApi >> responseOf: jsonResponse [
	"Returns the content of the message from parsed JSON response extracting the actual response text from Ollama API nested structure"
	| parsed message  |
	parsed := STONJSON fromString: jsonResponse.
	message := parsed at: 'message'.
	^ message at: 'content' 
]
