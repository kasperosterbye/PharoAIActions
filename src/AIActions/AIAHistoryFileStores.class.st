Class {
	#name : 'AIAHistoryFileStores',
	#superclass : 'Object',
	#instVars : [
		'rootDirectory',
		'historiesByFileName'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'actions' }
AIAHistoryFileStores >> loadAll [
	| histories files |
	histories := OrderedCollection new.
	historiesByFileName := Dictionary new.

	rootDirectory exists ifFalse: [
		^ histories ].

	files := rootDirectory files select: [ :file |
		file extension = 'json' ].

	files do: [ :file |
		histories add: (self loadFile: file) ].

	^ histories
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStores >> loadFile: aFileReference [
	| fileName history store |
	fileName := aFileReference basename.

	history := historiesByFileName
		at: fileName
		ifAbsent: [ nil ].
	history ifNotNil: [
		^ history ].

	store := AIAHistoryFileStore new.
	store rootDirectory: aFileReference parent.

	history := store
		loadFrom: aFileReference
		preHistoryLoader: [ :preHistoryFileName |
			self loadFile: aFileReference parent / preHistoryFileName ].
	historiesByFileName
		at: fileName
		put: history.

	^ history
]

{ #category : 'accessing' }
AIAHistoryFileStores >> rootDirectory [

	^ rootDirectory
]

{ #category : 'accessing' }
AIAHistoryFileStores >> rootDirectory: anObject [

	rootDirectory := anObject
]
