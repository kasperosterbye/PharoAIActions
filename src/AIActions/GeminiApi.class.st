"
GeminiApi provides an interface to interact with the Gemini AI models for generating content and transcribing audio from YouTube videos.
"
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
GeminiApi class >> modelNamesAndReasoning [
	"Look at https://ai.google.dev/gemini-api/docs/models to see the list"

	^ {
		'gemini-2.5-flash' -> #().
		'gemini-3.5-flash' -> #().
		'gemini-3.7-flash' -> #().
		'gemini-3.8-flash' -> #(). }
]

{ #category : 'accessing' }
GeminiApi class >> transcribeYouTube: aUrl [
	"GeminiApi transcribeYouTube: 'https://www.youtube.com/watch?v=x1ESqB7M9To'"
	| body response modelName |
	modelName := self modelNames first.
	body := Dictionary with: 'contents' -> {
		Dictionary with: 'parts' -> {
			Dictionary with: 'file_data' -> (Dictionary with: 'file_uri' -> aUrl).
			Dictionary with: 'text' -> 'Transcribe the spoken words of this video verbatim, in English. No timestamps, no commentary.' } }.
	response := ZnClient new
		url: 'https://generativelanguage.googleapis.com/v1beta/models/' , modelName , ':generateContent';
		headerAt: 'x-goog-api-key' put: self geminiKey;
		entity: (ZnEntity json: (STONJSON toString: body));
		timeout: 600;
		post.
	^ ((((STONJSON fromString: response) at: 'candidates') first at: 'content') at: 'parts') first at: 'text'
]

{ #category : 'AI models' }
GeminiApi class >> znClientHeaders: jsonPrompt [

	jsonPrompt
		headerAt: 'Authorization' put: 'Bearer ', self geminiKey;
		headerAt: 'Content-Type' put: 'application/json'.
]
