"
AIAHistoryFileStore persists and loads AIAHistory conversations as files, allowing histories to be saved and restored between Pharo sessions.
"
Class {
	#name : 'AIAHistoryFileStore',
	#superclass : 'Object',
	#instVars : [
		'createdAt',
		'modifiedAt',
		'rootDirectory',
		'storedFileName'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'loading' }
AIAHistoryFileStore class >> loadFrom: aFileReference [
	"Load a history store from a file reference."

	| json store |
	json := aFileReference readStreamDo: [ :stream |
		stream contents ].

	store := self new.
	store
		rootDirectory: aFileReference parent;
		storedFileName: aFileReference basename.

	^ store historyFromJson: json
]

{ #category : 'accessing' }
AIAHistoryFileStore >> associationFromRoleDictionary: aDictionary [
	^ (aDictionary at: 'role')
		-> (aDictionary at: 'content')
]

{ #category : 'accessing' }
AIAHistoryFileStore >> createdAt [
	^ createdAt
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
	"Return the persisted filename, or a provisional ID before first save."

	storedFileName ifNotNil: [ ^ storedFileName ].
	^ self nextHistoryIdentifier, '.json'
]

{ #category : 'accessing' }
AIAHistoryFileStore >> fileReference [
	^ self rootDirectory / self fileName
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStore >> historyFiles [
	| files |
	files := OrderedCollection new.

	rootDirectory exists ifTrue: [
		files addAll: rootDirectory files ].

	self trashDirectory exists ifTrue: [
		files addAll: self trashDirectory files ].

	^ files
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

{ #category : 'as yet unclassified' }
AIAHistoryFileStore >> historyNumberFrom: aFileReference [
	| name digits |
	name := aFileReference basename.
	name size < 6 ifTrue: [ ^ 0 ].
	name first = $H ifFalse: [ ^ 0 ].

	digits := name copyFrom: 2 to: 6.
	(digits allSatisfy: [ :character |
		character isDigit ]) ifFalse: [ ^ 0 ].

	^ digits asInteger
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
	storedFileName := aFileReference basename.
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
AIAHistoryFileStore >> modifiedAt [
	^ modifiedAt
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStore >> moveToTrash [
	| source destination |
	source := self fileReference.
	source exists ifFalse: [ ^ nil ].

	self trashDirectory ensureCreateDirectory.
	destination := self trashDirectory / self fileName.

	destination exists ifTrue: [
		self error: 'History already exists in Trash' ].

	source moveTo: destination.
	^ destination
]

{ #category : 'instance creation' }
AIAHistoryFileStore >> newFileNameFor: aHistory [
	| description |
	description := aHistory title
		ifNil: [ aHistory printPrompt ].

	^ self nextHistoryIdentifier,
		'-',
		(self slugFrom: description),
		'.json'
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStore >> nextHistoryIdentifier [
	| largest next |
	largest := self historyFiles
		inject: 0
		into: [ :maximum :file |
			maximum max: (self historyNumberFrom: file) ].

	next := largest + 1.
	next > 99999 ifTrue: [
		self error: 'No more history identifiers available' ].

	^ 'H', (('00000', next asString) last: 5)
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

	storedFileName ifNil: [
		storedFileName := self newFileNameFor: aHistory ].

	file := self fileReference.
	file parent ensureCreateDirectory.
	json := self jsonFromHistory: aHistory.

	file writeStreamDo: [ :stream |
		stream nextPutAll: json ].

	^ file
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStore >> slugFrom: aString [
	| slug previousWasSeparator |
	previousWasSeparator := true.

	slug := String streamContents: [ :stream |
		aString asLowercase do: [ :character |
			character isAlphaNumeric
				ifTrue: [
					stream nextPut: character.
					previousWasSeparator := false ]
				ifFalse: [
					previousWasSeparator ifFalse: [
						stream nextPut: $-.
						previousWasSeparator := true ] ] ] ].

	slug := slug first: (40 min: slug size).

	[ slug notEmpty and: [ slug last = $- ] ] whileTrue: [
		slug := slug allButLast ].

	^ slug ifEmpty: [ 'history' ]
]

{ #category : 'accessing' }
AIAHistoryFileStore >> storedFileName: aString [
	storedFileName := aString
]

{ #category : 'as yet unclassified' }
AIAHistoryFileStore >> trashDirectory [
	^ self rootDirectory / 'Trash'
]
