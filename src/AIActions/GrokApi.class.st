Class {
	#name : 'GrokApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
GrokApi class >> apiGenerateUrl [ 
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

	jsonPrompt
		headerAt: 'Authorization' put: 'Bearer ' , self grokKey;
		headerAt: 'Content-Type' put: 'application/json'.
]
