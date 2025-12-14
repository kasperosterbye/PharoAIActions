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
	^ { #providers -> {ClaudeApi. GeminiApi. GrokApi. MistralApi.  OllamaApi. OpenAIApi. TogetherApi}.
		#llmNos -> { 1. 2. 3. 4 }.
		#turnPatterns -> { #UAUAU. #UUU. #AAAU. #AAA }.
		#responseIds -> (1 to: 7) asArray 
	} asDictionary
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMStorage class >> linesToBuild [
	^ { #providers -> {OllamaApi. TogetherApi}.
		#llmNos -> {3. 4 }.
		#turnPatterns -> { #AAAU }.
		#responseIds -> (1 to: 2) asArray 
	} asDictionary
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMStorage class >> new [
	self error: 'use storage instead'
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMStorage class >> storage [
	storage ifNil: [ storage := super new ].
	^ storage
]

{ #category : 'adding' }
AIA2MultiLLMStorage >> addStore: line [
	self storeRows add: line 
]

{ #category : 'initialization' }
AIA2MultiLLMStorage >> initialize [
	super initialize.
	self storageArray: OrderedCollection new.
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMStorage >> makeStoreLines [
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
	storageArray do: [ : storeLine |
		storeLine printOn: aStream.
		aStream << String lf 
		 ].
	^ aStream  contents 
]

{ #category : 'accessing' }
AIA2MultiLLMStorage >> storageArray [
	^ storageArray
]

{ #category : 'accessing' }
AIA2MultiLLMStorage >> storageArray: anObject [
	storageArray := anObject
]

{ #category : 'adding' }
AIA2MultiLLMStorage >> storeRows [
	^ storageArray 
]
