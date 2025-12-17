"
# Class Comment for AIA2MultiLLMStorage

`AIA2MultiLLMStorage` is a singleton class designed to manage and store configurations for multi-LLM (Large Language Model) experiments. It maintains an ordered collection of `AIA2MultiLLMStoreLine` instances, each representing a specific combination of LLM provider, model count, turn pattern, and response identifier.

## Key Features

- **Singleton Pattern**: Ensures a single instance manages all multi-LLM configurations.
- **Comprehensive Storage**: Automatically generates all possible combinations of LLM configurations based on predefined parameters.
- **Flexible Configuration**: Supports different providers, model counts, turn patterns, and response identifiers.
- **Printable Representation**: Provides a formatted output of all stored configurations.

## Usage Example

```smalltalk
""Access the singleton storage instance""
storage := AIA2MultiLLMStorage storage.

""Generate and populate the storage with all possible configurations""
storage makeStoreLines.

""Inspect the stored configurations""
storage storageArray inspect.

""Add a custom configuration line""
customLine := AIA2MultiLLMStoreLine new
    provider: OllamaApi;
    llmNo: 2;
    turnPattern: #UUU;
    responseId: 3;
    responseText: 'Custom response text'.
storage addStore: customLine.

""Print all configurations to a stream""
stream := WriteStream on: String new.
storage printOn: stream.
stream contents inspect.
```

## Configuration Parameters

The class uses predefined sets of parameters to generate configurations:
- **Providers**: OllamaApi, TogetherApi (and others in full configuration)
- **LLM Numbers**: 1, 3 (and up to 4 in full configuration)
- **Turn Patterns**: #UUU, #AAA, #AAAU (and others in full configuration)
- **Response IDs**: 1 to 2 (and up to 7 in full configuration)

This class is tagged as 'Experiments' and resides in the 'AIActions' package.
"
Class {
	#name : 'AIA2MultiLLMStorage',
	#superclass : 'Object',
	#instVars : [
		'storageArray'
	],
	#classInstVars : [
		'storage'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'as yet unclassified' }
AIA2MultiLLMStorage class >> clearStorage [
	<example>
	storage := nil
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMStorage class >> full_linesToBuild [
	"Returns a dictionary of full configuration parameters for building LLM storage"
	^ { #providers -> {ClaudeApi. GeminiApi. GrokApi. MistralApi.  OllamaApi. OpenAIApi. TogetherApi}.
		#llmNos -> { 1. 2. 3. 4 }.
		#turnPatterns -> { #UAUAU. #UUU. #AAAU. #AAA }.
		#responseIds -> (1 to: 7) asArray 
	} asDictionary
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMStorage class >> linesToBuild [
	"Returns a dictionary of configuration parameters for building LLM storage"
	^ { #providers -> {OllamaApi. TogetherApi}.
		#llmNos -> {1. 3 }.
		#turnPatterns -> { #UUU. .#AAA. #AAAU }.
		#responseIds -> (1 to: 2) asArray 
	} asDictionary
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMStorage class >> new [
	"Use storage instead of creating a new instance"
	self error: 'use storage instead'
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMStorage class >> storage [
	"Returns the singleton storage instance for multi-LLM configurations"
	storage ifNil: [ storage := super new ].
	^ storage
]

{ #category : 'adding' }
AIA2MultiLLMStorage >> addStore: line [
	"Adds a new store line to the storage array"
	self storeRows add: line 
]

{ #category : 'initialization' }
AIA2MultiLLMStorage >> initialize [
	"Initialises the storage with an empty ordered collection for multi-LLM configurations"
	super initialize.
	self storageArray: OrderedCollection new.
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMStorage >> makeStoreLines [
	"Creates and populates the storage array with all possible combinations of provider, LLM number, turn pattern, and response ID."
	self storeRows ifNotEmpty: [ ^ self ].
	(self class linesToBuild at: 'providers') do: [ :provider |
		(self class linesToBuild at: 'llmNos') do: [ :llmNo |
			(self class linesToBuild at: 'turnPatterns') do: [ :turnPattern |
				(self class linesToBuild at: 'responseIds') do: [ :responseId |
					AIA2MultiLLMStoreLine new
						provider: provider;
						llmNo: llmNo;
						turnPattern: turnPattern;
						responseId: responseId;
						responseText: ''.
					 ]]]]
]

{ #category : 'printing' }
AIA2MultiLLMStorage >> printOn: aStream [
	"Prints each store line in the storage array to the stream, separated by line feeds"
	storageArray do: [ : storeLine |
		storeLine printOn: aStream.
		aStream << String lf 
		 ].
	^ aStream  contents 
]

{ #category : 'accessing' }
AIA2MultiLLMStorage >> storageArray [
	"Returns the ordered collection storing multi-LLM configuration lines"
	^ storageArray
]

{ #category : 'accessing' }
AIA2MultiLLMStorage >> storageArray: anObject [
	"Returns the ordered collection storing multi-LLM configuration lines"
	storageArray := anObject
]

{ #category : 'adding' }
AIA2MultiLLMStorage >> storeRows [
	"Returns the ordered collection storing multi-LLM configuration lines"
	^ storageArray 
]
