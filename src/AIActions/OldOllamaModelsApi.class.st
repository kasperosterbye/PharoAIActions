Class {
	#name : 'OldOllamaModelsApi',
	#superclass : 'OldAilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'ollama models' }
OldOllamaModelsApi class >> modelNames [
	"returns an array with one item per model."
	^ self models collect: [ :ollamaModel | ollamaModel at: 'name' ]
]

{ #category : 'AI models' }
OldOllamaModelsApi class >> models [
	"returns an array with one item per model. Each item has nested informations, and some arrays"
	| response  |

	response := ZnClient new get: 'http://localhost:11434/api/tags'.
	^ (STONJSON fromString: response) at: 'models'  .
]

{ #category : 'instance creation' }
OldOllamaModelsApi class >> newModel: modelNumber [
	"make an instance of OllamaApi based on a specfic Ollama model installed"
	| selectedModel |
	
	selectedModel := self modelNames 
		at: modelNumber 
		ifAbsent: [ self modelNames at: 1 ]. "Select the first one"
	^ self new model: selectedModel 
]

{ #category : 'instance creation' }
OldOllamaModelsApi class >> newSystem: synstemText promptPrefix: promptPrefixText [
	"Create and return an instance with predefined system and prompt prefix for Ollama queries."
	| prompter |
	prompter := self new.
	prompter system: synstemText.
	prompter promptPrefix: promptPrefixText.
	^ prompter 
]

{ #category : 'AI models' }
OldOllamaModelsApi class >> ollamaVersion [
	"Retrieve the Ollama version"
	| response  |
	
	response := ZnClient new get: 'http://localhost:11434/api/version'.
	^ (STONJSON fromString: response) at: 'version'  .
]

{ #category : 'ollama models' }
OldOllamaModelsApi >> bodyForEntityWithPrompt [
	"Constructs a JSON entity for the API request, including model, system, prompt, and options."
	| apiGenerateUrl  requestDictionary |
	apiGenerateUrl := 'http://localhost:11434/api/generate'.
	requestDictionary := Dictionary newFrom:  { 
		#model -> model.
		#system -> self system.
		#prompt -> self prompt.
		#stream -> false.
		#options -> (Dictionary newFrom: {
    		#temperature -> 0})
	} .
	^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'initialization' }
OldOllamaModelsApi >> initialize [ 
	super initialize.
	self model: (self class modelNames) second.
]

{ #category : 'ollama models' }
OldOllamaModelsApi >> loadResponse [ 
	| apiGenerateUrl jsonResponse |
	apiGenerateUrl := 'http://localhost:11434/api/generate'.
	[  jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	    entity: self bodyForEntityWithPrompt;
	    post;
	    contents.
		response := self responseOf: jsonResponse .
	] on: Error do: [ :ex |
   		response := ex messageText.
	].
]

{ #category : 'ollama models' }
OldOllamaModelsApi >> modelInformation [
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
	response := (STONJSON fromString: jsonResponse).
	^ response contents.
]

{ #category : 'ollama models' }
OldOllamaModelsApi >> modelShortInfo [	
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

{ #category : 'printing' }
OldOllamaModelsApi >> printOn: string [
	"Prints the model name of OllamaModelsApi instance"
	string << 'OllamaModelsApi: ' << self model.
]

{ #category : 'mistral models' }
OldOllamaModelsApi >> responseOf: jsonResponse [
	"Extracts the 'content' from the first 'message' in the 'choices' array of a JSON response."
	^ (STONJSON fromString: jsonResponse) at: 'response'
]
