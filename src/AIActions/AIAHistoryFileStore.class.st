Class {
	#name : 'AIAHistoryFileStore',
	#superclass : 'Object',
	#instVars : [
		'id',
		'kind',
		'createdAt',
		'modifiedAt'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
AIAHistoryFileStore class >> kind: aKind [
	^ self new
		kind: aKind;
		yourself
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStore class >> rootDirectory [
	^ FileLocator home / 'D' / 'Pharo' / 'history'
]

{ #category : 'actions' }
AIAHistoryFileStore >> dictionaryFrom: aHistory [
	| preHistoryIds |
	preHistoryIds := (aHistory preHistories collect: [ :each |
		| store |
		store := each fileStore.
		store ifNil: [
			self error: 'A preHistory has no fileStore' ].
		store id ]) asArray.

	^ Dictionary new
		at: 'formatVersion' put: 1;
		at: 'id' put: id;
		at: 'kind' put: kind;
		at: 'createdAt' put: createdAt asString;
		at: 'modifiedAt' put: modifiedAt asString;
		at: 'title' put: aHistory title;
		at: 'provider' put: aHistory api class name asString;
		at: 'model' put: aHistory api model;
		at: 'preHistoryIds' put: preHistoryIds;
		at: 'firstRoles' put:
			((aHistory firstRoles collect: [ :each |
				self roleDictionaryFrom: each ]) asArray);
		at: 'messages' put:
			((aHistory messages collect: [ :each |
				self roleDictionaryFrom: each ]) asArray);
		at: 'lastRoles' put:
			((aHistory lastRoles collect: [ :each |
				self roleDictionaryFrom: each ]) asArray);
		at: 'responseHeaderLevel' put: aHistory responseHearderLevel;
		yourself
]

{ #category : 'accessing' }
AIAHistoryFileStore >> fileName [
	| date time shortId createdString |
	createdString := createdAt asString.
	date := (createdString copyFrom: 1 to: 10)
		copyWithoutAll: '-'.
	time := (createdString copyFrom: 12 to: 19)
		copyWithoutAll: ':'.
	shortId := ((id copyWithoutAll: '-') first: 12)
		asUppercase.
	^ date, '-', time, '-', shortId, '.json'
]

{ #category : 'accessing' }
AIAHistoryFileStore >> fileReference [
	^ self class rootDirectory / kind / self fileName
]

{ #category : 'actions' }
AIAHistoryFileStore >> historyFrom: aDictionary [
]

{ #category : 'initialization' }
AIAHistoryFileStore >> initialize [
	super initialize.
	id := UUID new asString.
	createdAt := DateAndTime now.
	modifiedAt := createdAt
]

{ #category : 'accessing' }
AIAHistoryFileStore >> kind: aKind [
	kind := aKind asString
]

{ #category : 'loading' }
AIAHistoryFileStore >> load [
]

{ #category : 'as yet unclassified' }
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
	json := STONJSON toString:
		(self dictionaryFrom: aHistory).
	file writeStreamDo: [ :stream |
		stream nextPutAll: json ].
	^ file
]
