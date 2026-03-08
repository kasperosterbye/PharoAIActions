Class {
	#name : 'GeminiApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
GeminiApi class >> apiGenerateUrl [
	"Constructs the specific API endpoint URL for the selected Gemini model to generate content"
	^ 'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions'.
]

{ #category : 'AI models' }
GeminiApi class >> geminiKey [
	^ (FileSystem disk workingDirectory / '../../geminicode.txt')
		readStream contents trimBoth.
]

{ #category : 'AI models' }
GeminiApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://ai.google.dev/gemini-api/docs/models to see the list"
	
	"^ #( 'gemini-2.0-flash' 'gemini-2.0-flash-lite-preview-02-05' 'gemini-1.5-pro' )"
	^ #('gemini-2.5-flash') 
]

{ #category : 'AI models' }
GeminiApi class >> znClientHeaders: jsonPrompt [

	jsonPrompt
		headerAt: 'Authorization' put: 'Bearer ', self geminiKey;
		headerAt: 'Content-Type' put: 'application/json'.
]
