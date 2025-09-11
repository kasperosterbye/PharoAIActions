"
# Class Comment for ClaudeApi

The `ClaudeApi` class provides an interface to interact with Anthropic's Claude AI models through their API. It extends the `AilienApi` superclass to implement specific functionality for Claude's message-based API.

## Key Features

- **Model Management**: Supports multiple Claude models including the latest versions of Sonnet and Haiku
- **Conversation History**: Maintains and formats conversation history in JSON format suitable for the API
- **API Integration**: Handles authentication, request formatting, and response processing
- **Error Handling**: Gracefully manages API errors and provides meaningful feedback

## Usage Example

```smalltalk
""Create and configure a Claude API instance""
api := ClaudeApi new.
api system: 'You are a helpful assistant that explains programming concepts'.
api user: 'What is polymorphism in object-oriented programming?'.
api getResponse.

""Inspect the response""
api response
```

## Implementation Notes

- Requires valid API keys stored in `claudecode00.txt`, `claudecode01.txt`, etc.
- Uses the Anthropic API endpoint at `https://api.anthropic.com/v1/messages`
- Implements proper request headers including API key and version
- Processes both successful responses and error conditions
- Maintains conversation history in chronological order

## Error Handling

The class handles API errors by:
1. Catching exceptions during API calls
2. Providing formatted error messages
3. Preserving conversation context even when errors occur

This implementation provides a robust foundation for integrating Claude's AI capabilities into Pharo applications while maintaining clean separation of concerns with the base `AilienApi` class.
```
"
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

{ #category : 'AI models' }
ClaudeApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://docs.anthropic.com/en/docs/about-claude/models/overview to see the list"
	
	^ #('claude-3-5-sonnet-20241022' 
	'claude-3-5-haiku-20241022' 
	'claude-sonnet-4-20250514' 
	'claude-3-7-sonnet-20250219') 
]

{ #category : 'accessing' }
ClaudeApi >> bodyForEntityWithPrompt [
	"Creates a JSON request body for Claude API including system content user messages model settings and temperature parameter for message generation"
    | requestDictionary  |
    requestDictionary := Dictionary newFrom: {
        'model' -> model.
        'max_tokens' -> 1024.
        'messages' -> self jsonHistory.
        'temperature' -> 0.1.
    	  'stream' -> false.
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'initialize' }
ClaudeApi >> initialize [ 
	"Initialises the MistralApi instance with the latest model."
	super initialize.
	self model: 'claude-3-5-sonnet-20241022'.
]

{ #category : 'accessing' }
ClaudeApi >> loadResponse [ 
	"Loads response from Claude API, handling API calls, processing results, and managing errors. Updates assistant message in history or sets error message."
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
   		self assistant: ex messageText.
	].
]

{ #category : 'accessing' }
ClaudeApi >> printOn: aStream [
	"Prints the class name and current model to a stream in a readable format for debugging purposes"
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
