Class {
	#name : 'AIADiscussion',
	#superclass : 'Object',
	#instVars : [
		'history',
		'api'
	],
	#classVars : [
		'Current',
		'Histories'
	],
	#category : 'AIActions-AIADiscussion',
	#package : 'AIActions',
	#tag : 'AIADiscussion'
}

{ #category : 'accessing' }
AIADiscussion class >> current [
	Current ifNil: [ Current := self new ].
	^ Current
]

{ #category : 'accessing' }
AIADiscussion class >> currentHistory [
	^ self current history
]

{ #category : 'class initialization' }
AIADiscussion class >> histories [
	^ Histories collect: [ :dis| dis history first value -> dis history ]
]

{ #category : 'class initialization' }
AIADiscussion class >> initialize [ 
	
	Histories := OrderedDictionary new.
	Current := nil.
]

{ #category : 'as yet unclassified' }
AIADiscussion class >> inspectionKillroy: aBuilder [
	<inspectorPresentationOrder: 100 title: 'Killroy'>
	
	^ aBuilder newCode
		addStyle: 'stCode';
		syntaxHighlight: false;
		text: 'Was here';
		yourself
]

{ #category : 'class initialization' }
AIADiscussion class >> next [

	Current
		ifNil: [
				Histories := OrderedDictionary new.
				Current := nil ]
		ifNotNil: [
				Histories add: Current.
				Current := self new. ]
]

{ #category : 'adding' }
AIADiscussion >> addUser: user response: response [
	"Adds a user message and AI response to the discussion history, updating the conversation context for future interactions."
	
]

{ #category : 'adding' }
AIADiscussion >> getResponse [
	"Retrieves the AI's response from the API, updates the history, and presents the response using AIACommentPresenter. Returns the response text."
	api history: history.
	api getResponse.
	AIACommentPresenter onText: api response.
	"getResponce adds the response to the history"
]

{ #category : 'accessing' }
AIADiscussion >> history [
	"Returns the ordered collection of chat history items, each containing a role and content. Used to track the conversation flow between user and assistant."
	^ history 
]

{ #category : 'initialization' }
AIADiscussion >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	history := OrderedCollection new.
	api := AilienApi provider new. 
]

{ #category : 'adding' }
AIADiscussion >> response [
	^ api response
]

{ #category : 'adding' }
AIADiscussion >> user: aString [
	api history: history.
	api user: aString.
]
