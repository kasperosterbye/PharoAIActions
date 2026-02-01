"
# Class Comment for AIA2MultiLLMBuilder

The `AIA2MultiLLMBuilder` class is responsible for constructing and managing multi-turn conversations with Large Language Models (LLMs). It processes stored conversation lines by applying appropriate turn pattern handlers to generate responses. The builder supports various conversation patterns, including user-assistant interactions and assistant-only responses, and can be extended to accommodate additional patterns as needed.

## Key Features

- **Turn Pattern Handling**: Maps specific conversation patterns (e.g., `#UAUAU`, `#UUU`) to corresponding response methods.
- **Response Generation**: Constructs responses by simulating conversations with LLMs, including user and assistant messages.
- **Flexible Configuration**: Allows customisation of conversation flows and response logic through configurable turn patterns.

## Usage Example

```st
""AIA2MultiLLMBuilder example usage in the Playground""

""Create a new builder instance""
builder := AIA2MultiLLMBuilder new.

""Define a sample store line with conversation details""
storeLine := AIA2MultiLLMStorage new
    turnPattern: #UAUAU;
    provider: AIAOpenAI;
    llmNo: 'gpt-3.5-turbo';
    yourself.

""Build the response for the store line""
builder buildResponseText: storeLine.

""Inspect the generated response""
storeLine responseText
```

This example demonstrates how to create a builder, configure a conversation scenario, and generate a response using the `AIA2MultiLLMBuilder`. The response is stored in the `responseText` slot of the store line and can be inspected for verification.
"
Class {
	#name : 'AIA2MultiLLMBuilder',
	#superclass : 'Object',
	#classInstVars : [
		'default'
	],
	#category : 'AIAExperiments-PaperWriting',
	#package : 'AIAExperiments',
	#tag : 'PaperWriting'
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
