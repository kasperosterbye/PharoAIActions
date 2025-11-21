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
	
	^ #('gpt-5.1'  'gpt-5-mini' 'gpt-5-nano' 'gpt-4.1-nano') 
]

{ #category : 'accessing' }
OpenAIApi class >> openAI01 [
	"Method to read and trim the contents of a file named Eva01.txt."
	^ (FileSystem disk workingDirectory / '../../Eva01.txt')
		readStream contents trimBoth.
]

{ #category : 'accessing' }
OpenAIApi >> apiGenerateUrl [
	"Method to generate the API URL for OpenAIApi."
    ^ 'https://api.openai.com/v1/chat/completions'
]

{ #category : 'mistral models' }
OpenAIApi >> bodyForEntityWithPrompt [
	"Method to create a JSON body with prompt for OpenAIApi."
    | requestDictionary |
    requestDictionary := Dictionary newFrom: {
        'model' -> model.
        'messages' -> self jsonHistory.
        'stream' -> false.
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'accessing' }
OpenAIApi >> headers: jsonResponse [
	"Method to set headers for OpenAIApi request."

	jsonResponse
			headerAt: 'Authorization' put: self class openAI01;
			headerAt: 'OpenAI-Organization' put: 'org-XmWYpGR0EsRqkASrs8HE3hy6';
			headerAt: 'OpenAI-Project' put: 'proj_2QRIZLNVevImlaU0bMVzafGt';
			headerAt: 'Content-Type' put: 'application/json'.
	^ jsonResponse 
]

{ #category : 'initialization' }
OpenAIApi >> initialize [ 
	"Initialises the OpenAI API instance by calling superclass initialiser and setting default model for AI interactions"
	 super initialize.
    self model: self class defaultModel .
]

{ #category : 'printing' }
OpenAIApi >> printOn: aStream [
	"Method to print the model name of OpenAIApi instance."
	aStream << 'OpenAIApi: ' << self model.
]

{ #category : 'mistral models' }
OpenAIApi >> responseOf: jsonResponse [
	"Method to parse JSON response and extract content, handling errors gracefully."
	| parsed   |
	parsed := STONJSON fromString: jsonResponse.
	[^ ((parsed at: 'choices') first at: 'message') at: 'content' ]
		on: Error 
		do: [ ^ self errorResponse: jsonResponse  ].
]
