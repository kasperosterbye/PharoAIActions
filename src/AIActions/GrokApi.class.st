Class {
	#name : 'GrokApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'AI models' }
GrokApi class >> grokKey [
    "Returns the API key for Grok, read from a local file (Bearer token)."
    ^ (FileSystem disk workingDirectory / '../../grokcode00.txt') readStream contents trimBoth.
]

{ #category : 'AI models' }
GrokApi class >> modelNames [
   "Returns an array of available Grok models. Check https://docs.x.ai/ for updates."
	"https://console.x.ai/team/5e551e89-6f2d-49bc-88ba-edd9b27ae732/models/grok-code-fast-1"
    ^ #('grok-code-fast-1' 'grok-4-fast-reasoning' 'grok-4-fast-non-reasoning' 'grok-3-mini').
]

{ #category : 'accessing' }
GrokApi >> apiGenerateUrl [ 
	^ 'https://api.x.ai/v1/chat/completions'.
    
]

{ #category : 'ollama models' }
GrokApi >> bodyForEntityWithPrompt [
    "Creates a JSON request body for Grok API with model, messages, max_tokens, temperature, and no streaming."
    | requestDictionary |
    requestDictionary := Dictionary newFrom: {
        'model' -> self model.
        'messages' -> self jsonHistory.
        'temperature' -> 0.0.
        'stream' -> false.
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary).

]

{ #category : 'accessing' }
GrokApi >> headers: jsonResponse [

	jsonResponse
            headerAt: 'Authorization' put: ('Bearer ', self class grokKey);
            headerAt: 'Content-Type' put: 'application/json'.
	^ jsonResponse 
]

{ #category : 'initialization' }
GrokApi >> initialize [
    "Initializes the GrokApi instance with the default model."
    super initialize.
    self model: self class defaultModel.

]

{ #category : 'ollama models' }
GrokApi >> printOn: aStream [
    "Prints the model name for the GrokApi instance."
    aStream << 'GrokApi: ' << self model.

]

{ #category : 'ollama models' }
GrokApi >> responseOf: jsonResponse [
    "Extracts the text content from the parsed Grok API JSON response."
    | parsed |
    parsed := STONJSON fromString: jsonResponse.
    [ ^ ((parsed at: 'choices') first at: 'message') at: 'content' ]
        on: Error
        do: [ ^ self errorResponse: jsonResponse ].

]
