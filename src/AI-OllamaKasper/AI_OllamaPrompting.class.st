"
Killroy was here, but went away
"
Class {
	#name : 'AI_OllamaPrompting',
	#superclass : 'Object',
	#instVars : [
		'model',
		'system',
		'promptPrefix',
		'response'
	],
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'instance creation' }
AI_OllamaPrompting class >> newSystem: synstemText promptPrefix: promptPrefixText [
	"Create and return an instance with predefined system and prompt prefix for Ollama queries."
	| prompter |
	prompter := self new.
	prompter system: synstemText.
	prompter promptPrefix: promptPrefixText.
	^ prompter 
]

{ #category : 'ollama models' }
AI_OllamaPrompting class >> ollamaList [
	"Ask ollama for its list of model names, return them"
	| res |
	res := (LibC resultOfCommand: 'ollama list') lines allButFirst.
	^res collect: [:resItem | resItem copyUpToSubstring: ' ' ].
]

{ #category : 'ollama models' }
AI_OllamaPrompting >> getDeepSeekResponseForPrompt: prompt [
    "Sends a prompt to DeepSeek Chat's API and returns the response."
    | url apiKey requestBody jsonResponse |
    
    url := 'https://api.deepseek.com/v1/chat/completions'. "Replace with actual API endpoint if different"
    apiKey := 'your_api_key_here'. "If authentication is required"
    
    "Format the request body for DeepSeek (adjust fields as per their API docs)"
    requestBody := STONJSON toString: {
        #model -> 'deepseek-chat'. "Or the specific model name"
        #messages -> { {
            #role -> 'user'.
            #content -> prompt
        } }.
        #stream -> false
    } asDictionary.
    
    "Send the HTTP request"
    jsonResponse := ZnClient new
        url: url;
        headers: {
            'Content-Type' -> 'application/json'.
            'Authorization' -> ('Bearer ', apiKey) "If auth is needed"
        };
        entity: (ZnEntity with: requestBody);
        post;
        contents.
    
    "Parse the JSON response (adjust key paths as per DeepSeek's response structure)"
    ^ (STONJSON fromString: jsonResponse) at: 'choices' at: 1 at: 'message' at: 'content'.
]

{ #category : 'ollama models' }
AI_OllamaPrompting >> getOllamaModelInformation [
	"Show information about a model including details, modelfile, template, parameters, license, system prompt."
	"Check https://github.com/ollama/ollama/blob/main/docs/api.md#show-model-information for details"
	| url jsonResponse requestBody|
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
AI_OllamaPrompting >> getOllamaModelNames [
	"returns an array with one item per model. Each item has nested informations, and some arrays"
	| url  |
	url := 'http://localhost:11434/api/tags'.
	
	response := ZnClient new get: url.
	^ ((STONJSON fromString: response) at: 'models' )
		 collect: [ :model | model at: 'name' ]
]

{ #category : 'ollama models' }
AI_OllamaPrompting >> getOllamaModels [
	"returns an array with one item per model. Each item has nested informations, and some arrays"
	| url  |
	url := 'http://localhost:11434/api/tags'.
	
	response := ZnClient new get: url.
	^ (STONJSON fromString: response) at: 'models'  .
]

{ #category : 'ollama models' }
AI_OllamaPrompting >> getOllamaVersion [
	"Retrieve the Ollama version"
	| url  |
	url := 'http://localhost:11434/api/version'.
	
	response := ZnClient new get: url.
	^ (STONJSON fromString: response) at: 'version'  .
]

{ #category : 'ollama models' }
AI_OllamaPrompting >> getResonceForPrompt: prompt [
	"Sends a prompt to an API, receives JSON response, and extracts the 'response' value"
	| url jsonResponse requestBody|
	url := 'http://localhost:11434/api/generate'.

	requestBody := STONJSON toString: { 
		#model -> model.
		#system -> system.
		#prompt -> (promptPrefix , ' ', prompt).
		#stream -> false.
	} asDictionary.
	jsonResponse := ZnClient new
	    url: url;
	    entity: (ZnEntity with: requestBody);
	    post;
	    contents.
	response := (STONJSON fromString: jsonResponse) at: 'response'.
	^ response contents.
]

{ #category : 'initialization' }
AI_OllamaPrompting >> initialize [ 
	model := ''.
	system := ''.
	promptPrefix := ''.
]

{ #category : 'accessing' }
AI_OllamaPrompting >> model [
	^ model
]

{ #category : 'accessing' }
AI_OllamaPrompting >> model: aValue [
	model	:=	aValue.
]

{ #category : 'accessing' }
AI_OllamaPrompting >> promptPrefix [
	^ promptPrefix .
]

{ #category : 'accessing' }
AI_OllamaPrompting >> promptPrefix: aValue [
	promptPrefix	:=	aValue.
]

{ #category : 'accessing' }
AI_OllamaPrompting >> response [
	^ response .
]

{ #category : 'accessing' }
AI_OllamaPrompting >> response: aValue [
	response	 :=	aValue.
]

{ #category : 'accessing' }
AI_OllamaPrompting >> system [
	^ system .
]

{ #category : 'accessing' }
AI_OllamaPrompting >> system: aValue [
	system	 :=	aValue.
]
