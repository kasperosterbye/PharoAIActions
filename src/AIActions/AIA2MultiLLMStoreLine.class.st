"
# Class Comment for AIA2MultiLLMStoreLine

`AIA2MultiLLMStoreLine` represents a single line of data storage for multi-LLM (Large Language Model) interactions within the AIActions framework. It encapsulates key details of an LLM response, including the provider, model number, turn pattern, response identifier, and the response text itself.

## Key Features

- **Structured Storage**: Organises LLM interaction data in a consistent format.
- **Multi-LLM Support**: Tracks responses from multiple LLM providers and models.
- **Turn Pattern Tracking**: Records the sequence of interactions (turn pattern) leading to the response.
- **Response Management**: Stores both the response identifier and the full response text.

## Usage Example

```st
""AIA2MultiLLMStoreLine usage example in Playground""

""Create a new store line""
storeLine := AIA2MultiLLMStoreLine new
    provider: 'OpenAI';
    llmNo: 1;
    turnPattern: 'user/system';
    responseId: 12345;
    responseText: 'This is a sample response from the LLM'.

""Inspect the created store line""
storeLine inspect
```

## Design Notes

- Automatically registers with `AIA2MultiLLMStorage` upon initialisation.
- Response text is normalised by joining lines with spaces.
- Follows the same fluid API pattern as other class builders in the system.
```
"
Class {
	#name : 'AIA2MultiLLMStoreLine',
	#superclass : 'Object',
	#instVars : [
		'provider',
		'llmNo',
		'turnPattern',
		'responseId',
		'responseText'
	],
	#category : 'AIActions-AIAPaperBuilding',
	#package : 'AIActions',
	#tag : 'AIAPaperBuilding'
}

{ #category : 'initialization' }
AIA2MultiLLMStoreLine >> initialize [ 
	"Initialises the store line and adds it to the storage"
	super initialize.
	AIA2MultiLLMStorage storage addStore: self
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> llmNo [
	"Returns the LLM number associated with this store line"

	^ llmNo
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> llmNo: anObject [
	"Sets the LLM number for this store line"

	llmNo := anObject
]

{ #category : 'printing' }
AIA2MultiLLMStoreLine >> printOn: aStream [
	"Prints the store line details to a stream in a structured format."

	aStream 
		<< provider asString 
		<< '/' << llmNo asString 
		<< '/' << turnPattern 
		<< '/' << responseId asString 
		<< '/responseText: ' << (' ' join: responseText lines)
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> provider [
	"Returns the provider associated with this store line"

	^ provider
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> provider: anObject [
	"Returns the provider associated with this store line"

	provider := anObject
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> responseId [
	"Returns the response identifier associated with this store line"

	^ responseId
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> responseId: anObject [
	"Sets the response identifier for this store line"

	responseId := anObject
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> responseText [
	"Returns the response text associated with this store line"

	^ responseText
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> responseText: anObject [
	"Sets the response text, joining lines with spaces"
	
	responseText := ' ' join: anObject lines
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> turnPattern [
	"Returns the turn pattern associated with this store line"

	^ turnPattern
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> turnPattern: anObject [
	"Sets the turn pattern for this store line"

	turnPattern := anObject
]
