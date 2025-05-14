"
# Class Comment for `OllamaApi`

The `OllamaApi` class is designed to interact with the Ollama API, providing a convenient interface for sending prompts and retrieving responses from various language models. This class encapsulates the necessary details for configuring and sending requests to the Ollama API, including model selection, system prompts, and response handling.

## Key Features

- **Model Selection**: Allows the selection of different language models available through the Ollama API.
- **System and Prompt Prefix**: Supports the configuration of system prompts and prefix text to guide the model's responses.
- **Response Handling**: Manages the sending of prompts and the retrieval of responses, including error handling for network issues or API errors.
- **Model Information**: Provides detailed and short information about the selected model, including architecture, parameter count, and context length.
- **Initialization**: Initializes the class with default values for model, system prompt, and prompt prefix.

## Usage

To use the `OllamaApi` class, you can create an instance and configure it with the desired model, system prompt, and prompt prefix. You can then send prompts to the API and retrieve responses. The class also provides methods to retrieve detailed information about the selected model.

## Example

```smalltalk
| api response |
api := OllamaApi new.
api model: 'example-model'.
api system: 'You are a helpful assistant.'.
api promptPrefix: 'Please answer the following question:'.
response := api getResponseForPrompt: 'What is the capital of France?'.
Transcript show: response; cr.
```

## Methods

- **Accessing**: Methods to get and set the model, system prompt, prompt prefix, and response.
- **Initialization**: Method to initialize the class with default values.
- **Ollama Models**: Methods to send prompts to the API, retrieve model information, and get short model information.
- **Printing**: Method to print the class and its model.

## Class Methods

- **Instance Creation**: Methods to create instances of `OllamaApi` with specific models, system prompts, and prompt prefixes.
- **Ollama Models**: Methods to retrieve the list of available models and the Ollama version.

## Dependencies

- **ZnClient**: Used for making HTTP requests to the Ollama API.
- **STONJSON**: Used for parsing JSON responses from the API.

This class is part of the `AI-ChatPharo` package and is tagged with 'Ollama'.
"
Class {
	#name : 'OllamaModelsApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'ollama models' }
OllamaModelsApi class >> modelNames [
	"returns an array with one item per model."
	^ self models collect: [ :ollamaModel | ollamaModel at: 'name' ]
]

{ #category : 'ollama models' }
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

{ #category : 'ollama models' }
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
