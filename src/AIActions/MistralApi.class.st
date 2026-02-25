"
Data receive timed out.
"
Class {
	#name : 'MistralApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
MistralApi class >> apiGenerateUrl [ 
	^ 'https://api.mistral.ai/v1/chat/completions'.
	
]

{ #category : 'accessing' }
MistralApi class >> esug [
	"Return the API token for Mistral, read from a maarumlam https file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ ZnClient new url: 'https://maarumlam.dk/pharoCommentsByMistral.txt'; get.
]

{ #category : 'AI models' }
MistralApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://docs.mistral.ai/getting-started/models/models_overview/ to see the list"
	
	^ #('codestral-latest'  'devstral-2512' 'labs-devstral-small-2512' 'mistral-medium-2508') 
]

{ #category : 'accessing' }
MistralApi class >> token [
	"Return the API token for Mistral, read from a local file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ (FileSystem disk workingDirectory / '../../mistralcode.txt')
		readStream contents trimBoth.
]

{ #category : 'accessing' }
MistralApi class >> znClientHeaders: jsonPrompt [

	jsonPrompt
		headerAt: 'Authorization' put: self esug;
		headerAt: 'Content-Type' put: 'application/json'.
]

{ #category : 'initialization' }
MistralApi >> initialize [ 
	"Initialises a new MistralApi instance with default model and tooling enabled, ready for AI interactions. Sets up conversation management and response handling."
    super initialize.
    self model: self class defaultModel .
]

{ #category : 'printing' }
MistralApi >> printOn: aStream [
	"Prints the MistralApi instance with its current model name for debugging and logging purposes."
	aStream << 'MistralApi: ' << self model.
]
