Class {
	#name : 'Mistral2Api',
	#superclass : 'AilienApiWithTools',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
Mistral2Api class >> apiGenerateUrl [ 
	"Returns the URL for the Mistral AI API endpoint for generating chat completions"
	^ 'https://api.mistral.ai/v1/chat/completions'.
	
]

{ #category : 'accessing' }
Mistral2Api class >> esug [
	"Return the API token for Mistral, read from a maarumlam https file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ ZnClient new url: 'https://maarumlam.dk/pharoCommentsByMistral.txt'; get.
]

{ #category : 'accessing' }
Mistral2Api class >> modelNames [
	"returns an array with one item per model."
	"Look at https://docs.mistral.ai/getting-started/models/models_overview/ to see the list"
	
	^ #('codestral-latest'  'devstral-2512' 'labs-devstral-small-2512' 'mistral-medium-2508') 
]

{ #category : 'accessing' }
Mistral2Api class >> token [
	"Return the API token for Mistral, read from a local file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ (FileSystem disk workingDirectory / '../../mistralcode.txt')
		readStream contents trimBoth.
]

{ #category : 'accessing' }
Mistral2Api class >> znClientHeaders: jsonPrompt [

	jsonPrompt
		headerAt: 'Authorization' put: self esug;
		headerAt: 'Content-Type' put: 'application/json'.
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
Mistral2Api >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item | self addJsonHistory: jsonHistory for: item ].
    ^ jsonHistory asArray
]

{ #category : 'responses' }
Mistral2Api >> loadResponse: aHistory [

	self traitLoadResponse: aHistory.
]

{ #category : 'responses' }
Mistral2Api >> printOn: aStream [
	aStream << 'Mistral2Api: ' << self model.
]

{ #category : 'responses' }
Mistral2Api >> znClientEntity [
	^ super znClientEntity ,  {
        'tools' -> self toolSpecification.
    } .
]
