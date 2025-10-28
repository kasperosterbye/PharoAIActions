Class {
	#name : 'AIACommentBuilding',
	#superclass : 'Object',
	#instVars : [
		'aiaApi'
	],
	#classVars : [
		'CommentLanguage',
		'CommentType'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'as yet unclassified' }
AIACommentBuilding class >> commentType [
	"Returns the current comment type for the AIACommentBuilding class"
	CommentType ifNil: [ CommentType := self commentTypes first ].
	^ CommentType 
]

{ #category : 'as yet unclassified' }
AIACommentBuilding class >> commentType: commentType [
	"Sets the comment type for the AIACommentBuilding class"

	| index |
	(commentType isInteger and: [ commentType >= 1 & commentType <= self commentTypes size ]) ifTrue: [
			CommentType := self commentTypes at: commentType.
			^ self ].
	index := self commentTypes indexOf: commentType.
	index > 0
		ifTrue: [ CommentType := commentType ]
		ifFalse: [ CommentType := self commentTypes first ]
]

{ #category : 'as yet unclassified' }
AIACommentBuilding class >> commentTypes [
	"Returns the available comment types for the AIACommentBuilding class"
	^ { 'Basic'. 'Beginner'. 'Detailed'. 'Expert'. 'TestGuide' }
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIClassComment [
	self aiaComment inspect
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIMethodComment [
	(EpLog >> #priorEntriesFrom:do:) aiaComment inspect
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIPackageComment [
	'Epicea' aiaComment inspect
]

{ #category : 'accessing' }
AIACommentBuilding class >> language [
	CommentLanguage ifNil: [ CommentLanguage := 'British' ].
	^ CommentLanguage 
]

{ #category : 'accessing' }
AIACommentBuilding class >> language: language [
	"Sets the preferred language for comment generation to the specified language string"
	CommentLanguage := language
]

{ #category : 'accessing' }
AIACommentBuilding >> getResponse [
	"Method initiates AI process to retrieve response displaying progress and handling interruptions. Uses system progress morph to show progress and allows interruption. Returns response from AI API."
	
	aiaApi getResponse
]

{ #category : 'initialization' }
AIACommentBuilding >> initialize [ 
	"Initialises the AI comment builder with a new AI API provider, setting up the necessary infrastructure for generating AI-driven comments."
	super initialize.
	aiaApi := AilienApi provider new.
]

{ #category : 'accessing' }
AIACommentBuilding >> response [
	"Returns the AI-generated response from the API, formatted as a string. Handles errors and ensures valid output. Uses the configured AI model for processing."

	^ aiaApi response
]

{ #category : 'accessing' }
AIACommentBuilding >> system [

	^ aiaApi system
]

{ #category : 'accessing' }
AIACommentBuilding >> system: anObject [

	aiaApi system: anObject
]

{ #category : 'accessing' }
AIACommentBuilding >> user [

	^ aiaApi user
]

{ #category : 'accessing' }
AIACommentBuilding >> user: anObject [

	aiaApi user: anObject
]
