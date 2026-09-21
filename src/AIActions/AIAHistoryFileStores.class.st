Class {
	#name : 'AIAHistoryFileStores',
	#superclass : 'Object',
	#instVars : [
		'rootDirectory',
		'historiesByIdentifier'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'actions' }
AIAHistoryFileStores >> loadAll [
	| histories files |
	histories := OrderedCollection new.
	historiesByIdentifier := Dictionary new.

	rootDirectory exists ifFalse: [
		^ histories ].

	files := rootDirectory files select: [ :file |
		file extension = 'json' ].

	files do: [ :file |
		| history |
		history := self loadFile: file.

		(histories anySatisfy: [ :each |
			each == history ])
			ifFalse: [
				histories add: history ] ].

	^ histories
]

{ #category : 'loading' }
AIAHistoryFileStores >> loadFile: aFileReference [
	| identifier history store |
	store := AIAHistoryFileStore new.
	store rootDirectory:
		aFileReference parent.

	identifier := store historyIdentifierFromFileName:
		aFileReference basename.

	identifier ifNil: [
		self error:
			'Invalid history filename: ',
				aFileReference basename ].

	history := historiesByIdentifier
		at: identifier
		ifAbsent: [ nil ].

	history ifNotNil: [
		^ history ].

	history := store
		loadFrom: aFileReference
		preHistoryLoader: [ :preHistoryIdentifier |
			self loadHistoryIdentifier:
				preHistoryIdentifier ].

	historiesByIdentifier
		at: identifier
		put: history.

	^ history
]

{ #category : 'loading' }
AIAHistoryFileStores >> loadHistoryIdentifier: anIdentifier [
	| store file |
	store := AIAHistoryFileStore new.
	store rootDirectory: rootDirectory.

	file := store
		fileReferenceForHistoryIdentifier:
			anIdentifier.

	^ self loadFile: file
]

{ #category : 'accessing' }
AIAHistoryFileStores >> rootDirectory [

	^ rootDirectory
]

{ #category : 'accessing' }
AIAHistoryFileStores >> rootDirectory: anObject [

	rootDirectory := anObject
]
