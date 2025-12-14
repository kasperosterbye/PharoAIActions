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
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'initialization' }
AIA2MultiLLMStoreLine >> initialize [ 
	super initialize.
	AIA2MultiLLMStorage storage addStore: self
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> llmNo [

	^ llmNo
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> llmNo: anObject [

	llmNo := anObject
]

{ #category : 'printing' }
AIA2MultiLLMStoreLine >> printOn: aStream [

	aStream 
		<< provider asString 
		<< '/' << llmNo asString 
		<< '/' << turnPattern 
		<< '/' << responseId asString 
		<< '/responseText: ' << (' ' join: responseText lines)
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> provider [

	^ provider
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> provider: anObject [

	provider := anObject
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> responseId [

	^ responseId
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> responseId: anObject [

	responseId := anObject
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> responseText [

	^ responseText
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> responseText: anObject [
	
	responseText := ' ' join: anObject lines
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> turnPattern [

	^ turnPattern
]

{ #category : 'accessing' }
AIA2MultiLLMStoreLine >> turnPattern: anObject [

	turnPattern := anObject
]
