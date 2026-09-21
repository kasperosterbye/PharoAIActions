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

{ #category : 'misc' }
AIAHistoryFileStore >> descriptionFor: aHistory [
	"Use an explicit title when present. Otherwise use the first context
	or conversational text."

	| candidate |
	candidate := aHistory title.

	(candidate notNil and: [
		candidate asString isNotEmpty ])
		ifTrue: [
			^ candidate asString ].

	aHistory firstRoles ifNotEmpty: [
		^ aHistory firstRoles first value asString ].

	aHistory messages ifNotEmpty: [
		^ aHistory messages first value asString ].

	^ 'history'
]

{ #category : 'actions' }
AIAHistoryFileStore >> ensurePreHistoriesAreStoredFor: aHistory [
	"Every referenced history must have a permanent identifier before the
	current history is serialised."

	aHistory preHistories do: [ :preHistory |
		preHistory fileStore historyIdentifier ifNil: [
			preHistory fileStore save: preHistory ] ]
]

{ #category : 'accessing' }
AIAHistoryFileStore >> fileName [
	"Return the persisted filename, or a provisional ID before first save."

	storedFileName ifNotNil: [ ^ storedFileName ].
	^ self nextHistoryIdentifier, '.json'
]

{ #category : 'private' }
AIAHistoryFileStore >> fileNameFor: aHistory [
	"Construct the current readable filename while preserving an existing
	history identifier."

	| identifier |
	identifier := self historyIdentifier.

	identifier ifNil: [
		identifier := self nextHistoryIdentifier ].

	^ identifier,
		'-',
		(self slugFrom:
			(self descriptionFor: aHistory)),
		'.json'
]

{ #category : 'accessing' }
AIAHistoryFileStore >> fileReference [
	^ self rootDirectory / self fileName
]

{ #category : 'loading' }
AIAHistoryFileStore >> fileReferenceForHistoryIdentifier: anIdentifier [
	"Find the active JSON file whose first six characters identify the
	requested history. Its readable suffix is deliberately ignored."

	| identifier matches |
	identifier := self historyIdentifierFromFileName:
		anIdentifier.

	identifier ifNil: [
		self error: 'Invalid history identifier' ].

	rootDirectory exists ifFalse: [
		self error: 'History directory does not exist' ].

	matches := rootDirectory files select: [ :file |
		file extension = 'json' and: [
			(self historyIdentifierFromFileName:
				file basename) = identifier ] ].

	matches isEmpty ifTrue: [
		self error: 'History file not found: ', identifier ].

	matches size > 1 ifTrue: [
		self error: 'Duplicate history identifier: ', identifier ].

	^ matches first
]

{ #category : 'loading' }
AIAHistoryFileStore >> historyFiles [
	| files |
	files := OrderedCollection new.

	rootDirectory exists ifTrue: [
		files addAll:
			(rootDirectory files select: [ :file |
				file extension = 'json' ]) ].

	self trashDirectory exists ifTrue: [
		files addAll:
			(self trashDirectory files select: [ :file |
				file extension = 'json' ]) ].

	^ files
]

{ #category : 'loading' }
AIAHistoryFileStore >> historyFromJson: json [
	^ self
		historyFromJson: json
		preHistoryLoader: [ :identifier |
			self class loadFrom:
				(self fileReferenceForHistoryIdentifier:
					identifier) ]
]

{ #category : 'misc' }
AIAHistoryFileStore >> historyFromJson: json preHistoryLoader: aBlock [
	"Convert persisted JSON into an AIAHistory and reconstruct its
	pre-history associations."

	| aDictionary history providerClass api preHistoryReferences |
	aDictionary := STONJSON fromString: json.

	preHistoryReferences := aDictionary
		at: 'preHistoryIdentifiers'
		ifAbsent: [
			aDictionary
				at: 'preHistoryFiles'
				ifAbsent: [ #() ] ].

	createdAt := DateAndTime fromString:
		(aDictionary at: 'createdAt').

	modifiedAt := DateAndTime fromString:
		(aDictionary at: 'modifiedAt').

	providerClass := Smalltalk globals
		at: (aDictionary at: 'provider') asSymbol
		ifAbsent: [
			self error: 'Unknown API provider' ].

	(AilienApi allSubclasses includes: providerClass)
		ifFalse: [
			self error: 'Invalid API provider' ].

	api := providerClass new.
	api model:
		(aDictionary at: 'model').

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

	preHistoryReferences do: [ :identifier |
		history preHistories add:
			(aBlock value: identifier) ].

	^ history
]

{ #category : 'loading' }
AIAHistoryFileStore >> historyIdentifier [
	"Return the permanent identifier of a persisted history."

	storedFileName ifNil: [ ^ nil ].

	^ self historyIdentifierFromFileName:
		storedFileName
]

{ #category : 'loading' }
AIAHistoryFileStore >> historyIdentifierFromFileName: aFileName [
	"Extract an identifier such as H00127. Answer nil when the filename
	does not begin with a valid history identifier."

	| name digits |
	name := aFileName asString.
	name size < 6 ifTrue: [ ^ nil ].
	name first = $H ifFalse: [ ^ nil ].

	digits := name copyFrom: 2 to: 6.

	(digits allSatisfy: [ :character |
		character isDigit ])
		ifFalse: [ ^ nil ].

	^ name first: 6
]

{ #category : 'loading' }
AIAHistoryFileStore >> historyNumberFrom: aFileReference [
	| identifier |
	identifier := self historyIdentifierFromFileName:
		aFileReference basename.

	identifier ifNil: [ ^ 0 ].

	^ (identifier copyFrom: 2 to: 6) asInteger
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
	"Convert a history into JSON. Pre-histories are referenced by their
	permanent identifiers rather than their mutable filenames."

	| preHistoryIdentifiers |
	preHistoryIdentifiers :=
		(aHistory preHistories collect: [ :each |
			each fileStore historyIdentifier ]) asArray.

	^ STONJSON toString:
		(Dictionary new
			at: 'formatVersion' put: 2;
			at: 'createdAt' put: createdAt asString;
			at: 'modifiedAt' put: modifiedAt asString;
			at: 'title' put: aHistory title;
			at: 'provider'
				put: aHistory api class name asString;
			at: 'model' put: aHistory api model;
			at: 'preHistoryIdentifiers'
				put: preHistoryIdentifiers;
			at: 'firstRoles'
				put: (aHistory firstRoles collect: [ :each |
					self roleDictionaryFrom: each ]) asArray;
			at: 'messages'
				put: (aHistory messages collect: [ :each |
					self roleDictionaryFrom: each ]) asArray;
			at: 'lastRoles'
				put: (aHistory lastRoles collect: [ :each |
					self roleDictionaryFrom: each ]) asArray;
			at: 'responseHeaderLevel'
				put: aHistory responseHearderLevel;
			yourself)
]

{ #category : 'loading' }
AIAHistoryFileStore >> load [
	| json  |
	json := self fileReference readStreamDo: [ :stream |
		stream contents ].
	^ self historyFromJson: json
]

{ #category : 'loading' }
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

{ #category : 'loading' }
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

{ #category : 'accessing' }
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

{ #category : 'accessing' }
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
	| oldFile newFileName file json |
	self ensurePreHistoriesAreStoredFor: aHistory.

	modifiedAt := DateAndTime now.

	oldFile := storedFileName
		ifNil: [ nil ]
		ifNotNil: [
			self rootDirectory / storedFileName ].

	newFileName := self fileNameFor: aHistory.
	file := self rootDirectory / newFileName.

	(file exists and: [
		oldFile isNil or: [
			oldFile ~= file ] ])
		ifTrue: [
			self error:
				'History filename already exists: ',
				newFileName ].

	file parent ensureCreateDirectory.
	json := self jsonFromHistory: aHistory.

	file writeStreamDo: [ :stream |
		stream nextPutAll: json ].

	(oldFile notNil and: [
		oldFile ~= file and: [
			oldFile exists ] ])
		ifTrue: [
			oldFile delete ].

	storedFileName := newFileName.

	^ file
]

{ #category : 'private' }
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

{ #category : 'loading' }
AIAHistoryFileStore >> trashDirectory [
	^ self rootDirectory / 'Trash'
]
