"
TogetherApi is a subclass of AilienApi that provides an interface to the Together AI API. 
It is used to generate text based on a given prompt and conversation history.

#### Usage Example
```st
| api prompt response |
api := TogetherApi new.
prompt := 'Hello, how are you?' .
api history add: {'role' -> 'user'. 'content' -> prompt}.
response := api loadResponse.
api history add: {'role' -> 'assistant'. 'content' -> response}.
api history inspect.
```
This example demonstrates how to create a new instance of TogetherApi, 
add a user prompt to the conversation history, 
load a response from the API, 
and then add the response to the conversation history.
"
Class {
	#name : 'TogetherApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'AI models' }
TogetherApi class >> modelNames [
   "Returns an array of available Together models. Check https://api.together.ai/models for updates."
	"Account area: https://api.together.ai/settings/api-keys"
    ^ #( 	'meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8'
			'nvidia/NVIDIA-Nemotron-Nano-9B-v2'
			'Qwen/Qwen3-235B-A22B-Thinking-2507'
			'deepseek-ai/DeepSeek-V3.1').
]

{ #category : 'AI models' }
TogetherApi class >> togetherKey [
	"Returns the Together API key from a local file together txt"
    ^ (FileSystem disk workingDirectory / '../../together01.txt') readStream contents trimBoth.
]

{ #category : 'accessing' }
TogetherApi >> apiGenerateUrl [ 
	"Returns the URL for Together API chat completions endpoint."
	^ 'https://api.together.xyz/v1/chat/completions'.
    
]

{ #category : 'ollama models' }
TogetherApi >> bodyForEntityWithPrompt [
	"Creates a json entity for the Together API request with model and conversation history."
    | requestDictionary |
    requestDictionary := Dictionary newFrom: {
        'model' -> self model.
        'messages' -> self jsonHistory.
        'max_tokens' -> 1024.
        'temperature' -> 0.0.
        'stream' -> false.
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'accessing' }
TogetherApi >> headers: jsonResponse [
	"Sets headers for Together API request with auth key and content type as json"

	jsonResponse
            headerAt: 'Authorization' put: ('Bearer ', self class togetherKey );
            headerAt: 'Content-Type' put: 'application/json'.
	^ jsonResponse 
]

{ #category : 'initialization' }
TogetherApi >> initialize [
	"Initialises TogetherApi with default model and empty history for AI interactions."
    super initialize.
    self model: self class defaultModel.
]

{ #category : 'ollama models' }
TogetherApi >> printOn: aStream [
	"Prints a representation of the Together API instance showing its model."
    aStream << 'TogetherApi: ' << self model.
]

{ #category : 'ollama models' }
TogetherApi >> responseOf: jsonResponse [
	"Processes JSON response from Together API and extracts content from first choice message handling potential errors during parsing."
    | parsed |
    parsed := STONJSON fromString: jsonResponse.
    [ ^ ((parsed at: 'choices') first at: 'message') at: 'content' ]
        on: Error
        do: [ ^ self errorResponse: jsonResponse ].
]
