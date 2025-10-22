"
# Class Comment for MistralApi

The `MistralApi` class provides an interface to interact with Mistral's AI models, enabling developers to send prompts, receive responses, and utilise tooling capabilities. It extends the `AilienApi` superclass, inheriting core conversation management functionality while specialising in Mistral-specific implementations.

## Key Features

- **Model Interaction**: Supports multiple Mistral models (e.g., 'codestral-latest', 'mistral-small-latest')
- **Tool Integration**: Optional tooling capabilities for enhanced functionality
- **Conversation Management**: Maintains and formats chat history
- **Error Handling**: Robust error management for API responses

## Usage Example

```smalltalk
""Create and configure a Mistral API instance""
mistral := MistralApi new.
mistral model: 'mistral-small-latest'.  ""Set the model""
mistral system: 'You are a helpful assistant'.  ""Set system message""
mistral user: 'Tell me about Pharo'.  ""Add user prompt""
mistral getResponse.  ""Get AI response""
mistral response  ""Inspect the response""
```

## Implementation Notes

- Requires valid API credentials stored in a file
- Handles both standard and tool-enhanced API requests
- Maintains conversation history in chronological order
- Provides formatted output for debugging and display purposes

The class is designed for integration with Pharo's Smalltalk environment, offering a clean interface for AI interactions while handling the complexities of API communication and response processing.
```
"
Class {
	#name : 'OpenAIApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'AI models' }
OpenAIApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://platform.openai.com/docs/models to see the list"
	
	^ #('gpt-4.1'  'gpt-3.5-turbo' 'gpt-4.1-mini' 'gpt-4.1-nano') 
]

{ #category : 'accessing' }
OpenAIApi class >> openAI01 [
	"Return the API token for Mistral, read from a maarumlam https file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ (FileSystem disk workingDirectory / '../../Eva01.txt')
		readStream contents trimBoth.
]

{ #category : 'accessing' }
OpenAIApi >> apiGenerateUrl [
    ^ 'https://api.openai.com/v1/chat/completions'
]

{ #category : 'mistral models' }
OpenAIApi >> bodyForEntityWithPrompt [
    "Creates a JSON request body for Grok API with model, messages, max_tokens, temperature, and no streaming."
    | requestDictionary |
    requestDictionary := Dictionary newFrom: {
        'model' -> model.
        'messages' -> self jsonHistory.
        'max_tokens' -> 1024.
        'temperature' -> 0.0.
        'stream' -> false.
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary).

]

{ #category : 'accessing' }
OpenAIApi >> headers: jsonResponse [

	jsonResponse
			headerAt: 'Authorization' put: self class openAI01;
			headerAt: 'OpenAI-Organization' put: 'org-XmWYpGR0EsRqkASrs8HE3hy6';
			headerAt: 'OpenAI-Project' put: 'proj_2QRIZLNVevImlaU0bMVzafGt';
			headerAt: 'Content-Type' put: 'application/json'.
	^ jsonResponse 
]

{ #category : 'initialization' }
OpenAIApi >> initialize [ 
	"Initialises a new MistralApi instance with default model and tooling enabled, ready for AI interactions. Sets up conversation management and response handling."
    super initialize.
    self model: self class defaultModel .
]

{ #category : 'printing' }
OpenAIApi >> printOn: aStream [
	"Prints the MistralApi instance with its current model name for debugging and logging purposes."
	aStream << 'OpenAIApi: ' << self model.
]

{ #category : 'mistral models' }
OpenAIApi >> responseOf: jsonResponse [
	| parsed   |
	parsed := STONJSON fromString: jsonResponse.
	[^ ((parsed at: 'choices') first at: 'message') at: 'content' ]
		on: Error 
		do: [ ^ 'Error bla bla: ', jsonResponse  ].
]
