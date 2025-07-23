Class {
	#name : 'AIAChatBuilding',
	#superclass : 'AIACommentBuilding',
	#instVars : [
		'history'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'initialization' }
AIAChatBuilding >> assistant: aString [
	history add: 'assistant' -> aString
]

{ #category : 'initialization' }
AIAChatBuilding >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	history := OrderedCollection new.
]

{ #category : 'initialization' }
AIAChatBuilding >> jsonHistory [
	| jsonHistory |
	jsonHistory := OrderedCollection new.
	history do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'content' -> item value.})
	].
	jsonHistory := jsonHistory asArray.
	aiaApi messagePart: jsonHistory.
	aiaApi getResponse.
	^ self response 
"	^jsonHistory "
]

{ #category : 'initialization' }
AIAChatBuilding >> system: aString [
	history add: 'system' -> aString
]

{ #category : 'initialization' }
AIAChatBuilding >> user: aString [
	history add: 'user' -> aString
]
