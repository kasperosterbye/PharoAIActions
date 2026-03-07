Class {
	#name : 'Mistral3Api',
	#superclass : 'Ailien3Api',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
Mistral3Api class >> apiGenerateUrl [ 
	"Returns the URL for the Mistral AI API endpoint for generating chat completions"
	^ 'https://api.mistral.ai/v1/chat/completions'.
	
]

{ #category : 'accessing' }
Mistral3Api class >> esug [
	"Return the API token for Mistral, read from a maarumlam https file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ ZnClient new url: 'https://maarumlam.dk/pharoCommentsByMistral.txt'; get.
]

{ #category : 'accessing' }
Mistral3Api class >> modelNames [
	"returns an array with one item per model."
	"Look at https://docs.mistral.ai/getting-started/models/models_overview/ to see the list"
	
	^ #('codestral-latest'  'devstral-2512' 'labs-devstral-small-2512' 'mistral-medium-2508') 
]

{ #category : 'accessing' }
Mistral3Api class >> token [
	"Return the API token for Mistral, read from a local file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ (FileSystem disk workingDirectory / '../../mistralcode.txt')
		readStream contents trimBoth.
]

{ #category : 'accessing' }
Mistral3Api class >> znClientHeaders: jsonPrompt [

	jsonPrompt
		headerAt: 'Authorization' put: self esug;
		headerAt: 'Content-Type' put: 'application/json'.
]
