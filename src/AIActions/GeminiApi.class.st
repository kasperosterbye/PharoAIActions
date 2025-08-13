Class {
	#name : 'GeminiApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
GeminiApi class >> geminiKey [
	^ (FileSystem disk workingDirectory / '../../geminicode.txt')
		readStream contents trimBoth.
]

{ #category : 'ollama models' }
GeminiApi >> bodyForEntityWithPrompt [

	| requestDictionary |
	requestDictionary :=Dictionary newFrom: {
		'contents' -> self jsonHistory.
		'generationConfig' -> (Dictionary newFrom: {
			'temperature' -> 0
		})
	}.
	^ ZnEntity json: (STONJSON toString: requestDictionary)
]

{ #category : 'initialization' }
GeminiApi >> initialize [ 
	"Initialises the MistralApi instance with the latest model."
	super initialize.
	self model: 'gemini-2.0-flash'.
]

{ #category : 'accessing' }
GeminiApi >> jsonHistory [
	"Transforms the message history into a JSON format suitable for the Gemini API, structuring roles and text parts."
	| jsonHistory geminiHistry|
	jsonHistory := OrderedCollection new.
	self system 
		ifNil: [ 
			geminiHistry := history ] 
		ifNotNil: [ 
			geminiHistry := history deepCopy allButFirst.
			geminiHistry first value: (history first value, '. ', history second value)] .
	geminiHistry do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'parts' -> {Dictionary newFrom: {  'text' -> item value} } } )
	].
	^ jsonHistory asArray.
]

{ #category : 'mistral models' }
GeminiApi >> loadResponse [ 
	| apiGenerateUrl jsonResponse bodyEntity |
	
	apiGenerateUrl := 'https://generativelanguage.googleapis.com/v1beta/models/', model, ':generateContent'.
	[ bodyEntity := self bodyForEntityWithPrompt.
		jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	    headerAt: 'X-goog-api-key' put: self class geminiKey;
	    headerAt: 'Content-Type' put: 'application/json';
	    entity: bodyEntity;
	    post;
	    contents.
		self assistant: (self responseOf: jsonResponse) .
	] on: Error do: [ :ex |
   		self assistant: ex messageText.
	].
]

{ #category : 'accessing' }
GeminiApi >> printOn: aStream [
	aStream << 'GeminiApi: ' << self model.
]

{ #category : 'accessing' }
GeminiApi >> responseOf: jsonResponse [
	"Parses the JSON response from the Gemini API and extracts the text content from the first candidate's content part."
	| parsed message  |
	parsed := STONJSON fromString: jsonResponse.
	message := (parsed at: 'candidates') first at: 'content'.	
	^  (message at: 'parts' ) first at: 'text' 
]
