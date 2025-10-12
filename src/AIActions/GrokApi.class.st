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

{ #category : 'ollama models' }
GrokApi >> bodyForEntityWithPrompt [
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

{ #category : 'as yet unclassified' }
GrokApi >> computePower: base exponent: exp [
    "Compute base^exp using Pharo's big integer arithmetic."
    ^ base raisedTo: exp
]

{ #category : 'initialization' }
GrokApi >> initialize [
    "Initializes the GrokApi instance with the default model."
    super initialize.
    self model: self class defaultModel.

]

{ #category : 'ollama models' }
GrokApi >> loadResponse [
    "Loads response from Grok API, handling requests, parsing, and errors. Updates assistant message in history."
    | apiGenerateUrl jsonResponse bodyEntity key |
    apiGenerateUrl := 'https://api.x.ai/v1/chat/completions'.
    [ 
        bodyEntity := self bodyForEntityWithPrompt.
        key := self class grokKey.

        jsonResponse := ZnClient new
            url: apiGenerateUrl;
            headerAt: 'Authorization' put: ('Bearer ', key);
            headerAt: 'Content-Type' put: 'application/json';
            entity: bodyEntity;
            post;
            contents.
        self assistant: (self responseOf: jsonResponse)
    ] on: Error do: [ :ex | self assistant: ex messageText ].
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
        do: [ ^ 'Error bla bla: ', jsonResponse ].

]
