"
AIAiliensSelection is a class designed to encapsulate information related to AI model selections, including the timestamp of the selection, the provider's name, and the model's name.
"
Class {
	#name : 'AIAiliensSelection',
	#superclass : 'Object',
	#instVars : [
		'timestamp',
		'providerName',
		'modelName'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'instance creation' }
AIAiliensSelection class >> fromLine: aString [
	| words |
	words := aString substrings.
	^ self new
		timestamp: (DateAndTime fromString: words first);
		providerName: words second asSymbol;
		modelName: words third;
		yourself
]

{ #category : 'accessing' }
AIAiliensSelection >> modelName [
	^ modelName
]

{ #category : 'accessing' }
AIAiliensSelection >> modelName: aString [
	modelName := aString
]

{ #category : 'accessing' }
AIAiliensSelection >> providerName [
	^ providerName
]

{ #category : 'accessing' }
AIAiliensSelection >> providerName: aSymbol [
	providerName := aSymbol
]

{ #category : 'accessing' }
AIAiliensSelection >> timestamp [
	^ timestamp
]

{ #category : 'accessing' }
AIAiliensSelection >> timestamp: aDateAndTime [
	timestamp := aDateAndTime
]
