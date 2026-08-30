Class {
	#name : 'AIAHistoryFileStore',
	#superclass : 'Object',
	#instVars : [
		'kindX',
		'createdAt',
		'modifiedAt'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'loading' }
AIAHistoryFileStore class >> loadFrom: aFileReference [
	| json |
	json := aFileReference readStreamDo: [ :stream |
		stream contents ].
	^ self new historyFromJson: json
]

{ #category : 'loading' }
AIAHistoryFileStore class >> rootDirectory [
	^ FileLocator home / 'D' / 'Pharo' / 'history'
]

{ #category : 'accessing' }
AIAHistoryFileStore >> associationFromRoleDictionary: aDictionary [
	^ (aDictionary at: 'role')
		-> (aDictionary at: 'content')
]

{ #category : 'accessing' }
AIAHistoryFileStore >> fileName [
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
	^ self class rootDirectory / self fileName
]

{ #category : 'actions' }
AIAHistoryFileStore >> historyFromJson: json [
	"Converts a dictionary into an AIAHistory object, initialising its properties and associations from the dictionary."
	| aDictionary history providerClass api |
	aDictionary := STONJSON fromString: json.
	(aDictionary at: 'preHistoryIds') ifNotEmpty: [
		self error:
			'Loading preHistories is not implemented yet' ].

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

	^ history
]

{ #category : 'initialization' }
AIAHistoryFileStore >> initialize [
	super initialize.
	createdAt := DateAndTime now.
	modifiedAt := createdAt
]

{ #category : 'actions' }
AIAHistoryFileStore >> jsonFromHistory: aHistory [
	"Converts an AIAHistory object into a JSON string, including its properties and associations."

	| preHistoryIds |
	preHistoryIds := (aHistory preHistories collect: [ :each |
			                  | store |
			                  store := each fileStore.
			                  store ifNil: [ self error: 'A preHistory has no fileStore' ].
			                  store id ]) asArray.
	^ STONJSON toString: (Dictionary new
			   at: 'formatVersion' put: 1;
			   at: 'createdAt' put: createdAt asString;
			   at: 'modifiedAt' put: modifiedAt asString;
			   at: 'title' put: aHistory title;
			   at: 'provider' put: aHistory api class name asString;
			   at: 'model' put: aHistory api model;
			   at: 'preHistoryIds' put: preHistoryIds;
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

{ #category : 'accessing' }
AIAHistoryFileStore >> roleDictionaryFrom: anAssociation [
	^ Dictionary new
		at: 'role' put: anAssociation key;
		at: 'content' put: anAssociation value;
		yourself
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
