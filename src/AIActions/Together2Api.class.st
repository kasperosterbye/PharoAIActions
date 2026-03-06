Class {
	#name : 'Together2Api',
	#superclass : 'AilienApiWithTools',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
Together2Api class >> apiGenerateUrl [ 
	"Returns the URL for Together API chat completions endpoint."
	^ 'https://api.together.xyz/v1/chat/completions'.
    
]

{ #category : 'accessing' }
Together2Api class >> modelNames [
   "Returns an array of available Together models. "
	"Check https://api.together.ai/models (use GitHub at login) for updates."
	"Account area: https://api.together.ai/settings/api-keys"
    ^ #( 	'Qwen/Qwen3-Next-80B-A3B-Instruct'
			'Qwen/Qwen3-235B-A22B-Thinking-2507'
			'deepseek-ai/DeepSeek-V3.1'
			'meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8').
]

{ #category : 'accessing' }
Together2Api class >> togetherKey [
	"Returns the Together API key from a local file together txt"
    ^ (FileSystem disk workingDirectory / '../../together01.txt') readStream contents trimBoth.
]

{ #category : 'accessing' }
Together2Api class >> znClientHeaders: jsonPrompt [

	jsonPrompt
		headerAt: 'Authorization' put: 'Bearer ' , self togetherKey;
		headerAt: 'Content-Type' put: 'application/json'.
]
