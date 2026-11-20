"
# Class: ClaudeApi

A `ClaudeApi` is a subclass of `AilienApi` designed to interact with the Anthropic's Claude AI models. It provides functionality to manage conversations, handle tool specifications, and process responses from the AI API. The class supports multiple models and includes methods for setting up API requests, managing message history, and processing responses.

## Usage Example

```st
""Create an instance of ClaudeApi and set the model""
api := ClaudeApi new.
api model: 'claude-sonnet-4-20250514'.

""Add messages to the conversation history""
api messageList: {
    'user' -> 'Hello, how are you?'.
    'assistant' -> 'I am doing well, thank you! How can I assist you today?'
}.

""Generate the JSON body for the API request""
jsonBody := api znClientEntity.

""Inspect the JSON body""
jsonBody inspect.
```

This example demonstrates how to create an instance of `ClaudeApi`, set the model, add messages to the conversation history, and generate the JSON body for the API request. The JSON body can then be inspected to verify its contents.
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

{ #category : 'accessing' }
ClaudeApi class >> apiGenerateUrl [ 
	"Returns the URL endpoint for generating API responses using the Claude model"
	^ 'https://api.anthropic.com/v1/messages'
]

{ #category : 'AI models' }
ClaudeApi class >> claudeKey [
	"Returns the API key for the Claude model, cycling through available keys"
	| fileName |
	lastKeyNumber ifNil: [ lastKeyNumber := 0 ].
	lastKeyNumber := lastKeyNumber + 1.
	lastKeyNumber > 2 ifTrue: [ lastKeyNumber := 0 ].
	fileName := '../../claudecode0{1}.txt' format: { lastKeyNumber }.
	^ (FileSystem disk workingDirectory / fileName ) readStream contents trimBoth.
]

{ #category : 'AI models' }
ClaudeApi class >> znClientHeaders: jsonPrompt [
	"Configures and returns the headers for the HTTP client used to interact with the Claude API, including the API key and version information"
	jsonPrompt
		headerAt: 'x-api-key' put: self claudeKey;
		headerAt: 'anthropic-version' put: '2023-06-01';
		headerAt: 'content-type' put: 'application/json'.
]

{ #category : 'adding' }
ClaudeApi >> innerCallClass [
	^ ClaudeInnerCall
]

{ #category : 'adding' }
ClaudeApi >> jsonHistory [
	"Returns the JSON representation of the message history for API interaction"
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item |
        item value isDictionary
            ifTrue: [ jsonHistory add: item value ]
            ifFalse: [
                jsonHistory add: (Dictionary newFrom: {
                    'role' -> item key.
                    'content' -> item value }) ] ].
    ^ jsonHistory asArray
]

{ #category : 'adding' }
ClaudeApi >> toolSpecification [
    "Translate the common registered tool specifications to Claude's format."
    ^ super toolSpecification collect: [ :tool |
        | function |
        function := tool at: 'function'.
        Dictionary newFrom: {
            'name' -> (function at: 'name').
            'description' -> (function at: 'description').
            'input_schema' -> (function at: 'parameters') } ]
]

{ #category : 'adding' }
ClaudeApi >> znClientEntity [
    "Add Claude's token limit to the common request, which includes tools only when enabled."
    ^ super znClientEntity , { 'max_tokens' -> 32000 }
]
