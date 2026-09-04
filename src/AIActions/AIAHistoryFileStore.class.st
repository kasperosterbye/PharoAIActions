"
AIAHistoryFileStore persists and loads AIAHistory conversations as files, allowing histories to be saved and restored between Pharo sessions.
"
Class {
	#name : 'AIAHistoryFileStore',
	#superclass : 'Object',
	#instVars : [
		'createdAt',
		'modifiedAt',
		'rootDirectory'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'loading' }
AIAHistoryFileStore class >> loadFrom: aFileReference [
	"Load a history store from a file reference"
	| json store |
	json := aFileReference readStreamDo: [ :stream |
		stream contents ].
	store := self new.
	store rootDirectory: aFileReference parent.
	^ store historyFromJson: json
]

{ #category : 'accessing' }
AIAHistoryFileStore >> associationFromRoleDictionary: aDictionary [
	^ (aDictionary at: 'role')
		-> (aDictionary at: 'content')
]

{ #category : 'submorphs - add/remove' }
AIAHistoryFileStore >> delete [
	"Delete the persisted history file if it still exists."

	| file |
	file := self fileReference.
	file exists ifTrue: [
		file delete ].
	^ file
]

{ #category : 'accessing' }
AIAHistoryFileStore >> fileName [
	"Returns a filename built from the creation date and time"
	| date time shortId createdString |
	createdString := createdAt asString.
	date := (createdString copyFrom: 1 to: 10)
		copyWithoutAll: '-'.
	time := (createdString copyFrom: 12 to: 19)
		copyWithoutAll: ':'.
	shortId := (createdString copyFrom: 21 to: 25).
	^ date, '-', time, '-', shortId, '.json'
]

{ #category : 'accessing' }
AIAHistoryFileStore >> fileReference [
	^ self rootDirectory / self fileName
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStore >> historyFromJson: json [
	^ self
		historyFromJson: json
		preHistoryLoader: [ :fileName |
			self class loadFrom:
				self rootDirectory / fileName ]
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStore >> historyFromJson: json preHistoryLoader: aBlock [
	"Converts a dictionary into an AIAHistory object, initialising its properties and associations from the dictionary."
	| aDictionary history providerClass api preHistoryFiles |
	aDictionary := STONJSON fromString: json.
	preHistoryFiles := aDictionary
		at: 'preHistoryFiles'
		ifAbsent: [ #() ].

	createdAt := DateAndTime fromString:
		(aDictionary at: 'createdAt').
	modifiedAt := DateAndTime fromString:
		(aDictionary at: 'modifiedAt').

	providerClass := Smalltalk globals
		at: (aDictionary at: 'provider') asSymbol
		ifAbsent: [ self error: 'Unknown API provider' ].

	(AilienApi allSubclasses includes: providerClass)
		ifFalse: [ self error: 'Invalid API provider' ].

	api := providerClass new.
	api model: (aDictionary at: 'model').

	history := AIAHistory new.
	history
		fileStore: self;
		title: (aDictionary at: 'title');
		api: api;
		responseHearderLevel:
			(aDictionary at: 'responseHeaderLevel').

	(aDictionary at: 'firstRoles') do: [ :each |
		history firstRoles add:
			(self associationFromRoleDictionary: each) ].

	(aDictionary at: 'messages') do: [ :each |
		history messages add:
			(self associationFromRoleDictionary: each) ].

	(aDictionary at: 'lastRoles') do: [ :each |
		history lastRoles add:
			(self associationFromRoleDictionary: each) ].
	preHistoryFiles do: [ :fileName |
		history preHistories add: (aBlock value: fileName) ].
	^ history
]

{ #category : 'initialization' }
AIAHistoryFileStore >> initialize [
	super initialize.
	createdAt := DateAndTime now.
	modifiedAt := createdAt.
	rootDirectory := FileLocator home / 'D' / 'Pharo' / 'history'.
]

{ #category : 'actions' }
AIAHistoryFileStore >> jsonFromHistory: aHistory [
	"Converts an AIAHistory object into a JSON string, including its properties and associations."

	| preHistoryFiles |
	preHistoryFiles := (aHistory preHistories collect: [ :each | each fileStore fileName ]) asArray.
	^ STONJSON toString: (Dictionary new
			   at: 'formatVersion' put: 1;
			   at: 'createdAt' put: createdAt asString;
			   at: 'modifiedAt' put: modifiedAt asString;
			   at: 'title' put: aHistory title;
			   at: 'provider' put: aHistory api class name asString;
			   at: 'model' put: aHistory api model;
			   at: 'preHistoryFiles' put: preHistoryFiles;
			   at: 'firstRoles' put: (aHistory firstRoles 
						collect: [ :each | self roleDictionaryFrom: each ]) asArray;
			   at: 'messages' put: (aHistory messages 
						collect: [ :each | self roleDictionaryFrom: each ]) asArray;
			   at: 'lastRoles' put: (aHistory lastRoles 
						collect: [ :each | self roleDictionaryFrom: each ]) asArray;
			   at: 'responseHeaderLevel' put: aHistory responseHearderLevel;
			   yourself)
]

{ #category : 'loading' }
AIAHistoryFileStore >> load [
	| json  |
	json := self fileReference readStreamDo: [ :stream |
		stream contents ].
	^ self historyFromJson: json
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStore >> loadFrom: aFileReference preHistoryLoader: aBlock [
	| json |
	rootDirectory := aFileReference parent.
	json := aFileReference readStreamDo: [ :stream |
		stream contents ].
	^ self
		historyFromJson: json
		preHistoryLoader: aBlock
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStore >> loadWithPreHistoryLoader: aBlock [
	| json |
	json := self fileReference readStreamDo: [ :stream |
		stream contents ].
	^ self
		historyFromJson: json
		preHistoryLoader: aBlock
]

{ #category : 'accessing' }
AIAHistoryFileStore >> roleDictionaryFrom: anAssociation [
	^ Dictionary new
		at: 'role' put: anAssociation key;
		at: 'content' put: anAssociation value;
		yourself
]

{ #category : 'accessing' }
AIAHistoryFileStore >> rootDirectory [
	^ rootDirectory
]

{ #category : 'accessing' }
AIAHistoryFileStore >> rootDirectory: aFileReference [
	rootDirectory := aFileReference
]

{ #category : 'actions' }
AIAHistoryFileStore >> save: aHistory [

	| file json |
	modifiedAt := DateAndTime now.
	file := self fileReference.
	file parent ensureCreateDirectory.
	json := self jsonFromHistory: aHistory.
	file writeStreamDo: [ :stream | stream nextPutAll: json ].
	^ file
]
