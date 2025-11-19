"
# Class: OllamaApi

A client interface for interacting with the Ollama API, enabling communication with large language models. This class extends `AilienApi` to provide Ollama-specific functionality, including model management, conversation history handling, and response generation.

## Key Features

- **Model Interaction**: Connects to Ollama's local API to generate responses from specified models
- **Conversation Management**: Maintains and formats chat history for context-aware interactions
- **Model Information**: Retrieves detailed metadata about available models
- **Error Handling**: Gracefully handles API communication errors

## Usage Example

```smalltalk
""Create and configure an Ollama API instance""
ollama := OllamaApi newModel: 1.  ""Selects the first available model""
ollama system: 'You are a helpful assistant'.  ""Set system context""
ollama user: 'Explain quantum computing in simple terms'.  ""Add user prompt""
ollama getResponse.  ""Generate and store response""
ollama response  ""Inspect the assistant's response""
```

## API Methods

- `responseOf:` - Extracts response content from JSON API responses
- `bodyForEntityWithPrompt` - Prepares request bodies for API calls
- `modelInformation` - Retrieves detailed model metadata
- `modelShortInfo` - Provides concise model specifications

## Class Methods

- `models` - Lists all available Ollama models
- `ollamaVersion` - Retrieves the installed Ollama version
- `newModel:` - Creates an instance for a specific model
- `modelNames` - Returns names of all available models

The class maintains conversation history and handles the complete lifecycle of API interactions with Ollama's local server.
```

This comment provides a comprehensive overview of the class's purpose, key features, and usage patterns while maintaining the British English style requested. The example demonstrates the complete workflow from instance creation to response retrieval, ending with an expression suitable for inspection in Pharo's Playground.
"
Class {
	#name : 'OllamaApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
OllamaApi class >> exampleUllama [
	"(AIAHistory new api: (OllamaApi newModel: 1)) user: 'What is your name'; getResponse ; response. "
]

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
		ifAbsent: [ self modelNames at: 1 ]. "Select the first one"
	^ self new model: selectedModel 
]

{ #category : 'AI models' }
OllamaApi class >> ollamaVersion [
	"Retrieve the Ollama version"
	| response  |
	
	response := ZnClient new get: 'http://localhost:11434/api/version'.
	^ (STONJSON fromString: response) at: 'version'  .
]

{ #category : 'accessing' }
OllamaApi >> apiGenerateUrl [ 
	^ 'http://localhost:11434/api/chat'.
	
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

{ #category : 'accessing' }
OllamaApi >> headers: jsonResponse [

	^ jsonResponse 
]

{ #category : 'initialization' }
OllamaApi >> initialize [
	"Initializes an OllamaApi instance with default model and empty conversation history ready for API interactions"

	super initialize.
	self model: self class defaultModel
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

{ #category : 'printing' }
OllamaApi >> printOn: string [
	"Prints the model name of OllamaModelsApi instance"
	string << 'OllamaApi: ' << self model.
]

{ #category : 'mistral models' }
OllamaApi >> responseOf: jsonResponse [
	"Returns the content of the message from parsed JSON response extracting the actual response text from Ollama API nested structure"
	| parsed message  |
	parsed := STONJSON fromString: jsonResponse.
	[message := parsed at: 'message'.
	^ message at: 'content' ]
		on: Error 
		do: [ ^ self errorResponse: jsonResponse  ].
		
]
