Class {
	#name : 'ClaudeApi',
	#superclass : 'AilienApi',
	#instVars : [
		'messagePart'
	],
	#classInstVars : [
		'lastKeyNumber'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
ClaudeApi class >> claudeKey [
	| fileName |
	lastKeyNumber ifNil: [ lastKeyNumber := 0 ].
	lastKeyNumber := lastKeyNumber + 1.
	lastKeyNumber > 2 ifTrue: [ lastKeyNumber := 0 ].
	fileName := '../../claudecode0{1}.txt' format: { lastKeyNumber }.
	^ (FileSystem disk workingDirectory / fileName ) readStream contents trimBoth.
]

{ #category : 'accessing' }
ClaudeApi >> bodyForEntityWithPrompt [
	"Creates a JSON request body for Claude API including system content user messages model settings and temperature parameter for message generation"
    | requestDictionary systemContent userMessages |
    
    "Extract system message and filter out system from messages"
    systemContent := self system ifNil: [ '' ].
    userMessages := self jsonHistory select: [ :msg | (msg at: 'role') ~= 'system' ].
    
    requestDictionary := Dictionary newFrom: {
        'model' -> model.
        'max_tokens' -> 1024.
        'system' -> systemContent.
        'messages' -> userMessages.
        'temperature' -> 0.1.
    	  'stream' -> false.
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'accessing' }
ClaudeApi >> initialize [ 
	"Initialises the MistralApi instance with the latest model."
	super initialize.
	self model: 'claude-3-5-sonnet-20241022'.
]

{ #category : 'accessing' }
ClaudeApi >> loadResponse [ 
	| apiGenerateUrl jsonResponse bodyEntity key |
	apiGenerateUrl := 'https://api.anthropic.com/v1/messages'.
	[  bodyEntity := self bodyForEntityWithPrompt.
		key := self class claudeKey.
		jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	    headerAt: 'x-api-key' put: key;
	    headerAt: 'anthropic-version' put: '2023-06-01';
	    headerAt: 'content-type' put: 'application/json';
	    entity: bodyEntity;
	    post;
	    contents.
		self assistant: (self responseOf: jsonResponse) .
	] on: Error do: [ :ex |
	self halt.
   		self assistant: ex messageText.
	].
]

{ #category : 'accessing' }
ClaudeApi >> printOn: aStream [
	aStream << 'ClaudeApi: ' << self model.
]

{ #category : 'accessing' }
ClaudeApi >> responseOf: jsonResponse [
	"Returns the text content from the parsed Claude API JSON response by extracting the text field from the first content element in the response dictionary"
	| parsed |
	parsed := STONJSON fromString: jsonResponse.
	(parsed at: 'type') = 'message'
		ifTrue:[ ^ (parsed at: 'content') first at: 'text'.].
	(parsed at: 'type') = 'error'
		ifTrue:[ ^ 'fooIsDeleted', String cr, 
			('"Error: {1}' format: { (parsed at: 'error') at: 'type' }), String cr, 			('Message: {2}"' format:{ (parsed at: 'error') at: 'message'. }) ].
	Error signal: 'Got an unexpected type return'.
]
