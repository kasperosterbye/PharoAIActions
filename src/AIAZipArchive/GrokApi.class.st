"
# Class comment for GrokApi

GrokApi provides an interface to interact with the Grok AI models via their API. It handles authentication, request formatting, and response processing for Grok's language models.

## Key Features:
- Connects to Grok's API endpoints
- Manages conversation history
- Supports multiple Grok models (e.g., 'grok-code-fast-1')
- Handles JSON request/response formatting

## Example Usage:
```smalltalk
| grok |
grok := GrokApi new.
grok model: 'grok-code-fast-1'.
grok messageList: {('user' -> 'Explain quantum computing').}.
grok loadResponse.
grok responseOf: grok lastResponse.
```
"
Class {
	#name : 'GrokApi',
	#superclass : 'Ailien0Api',
	#category : 'AIAZipArchive-AIApiArhive',
	#package : 'AIAZipArchive',
	#tag : 'AIApiArhive'
}

{ #category : 'accessing' }
GrokApi class >> apiGenerateUrl [ 
	^ 'https://api.x.ai/v1/chat/completions'.
    
]

{ #category : 'AI models' }
GrokApi class >> grokKey [
    "Returns the API key for Grok, read from a local file (Bearer token)."
    ^ (FileSystem disk workingDirectory / '../../grokcode00.txt') readStream contents trimBoth.
]

{ #category : 'AI models' }
GrokApi class >> modelNames [
   "Returns an array of available Grok models. Check https://docs.x.ai/ for updates."
	"https://console.x.ai/team/5e551e89-6f2d-49bc-88ba-edd9b27ae732/models/grok-code-fast-1"
    ^ #('grok-code-fast-1' 'grok-4-1-fast-reasoning' 'grok-4-1-fast-non-reasoning' 'grok-3-mini').
]

{ #category : 'accessing' }
GrokApi class >> znClientHeaders: jsonPrompt [

	jsonPrompt
		headerAt: 'Authorization' put: 'Bearer ' , self grokKey;
		headerAt: 'Content-Type' put: 'application/json'.
]
