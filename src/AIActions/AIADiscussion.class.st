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

{ #category : 'class initialization' }
AIADiscussion class >> histories [
	^ Histories collect: [ :dis| dis history first value -> dis history ]
]

{ #category : 'class initialization' }
AIADiscussion class >> initialize [ 
	
	Histories := OrderedDictionary new.
	Current := nil.
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
	
]

{ #category : 'adding' }
AIADiscussion >> getResponse [
	"Send history to my provider, and insert response into my history"
	api history: history.
	api getResponse.
	AIACommentPresenter onText: api response.
	"getResponce adds the response to the history"
]

{ #category : 'accessing' }
AIADiscussion >> history [
	
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
