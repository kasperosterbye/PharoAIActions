"
# Class: GrokApi

A `GrokApi` is a subclass of `AilienApi` designed to interact with the Grok AI API. It provides methods to generate responses, manage conversation history, and handle API interactions specific to Grok.

## Usage Example

```st
| grokApi |
grokApi := GrokApi new.
grokApi model: 'grok-code-fast-1'.
grokApi messageList: {('role' -> 'user'). ('content' -> 'Explain the concept of recursion in programming.')}.
grokApi loadResponse: 'https://api.x.ai/v1/chat/completions'.
grokApi history inspect.
```

## Design Decisions

- **Scripting**: The class is designed to be used interactively in the Playground.
- **Class Builder**: The class builder offers methods to build and install classes without modifying existing objects.
- **Fluid Syntax**: The class supports fluid syntax for building classes, enhancing readability and usability.
- **API Alignment**: Future revisions aim to align the API with class default values and reduce unnecessary conversions.

## Methods

- `apiGenerateUrl`: Returns the base URL for the Grok API endpoint for generating responses.
- `grokKey`: Returns the API key for Grok, read from a local file.
- `modelNames`: Returns an array of available Grok models.
- `znClientHeaders:`: Sets the headers for the HTTP request to the Grok API, including the authorization token and content type.

## Superclass Methods

- `apiGenerateUrl`: Returns the URL endpoint for the AI provider's API.
- `toolSpecification`: Returns a collection of tool specifications for all registered API tool subclasses.
- `messageList:`: Sets the message list for the API interaction.
- `initialize`: Initializes a new instance with empty model and history.
- `addJsonHistory:for:`: Adds a message to the JSON history based on its role and content.
- `loadResponse:`: Loads the response from the API.
- `responseError:hist:`: Handles API error responses.
- `znClientEntity`: Creates a JSON body with the prompt for the Grok API.
- `responseWaitingInSecs`: Returns the timeout duration in seconds for waiting for an AI response.
- `responseWaitingInSecs:`: Sets the timeout duration in seconds for waiting for an AI response.
- `model`: Returns the current model name used for AI interactions.
- `model:`: Sets the model for AI interactions.
- `errorResponse:`: Returns the error response string.
- `jsonHistory`: Returns the JSON history of the conversation.

## Class Methods

- `provider:`: Sets the provider for the API.
- `modelNames`: Returns a collection of available model names for the AI provider.
- `defaultModel`: Returns the default model for the API provider.
- `providerAndModels`: Returns all providers with their available models.
- `newOnModel:`: Creates a new instance of the API on the specified model.
- `defaultModel:`: Sets the default AI model for the API provider.
- `providers`: Returns the list of providers.
- `lastHistory`: Returns the last history of the conversation.
- `initialize`: Initializes the class.
- `noOfModels`: Returns the number of available models.
- `errorResponse:`: Sets the error response string.
- `background01`: Placeholder for background tasks.
- `playground01`: Placeholder for playground tasks.
- `info`: Returns a descriptive string combining the current AI provider name and its default model name.
"
Class {
	#name : 'GrokApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
GrokApi class >> apiGenerateUrl [ 
	"Returns the base URL for the Grok API endpoint for generating responses"
	^ 'https://api.x.ai/v1/chat/completions'.
    
]

{ #category : 'accessing' }
GrokApi class >> grokKey [
    "Returns the API key for Grok, read from a local file (Bearer token)."
    ^ (FileSystem disk workingDirectory / '../../grokcode00.txt') readStream contents trimBoth.
]

{ #category : 'accessing' }
GrokApi class >> modelNames [
   "Returns an array of available Grok models. Check https://docs.x.ai/ for updates."
	"https://console.x.ai/team/5e551e89-6f2d-49bc-88ba-edd9b27ae732/models/grok-code-fast-1"
    ^ #('grok-code-fast-1' 'grok-4-1-fast-reasoning' 'grok-4-1-fast-non-reasoning' 'grok-3-mini').
]

{ #category : 'accessing' }
GrokApi class >> znClientHeaders: jsonPrompt [
	"Sets the headers for the HTTP request to the Grok API, including the authorization token and content type"

	jsonPrompt
		headerAt: 'Authorization' put: 'Bearer ' , self grokKey;
		headerAt: 'Content-Type' put: 'application/json'.
]
