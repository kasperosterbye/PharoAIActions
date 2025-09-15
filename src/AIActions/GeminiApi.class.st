"
# Class Comment for GeminiApi

## Overview
`GeminiApi` is a specialized API client for interacting with Google's Gemini large language models. It extends the abstract `AilienApi` class to provide concrete implementations for model-specific operations, including request formatting, response parsing, and conversation history management tailored to the Gemini API's requirements.

## Key Features
- **Model-Specific Configuration**: Uses Gemini's model endpoints and authentication
- **Response Handling**: Parses JSON responses from the Gemini API
- **Conversation Management**: Maintains and formats chat history in Gemini's required format
- **Error Handling**: Processes API errors and provides meaningful feedback

## Usage Example

```smalltalk
""Create and configure a new GeminiApi instance""
gemini := GeminiApi new
    model: 'gemini-2.0-flash-lite';
    system: 'You are a helpful assistant';
    prompt: 'Explain quantum computing in simple terms'.

""Get a response from the API""
gemini getResponse.

""Inspect the assistant's response""
gemini response
```

## Implementation Notes
- Requires a valid API key stored in `geminicode.txt` in the parent directory
- Uses the STON library for JSON parsing
- Implements the abstract methods from `AilienApi` with Gemini-specific logic
- Maintains conversation history in the format expected by the Gemini API

## See Also
- `AilienApi` - The abstract superclass providing common AI API functionality
- `GeminiApi class>>#modelNames` - Lists available Gemini models
- `GeminiApi class>>#geminiKey` - Manages API key access
```

This class comment provides a comprehensive overview of the `GeminiApi` class, its purpose, key features, and usage examples that can be directly executed in the Pharo Playground. The example demonstrates the complete workflow from instance creation to obtaining a response, with the final expression (`gemini response`) ready for inspection using the Playground's inspection command.
"
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

{ #category : 'AI models' }
GeminiApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://ai.google.dev/gemini-api/docs/models to see the list"
	
	^ #('gemini-2.0-flash-lite'  'gemini-2.5-pro' 'gemini-1.5-pro' 'gemini-2.5-flash') 
]

{ #category : 'ollama models' }
GeminiApi >> bodyForEntityWithPrompt [
	"Constructs JSON entity for API request with chat history and generation config. Formats history as role-parts array and sets temperature to 0. Returns ZnEntity with JSON string."

	| requestDictionary |
	requestDictionary :=Dictionary newFrom: {
		'contents' -> self jsonHistory.
		'generationConfig' -> (Dictionary newFrom: {
			'temperature' -> 0
		})
	}.
	^ ZnEntity json: (STONJSON toString: requestDictionary)
]

{ #category : 'initialize' }
GeminiApi >> initialize [ 
	"Initialises the MistralApi instance with the latest model."
	super initialize.
	self model: 'gemini-2.0-flash-lite'.
]

{ #category : 'accessing' }
GeminiApi >> jsonHistory [
	"Converts the chat history into a JSON-formatted array suitable for the Gemini API, structuring each message with role and text content."
	| jsonHistory |
	jsonHistory := OrderedCollection new.
	history do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'parts' -> { Dictionary newFrom: {  'text' -> item value} } } )
	].
	^ jsonHistory asArray.
]

{ #category : 'mistral models' }
GeminiApi >> loadResponse [
	"Loads response from Gemini API, handling JSON parsing, error checking, and updating assistant state. Uses model-specific endpoint and API key for secure communication."

	| apiGenerateUrl jsonResponse bodyEntity |
	apiGenerateUrl := 'https://generativelanguage.googleapis.com/v1beta/models/' , model , ':generateContent'.
	[
		bodyEntity := self bodyForEntityWithPrompt.
		jsonResponse := ZnClient new
			                url: apiGenerateUrl;
			                headerAt: 'X-goog-api-key' put: self class geminiKey;
			                headerAt: 'Content-Type' put: 'application/json';
			                entity: bodyEntity;
			                post;
			                contents.
		self assistant: (self responseOf: jsonResponse) ]
		on: Error
		do: [ :ex | self assistant: ex messageText ]
]

{ #category : 'accessing' }
GeminiApi >> printOn: aStream [
	"Prints the class name and current model to a stream for debugging and inspection purposes."
	aStream << 'GeminiApi: ' << self model.
]

{ #category : 'accessing' }
GeminiApi >> responseOf: jsonResponse [
	| parsed message |
	parsed := STONJSON fromString: jsonResponse.
	[
		message := (parsed at: 'candidates') first at: 'content'.
		^ (message at: 'parts') first at: 'text' ]
		on: Error
		do: [ ^ 'Error bla bla: ' , jsonResponse ]
]
