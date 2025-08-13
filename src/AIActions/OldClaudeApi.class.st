Class {
	#name : 'OldClaudeApi',
	#superclass : 'OldAilienApi',
	#instVars : [
		'messagePart'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
OldClaudeApi class >> claudeKey [
	^ (FileSystem disk workingDirectory / '../../claudecode.txt')
		readStream contents trimBoth.
]

{ #category : 'accessing' }
OldClaudeApi >> bodyForEntityWithPrompt [
    "Creates a JSON entity for Claude API request with model, max tokens, system prompt, messages, and temperature settings."
    | requestDictionary messages |
    
    "Use messagePart if available, otherwise create simple user message"
    messages := messagePart 
        ifNil: [ { Dictionary newFrom: { 'role' -> 'user'. 'content' -> prompt } } ]
        ifNotNil: [ 
            "Filter out system messages - Claude handles system separately"
            messagePart select: [ :msg | (msg at: 'role') ~= 'system' ]
        ].
    
    requestDictionary := Dictionary newFrom: {
        'model' -> model.
        'max_tokens' -> 1024.
        'system' -> system.
        'messages' -> messages.
        'temperature' -> 0
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'accessing' }
OldClaudeApi >> initialize [ 
	"Initialises the MistralApi instance with the latest model."
	super initialize.
	self model: 'claude-3-5-sonnet-20241022'.
]

{ #category : 'accessing' }
OldClaudeApi >> loadResponse [ 
	| apiGenerateUrl jsonResponse bodyEntity |
	apiGenerateUrl := 'https://api.anthropic.com/v1/messages'.
	[  bodyEntity := self bodyForEntityWithPrompt.
		jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	    headerAt: 'x-api-key' put: self class claudeKey;
	    headerAt: 'anthropic-version' put: '2023-06-01';
	    headerAt: 'content-type' put: 'application/json';
	    entity: bodyEntity;
	    post;
	    contents.
		response := self responseOf: jsonResponse .
	] on: Error do: [ :ex |
   		response := ex messageText.
	].
]

{ #category : 'accessing' }
OldClaudeApi >> messagePart [
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
OldClaudeApi >> messagePart: message [
	messagePart := message
]

{ #category : 'accessing' }
OldClaudeApi >> old_bodyForEntityWithPrompt [
	"Creates a JSON entity for Claude API request with model, max tokens, system prompt, user message, and temperature settings."
	| requestDictionary |
	requestDictionary := Dictionary newFrom: {
	    'model' -> model.
	    'max_tokens' -> 1024.
	    'system' -> system.
	    'messages' -> { 
	        Dictionary newFrom: {
	            'role' -> 'user'.
	            'content' -> prompt
	        }
	    }.
	    'temperature' -> 0
	}.
	^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'accessing' }
OldClaudeApi >> printOn: aStream [
	aStream << 'ClaudeApi: ' << self model.
]

{ #category : 'accessing' }
OldClaudeApi >> responseOf: jsonResponse [
	"Returns the text content from the parsed Claude API JSON response by extracting the text field from the first content element in the response dictionary"
	| parsed |
	parsed := STONJSON fromString: jsonResponse.
	^ (parsed at: 'content') first at: 'text'
]
