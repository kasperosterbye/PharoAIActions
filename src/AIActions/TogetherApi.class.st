"
# Class: TogetherApi

A `TogetherApi` is a subclass of `AilienApi` designed to interact with the Together AI API. It provides methods to configure and execute chat completions using various AI models. The class handles the setup of API headers, manages conversation history, and processes responses from the Together AI service.

## Usage Example

```st
""Create an instance of TogetherApi and set the model""
api := TogetherApi new.
api model: 'Qwen/Qwen3-Next-80B-A3B-Instruct'.

""Add a message to the conversation history""
api messageList: { 'user' -> 'Hello, how are you?' }.

""Generate a response from the AI""
response := api loadResponse.

""Inspect the response""
response inspect.
```

This example demonstrates how to create an instance of `TogetherApi`, set the desired AI model, add a message to the conversation history, and generate a response from the AI. The response is then inspected to view the details.
"
Class {
	#name : 'TogetherApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
TogetherApi class >> apiGenerateUrl [ 
	"Returns the URL for Together API chat completions endpoint."
	^ 'https://api.together.xyz/v1/chat/completions'.
    
]

{ #category : 'accessing' }
TogetherApi class >> modelNames [
   "Returns an array of available Together models. "
	"Check https://api.together.ai/models (use GitHub at login) for updates."
	"Account area: https://api.together.ai/settings/api-keys"
    ^ #( 	'Qwen/Qwen3-Coder-Next-FP8'
			'Qwen/Qwen3-Coder-480B-A35B-Instruct-FP8'
			'deepseek-ai/DeepSeek-V3.1'
			'deepseek-ai/DeepSeek-V4-Pro'
			'openai/gpt-oss-120b'
			'meta-llama/Llama-3.3-70B-Instruct-Turbo' ).
]

{ #category : 'accessing' }
TogetherApi class >> togetherKey [
	"Returns the Together API key from a local file together txt"
    ^ (FileSystem disk workingDirectory / '../../together01.txt') readStream contents trimBoth.
]

{ #category : 'accessing' }
TogetherApi class >> znClientHeaders: jsonPrompt [
	"Sets the headers for the HTTP request to the Together API, including the authorization token and content type."

	jsonPrompt
		headerAt: 'Authorization' put: 'Bearer ' , self togetherKey;
		headerAt: 'Content-Type' put: 'application/json'.
]
