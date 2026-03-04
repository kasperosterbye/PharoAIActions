Class {
	#name : 'Ollama2Api',
	#superclass : 'AilienApiWithTools',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
Ollama2Api class >> apiGenerateUrl [ 
	^ 'https://api.x.ai/v1/chat/completions'.
    
]

{ #category : 'accessing' }
Ollama2Api class >> grokKey [
    "Returns the API key for Grok, read from a local file (Bearer token)."
    ^ (FileSystem disk workingDirectory / '../../grokcode00.txt') readStream contents trimBoth.
]

{ #category : 'accessing' }
Ollama2Api class >> modelNames [
   "Returns an array of available Grok models. Check https://docs.x.ai/ for updates."
	"https://console.x.ai/team/5e551e89-6f2d-49bc-88ba-edd9b27ae732/models/grok-code-fast-1"
    ^ #('grok-code-fast-1' 'grok-4-1-fast-reasoning' 'grok-4-1-fast-non-reasoning' 'grok-3-mini').
]

{ #category : 'accessing' }
Ollama2Api class >> znClientHeaders: jsonPrompt [

	jsonPrompt
		headerAt: 'Authorization' put: 'Bearer ' , self grokKey;
		headerAt: 'Content-Type' put: 'application/json'.
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
Ollama2Api >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item | self addJsonHistory: jsonHistory for: item ].
    ^ jsonHistory asArray
]

{ #category : 'responses' }
Ollama2Api >> loadResponse: aHistory [

	self traitLoadResponse: aHistory.
]

{ #category : 'responses' }
Ollama2Api >> printOn: aStream [
	aStream << 'Grok2Api: ' << self model.
]

{ #category : 'responses' }
Ollama2Api >> znClientEntity [
	^ super znClientEntity ,  {
        'tools' -> self toolSpecification.
    } .
]
