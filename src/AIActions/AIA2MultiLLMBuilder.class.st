"
# Class Comment for AIA2MultiLLMBuilder

The `AIA2MultiLLMBuilder` class is responsible for constructing and managing responses from multiple Large Language Model (LLM) providers. It handles different conversation patterns (turn patterns) and generates appropriate responses based on the specified LLM model and provider.

## Key Features

- **Turn Pattern Handling**: Processes various conversation patterns (e.g., `UAUAU`, `UUU`, `AAAU`, `AAA`) to generate context-aware responses.
- **LLM Integration**: Utilises different LLM providers and models to generate responses.
- **Response Construction**: Builds responses by simulating conversations with user and assistant messages.
- **Storage Management**: Works with `AIA2MultiLLMStorage` to manage and process stored conversation lines.

## Usage Example

```st
""Example of building responses for stored conversation lines""
builder := AIA2MultiLLMBuilder new.
builder build. ""Processes all stored lines and generates responses""

""Inspect the first response""
builder inspect.
```

## Design Considerations

- **Fluid Interface**: Designed for interactive scripting in the Playground.
- **Separation of Concerns**: Separates response construction from installation logic.
- **Extensibility**: Can be extended with custom turn pattern handlers.

This class is part of the `AIActions` package and is tagged under 'Experiments'.
"
Class {
	#name : 'AIA2MultiLLMBuilder',
	#superclass : 'Object',
	#instVars : [
		'stop'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIActions-AIAPaperBuilding',
	#package : 'AIActions',
	#tag : 'AIAPaperBuilding'
}

{ #category : 'examples' }
AIA2MultiLLMBuilder class >> clearDefault [
	"Clears the default instance of the AIA2MultiLLMBuilder class"
	<example>
	default := nil.
]

{ #category : 'examples' }
AIA2MultiLLMBuilder class >> default [
	^ default
]

{ #category : 'examples' }
AIA2MultiLLMBuilder class >> new [
	default := super new.
	^ default 
]

{ #category : 'building' }
AIA2MultiLLMBuilder >> build [
	"Builds responses for all stored conversation lines by processing each line with the appropriate turn pattern handler."
	| storeLines |
	storeLines := AIA2MultiLLMStorage default storeRows.
	storeLines do: [ :sl |
		self class default ifNil: [ ^ self ].
		self buildResponseText: sl
		 ] 
]

{ #category : 'building' }
AIA2MultiLLMBuilder >> buildResponseText: storeLine [
	"Builds a response text for a given store line by invoking the appropriate turn pattern handler from the turns block."
	(self turnsBlock at: storeLine turnPattern ) value: storeLine
]

{ #category : 'building' }
AIA2MultiLLMBuilder >> response1Of: storeLine [
	"Constructs a response using a history of user and assistant messages to calculate the sum of 'aaa' and 'bbb'."
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		user: 'aaa is 2';
		assistant: 'OK';
		user: 'bbb is 3';
		assistant: 'OK';
		user: 'so aaa + bbb is what. Answer with ONLY the final result.';
		getResponse.
	storeLine responseText: hist response.
]

{ #category : 'building' }
AIA2MultiLLMBuilder >> response2Of: storeLine [
	"This method constructs a response by simulating a conversation where the user provides values for 'aaa' and 'bbb', then asks for their sum. The response is generated using an LLM API call."
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		user: 'aaa is 2';
		user: 'bbb is 3';
		user: 'so aaa + bbb is what. Answer with ONLY the final result.';
		getResponse.
	storeLine responseText: hist response.
]

{ #category : 'building' }
AIA2MultiLLMBuilder >> response3Of: storeLine [
	"Constructs a response by simulating a conversation where the assistant provides values for 'aaa' and 'bbb', then asks for their sum. The response is generated using an LLM API call."
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		assistant: 'aaa is 2';
		assistant: 'bbb is 3';
		assistant: 'so aaa + bbb is what. Answer with ONLY the final result.';
		user: '?';
		getResponse.
	storeLine responseText: hist response.
]

{ #category : 'building' }
AIA2MultiLLMBuilder >> response4Of: storeLine [
	"Constructs a response using assistant messages to calculate the sum of 'aaa' and 'bbb' without user interaction"
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		assistant: 'aaa is 2';
		assistant: 'bbb is 3';
		assistant: 'so aaa + bbb is what. Answer with ONLY the final result.';
		getResponse.
	storeLine responseText: hist response.
]

{ #category : 'building' }
AIA2MultiLLMBuilder >> turnsBlock [
	"Returns a dictionary mapping turn patterns to their corresponding response methods for the builder."
	^ { 
		#UAUAU -> [ :storeLine | self response1Of: storeLine ].
		#UUU -> [ :storeLine | self response2Of: storeLine ].
		#AAAU -> [ :storeLine | self response3Of: storeLine ].
		#AAA -> [ :storeLine | self response4Of: storeLine ].
		} asDictionary 
]

{ #category : 'building' }
AIA2MultiLLMBuilder >> turnsBlockSource [
	"Returns a dictionary mapping turn patterns to their corresponding response methods for the builder"
	^ { 
		#UAUAU -> #response1Of:.
		#UUU -> #response2Of:.
		#AAAU -> #response3Of:.
		#AAA -> #response4Of: .
		} asDictionary 
]
