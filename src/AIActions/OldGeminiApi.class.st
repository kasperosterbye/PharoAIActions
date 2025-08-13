Class {
	#name : 'OldGeminiApi',
	#superclass : 'OldAilienApi',
	#instVars : [
		'messagePart'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
OldGeminiApi class >> geminiKey [
	^ (FileSystem disk workingDirectory / '../../geminicode.txt')
		readStream contents trimBoth.
]

{ #category : 'ollama models' }
OldGeminiApi >> bodyForEntityWithPrompt [
    "Creates a JSON entity for Gemini API request with contents format"
    | requestDictionary parts |
    
    "Build parts from messagePart if available, otherwise use system + prompt"
    parts := messagePart 
        ifNil: [ 
            { Dictionary newFrom: { 'text' -> (system, ' ', prompt) } }
        ]
        ifNotNil: [ 
            "Convert history to Gemini format - combine all content"
            | combinedText |
            combinedText := String streamContents: [ :stream |
                messagePart do: [ :msg |
                    stream << (msg at: 'content') << ' '
                ]
            ].
            { Dictionary newFrom: { 'text' -> combinedText trimBoth } }
        ].
    
    requestDictionary := Dictionary newFrom: {
        'contents' -> {
            Dictionary newFrom: {
                'parts' -> parts
            }
        }.
        'generationConfig' -> (Dictionary newFrom: {
            'temperature' -> 0
        })
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'initialization' }
OldGeminiApi >> initialize [ 
	"Initialises the MistralApi instance with the latest model."
	super initialize.
	self model: 'gemini-2.0-flash'.
]

{ #category : 'mistral models' }
OldGeminiApi >> loadResponse [ 
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
OldGeminiApi >> messagePart [
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
OldGeminiApi >> messagePart: message [
	messagePart := message
]

{ #category : 'accessing' }
OldGeminiApi >> printOn: aStream [
	aStream << 'GeminiApi: ' << self model.
]

{ #category : 'accessing' }
OldGeminiApi >> responseOf: jsonResponse [
	"Parses the JSON response from the Gemini API and extracts the text content from the first candidate's content part."
	| parsed message  |
	parsed := STONJSON fromString: jsonResponse.
	message := (parsed at: 'candidates') first at: 'content'.	
	^  (message at: 'parts' ) first at: 'text' 
]
