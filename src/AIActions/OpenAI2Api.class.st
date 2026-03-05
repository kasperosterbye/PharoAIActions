Class {
	#name : 'OpenAI2Api',
	#superclass : 'AilienApiWithTools',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
OpenAI2Api class >> apiGenerateUrl [
	"Method to generate the API URL for OpenAIApi."
    ^ 'https://api.openai.com/v1/chat/completions'
]

{ #category : 'accessing' }
OpenAI2Api class >> modelNames [
	"returns an array with one item per model."
	"Look at https://platform.openai.com/docs/models to see the list"
	
	^ #('gpt-5.2-2025-12-11' 'gpt-5.1' 'gpt-5.3-codex'  'gpt-5-mini' )
]

{ #category : 'accessing' }
OpenAI2Api class >> openAI01 [
	"Method to read and trim the contents of a file named Eva01.txt."
	^ (FileSystem disk workingDirectory / '../../Eva01.txt')
		readStream contents trimBoth.
]

{ #category : 'accessing' }
OpenAI2Api class >> znClientHeaders: jsonPrompt [
	jsonPrompt
		headerAt: 'Authorization' put: self openAI01;
		headerAt: 'OpenAI-Organization' put: 'org-XmWYpGR0EsRqkASrs8HE3hy6';
		headerAt: 'OpenAI-Project' put: 'proj_2QRIZLNVevImlaU0bMVzafGt';
		headerAt: 'Content-Type' put: 'application/json'.
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
OpenAI2Api >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item | self addJsonHistory: jsonHistory for: item ].
    ^ jsonHistory asArray
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
OpenAI2Api >> printOn: aStream [
	aStream << 'OpenAI2Api: ' << self model.
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
OpenAI2Api >> znClientEntity [
	^ super znClientEntity ,  {
        'tools' -> self toolSpecification.
    } .
]
