Class {
	#name : 'OllamaModelsApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'AI models' }
OllamaModelsApi class >> modelNames [
	"returns an array with one item per model."
	^ self models collect: [ :ollamaModel | ollamaModel at: 'name' ]
]

{ #category : 'AI models' }
OllamaModelsApi class >> models [
	"returns an array with one item per model. Each item has nested informations, and some arrays"
	| response  |

	response := ZnClient new get: 'http://localhost:11434/api/tags'.
	^ (STONJSON fromString: response) at: 'models'  .
]

{ #category : 'instance creation' }
OllamaModelsApi class >> newModel: modelNumber [
	"make an instance of OllamaApi based on a specfic Ollama model installed"
	| selectedModel |
	
	selectedModel := self modelNames 
		at: modelNumber 
		ifAbsent: [ self modelNames at: 1 ]. "Select the first one"
	^ self new model: selectedModel 
]

{ #category : 'instance creation' }
OllamaModelsApi class >> newSystem: synstemText promptPrefix: promptPrefixText [
	"Create and return an instance with predefined system and prompt prefix for Ollama queries."
	| prompter |
	prompter := self new.
	prompter system: synstemText.
	prompter promptPrefix: promptPrefixText.
	^ prompter 
]

{ #category : 'AI models' }
OllamaModelsApi class >> ollamaVersion [
	"Retrieve the Ollama version"
	| response  |
	
	response := ZnClient new get: 'http://localhost:11434/api/version'.
	^ (STONJSON fromString: response) at: 'version'  .
]

{ #category : 'ollama models' }
OllamaModelsApi >> getResponseForPrompt: prompt [
	"Sends a prompt to an API, receives JSON response, and extracts the 'response' value"
	"Split the method into parts, it is a bit too long now..."
	| apiGenerateUrl jsonResponse requestDictionary requestBody|
	apiGenerateUrl := 'http://localhost:11434/api/generate'.
	requestDictionary := Dictionary newFrom:  { 
		#model -> model.
		#system -> self system.
		#prompt -> (self promptPrefix , ' ', prompt).
		#stream -> false.
		#options -> (Dictionary newFrom: {
    		#temperature -> 0})
	} .
	requestBody := (STONJSON toString: requestDictionary).
	[jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	    entity: (ZnEntity with: requestBody);
		 timeout: (ZnNetworkingUtils defaultSocketStreamTimeout * 5);
	    post;
	    contents.
		self response: ((STONJSON fromString: jsonResponse) at: 'response') contents .
	] on: Error do: [ :ex |
   		self response: ex messageText.
	].
	^ self response.
]

{ #category : 'initialization' }
OllamaModelsApi >> initialize [ 
	super initialize.
	self model: (self class modelNames) first.
	self system: ''.
	self promptPrefix: ''.
]

{ #category : 'ollama models' }
OllamaModelsApi >> modelInformation [
	"Show information about a model including details, modelfile, template, parameters, license, system prompt."
	"Check https://github.com/ollama/ollama/blob/main/docs/api.md#show-model-information for details"
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
	response := (STONJSON fromString: jsonResponse).
	^ response contents.
]

{ #category : 'ollama models' }
OllamaModelsApi >> modelShortInfo [
	"Return a short array of modelName, architecture, parameters, context_length"
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

{ #category : 'printing' }
OllamaModelsApi >> printOn: string [
	string << 'OllamaApi: ' << self model.
]
