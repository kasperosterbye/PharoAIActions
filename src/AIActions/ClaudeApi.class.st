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
ClaudeApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://docs.anthropic.com/en/docs/about-claude/models/overview to see the list"
	
	^ #(
	'claude-sonnet-4-20250514' 
	'claude-3-haiku-20240307'
	'claude-haiku-4-5-20251001' 
	'claude-opus-4-6'
	'claude-opus-4-5-20251101') 
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
ClaudeApi >> loadResponse: aHistory [
	"Loads and processes the response from the AI API, updating the conversation history with the assistant's reply."
	| maxTurns  |
	history := aHistory.
	maxTurns := 50.
	1 to: maxTurns do: [ :turn |
			(ClaudeInnerCall on: self turn: turn) innerCall.
			].
	^ history assistant: 
		('API Error: tried more than the {1} allowed TOOLS calls' format: { maxTurns })
]

{ #category : 'adding' }
ClaudeApi >> toolSpecification [
	"Returns a collection of tool specifications for all registered API tool subclasses"
	| all |
    all := AilienApiTool subclasses collect: [ :tool |
        | openAI func params |
        openAI := tool new evaluateTool.
        func := openAI at: 'function'.
        params := func at: 'parameters'.
        Dictionary newFrom: {
            'name' -> (func at: 'name').
            'description' -> (func at: 'description').
            'input_schema' -> params } ].
	^ all
]

{ #category : 'adding' }
ClaudeApi >> znClientEntity [
	"Returns the JSON body for the API request, including the message history and tool specifications"
    ^ super znClientEntity , {
        'tools' -> self toolSpecification.
        'max_tokens' -> 4096
    }
]
