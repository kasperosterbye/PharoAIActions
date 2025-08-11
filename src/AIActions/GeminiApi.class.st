Class {
	#name : 'GeminiApi',
	#superclass : 'AilienApi',
	#instVars : [
		'messagePart'
	],
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
	"Creates a JSON entity for Gemini API request with contents format"
	| requestDictionary |
	requestDictionary := Dictionary newFrom: {
	    'contents' -> {
	        Dictionary newFrom: {
	            'parts' -> {
	                Dictionary newFrom: {
	                    'text' -> (system, ' ', prompt)
	                }
	            }
	        }
	    }.
	    'generationConfig' -> (Dictionary newFrom: {
	        'temperature' -> 0
	    })
	}.
	^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'initialization' }
GeminiApi >> initialize [ 
	"Initialises the MistralApi instance with the latest model."
	super initialize.
	self model: 'gemini-2.0-flash'.
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
		response := self responseOf: jsonResponse .
	] on: Error do: [ :ex |
   		response := ex messageText.
	].
]

{ #category : 'accessing' }
GeminiApi >> messagePart [
	"Returns the message part for the API request, either from the stored message or creates a new one with system and user roles."
	messagePart 
		ifNil: [ ^ {
				Dictionary newFrom: {
					'role' -> 'system'.
					'content' -> system
				}. 
		      Dictionary newFrom: { 
		         'role' -> 'user'. 
		         'content' -> prompt 
		      }
			}]
		ifNotNil: [ 
			^ messagePart 
		]
]

{ #category : 'accessing' }
GeminiApi >> messagePart: message [
	messagePart := message
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
