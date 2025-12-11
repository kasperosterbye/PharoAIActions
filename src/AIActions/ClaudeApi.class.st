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
	#classInstVars : [
		'lastKeyNumber'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'AI models' }
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
	
	^ #(
	'claude-sonnet-4-20250514' 
	'claude-3-haiku-20240307'
	'claude-3-5-haiku-20241022' 
	'claude-3-7-sonnet-20250219'
	'claude-opus-4-5-20251101') 
]

{ #category : 'accessing' }
ClaudeApi >> apiGenerateUrl [ 
	^ 'https://api.anthropic.com/v1/messages'
]

{ #category : 'accessing' }
ClaudeApi >> bodyForEntityWithPrompt [
	"Creates a JSON request body for Claude API including system content user messages model settings and temperature parameter for message generation"
    | requestDictionary  |
    requestDictionary := Dictionary newFrom: {
        'model' -> self model.
        'messages' -> self jsonHistory.
        'max_tokens' -> 4096.
        'temperature' -> 0.0.
    	  'stream' -> false.
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'accessing' }
ClaudeApi >> headers: jsonResponse [

	jsonResponse
		headerAt: 'x-api-key' put: self class claudeKey;
		headerAt: 'anthropic-version' put: '2023-06-01';
		headerAt: 'content-type' put: 'application/json'.
	^ jsonResponse 
]

{ #category : 'initialize' }
ClaudeApi >> initialize [ 
	"Initialises a new ClaudeApi instance with default model and empty history ready for AI interactions"
	super initialize.
   self model: self class defaultModel .
]

{ #category : 'accessing' }
ClaudeApi >> printOn: aStream [
	"Prints the model name of the ClaudeApi instance, showing the current AI model being used for interactions"
	aStream << 'ClaudeApi: ' << self model.
]

{ #category : 'accessing' }
ClaudeApi >> responseOf: jsonResponse [
	"Returns the text content from the parsed Claude API JSON response by extracting the text field from the first content element in the response dictionary"
	| parsed |
	parsed := STONJSON fromString: jsonResponse.
	[ ^ (parsed at: 'content') first at: 'text'.]
		on: Error
		do: [  ^ self errorResponse: jsonResponse  ]
]
