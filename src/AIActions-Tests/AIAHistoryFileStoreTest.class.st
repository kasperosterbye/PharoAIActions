Class {
	#name : 'AIAHistoryFileStoreTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAHistoryFileStore',
		'originalRootDirectory',
		'originalHistories'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'running' }
AIAHistoryFileStoreTest >> setUp [
	super setUp.
	originalHistories := AIAHistory histories copy.
	AIAHistory clearHistories.

	refAIAHistoryFileStore := AIAHistoryFileStore new.
	refAIAHistoryFileStore rootDirectory:
		(FileSystem memory root / 'history')
]

{ #category : 'running' }
AIAHistoryFileStoreTest >> tearDown [
	AIAHistory clearHistories.
	AIAHistory histories addAll: originalHistories.
	super tearDown
]

{ #category : 'tests' }
AIAHistoryFileStoreTest >> testLoadFromPreservesFileReference [
	"A history loaded from a file must remain connected to that same file.
	Future changes must not accidentally be written to another directory."

	| history file loadedHistory |
	history := AIAHistory new.
	file := refAIAHistoryFileStore save: history.

	loadedHistory := AIAHistoryFileStore loadFrom: file.

	self
		assert: loadedHistory fileStore fileReference
		equals: file
]

{ #category : 'tests' }
AIAHistoryFileStoreTest >> testNewStoreHasStableJsonFileName [
	"A newly created file store must have a stable filename before anything
	is saved. Repeated requests must return the same JSON filename."

	| fileName |
	fileName := refAIAHistoryFileStore fileName.

	self assert: fileName equals: refAIAHistoryFileStore fileName.
	self assert: (fileName endsWith: '.json')
]

{ #category : 'tests' }
AIAHistoryFileStoreTest >> testSaveCreatesJsonFile [
	"Saving a history must create a readable JSON file. The test uses an
	in-memory filesystem, so no real history files are created or deleted."

	| history file |
	history := AIAHistory new.

	file := refAIAHistoryFileStore save: history.

	self assert: file exists.
	self assert: file extension equals: 'json'
]

{ #category : 'tests' }
AIAHistoryFileStoreTest >> testSavedHistoryCanBeLoaded [
	"A stored history is useful only if loading reconstructs the same
	observable conversation, including roles, contents and order."

	| history loadedHistory |
	history := AIAHistory new.
	history fileStore: refAIAHistoryFileStore.
	history user: 'Who is Kilroy?'.
	history assistant: 'A test response'.

	loadedHistory := refAIAHistoryFileStore load.

	self assert: loadedHistory messages equals: history messages
]

{ #category : 'tests' }
AIAHistoryFileStoreTest >> testSavedHistoryCanBeLoaded02 [
	"A stored history is useful only if loading reconstructs the same
	observable conversation, including roles, contents and order."

	| history loadedHistory |
	history := AIAHistory new.
	history fileStore: refAIAHistoryFileStore.
	history user: 'Who is Kilroy?'.
	history user: 'Does he have a last name?'.
	history assistant: 'A test response'.

	loadedHistory := refAIAHistoryFileStore load.

	self assert: loadedHistory messages equals: history messages
]

{ #category : 'tests' }
AIAHistoryFileStoreTest >> testSavedHistoryPreservesContext [
	"A stored history must preserve its title, initial roles, final roles,
	response header level, provider and model."

	| history loadedHistory |
	history := AIAHistory new.
	history
		title: 'Kilroy discussion';
		system: 'Answer precisely';
		background: 'Kilroy was here';
		responseType: 'Short answer';
		responseHearderLevel: 3.

	refAIAHistoryFileStore save: history.
	loadedHistory := refAIAHistoryFileStore load.

	self assert: loadedHistory title equals: history title.
	self assert: loadedHistory firstRoles equals: history firstRoles.
	self assert: loadedHistory lastRoles equals: history lastRoles.
	self
		assert: loadedHistory responseHearderLevel
		equals: history responseHearderLevel.
	self assert: loadedHistory api class equals: history api class.
	self assert: loadedHistory api model equals: history api model
]

{ #category : 'tests' }
AIAHistoryFileStoreTest >> testSavedHistoryPreservesNestedPreHistories [
	"A pre-history may itself have a pre-history. Saving and loading the
	current history must reconstruct the complete nested structure without
	flattening it or losing any messages."

	| oldestStore middleStore
	  oldestHistory middleHistory currentHistory
	  loadedCurrent loadedMiddle loadedOldest |

	oldestStore := AIAHistoryFileStore new.
	oldestStore rootDirectory:
		refAIAHistoryFileStore rootDirectory.

	middleStore := AIAHistoryFileStore new.
	middleStore rootDirectory:
		refAIAHistoryFileStore rootDirectory.

	oldestHistory := AIAHistory new.
	oldestHistory fileStore: oldestStore.
	oldestHistory user: 'The oldest context'.

	middleHistory := AIAHistory new.
	middleHistory fileStore: middleStore.
	middleHistory user: 'The middle context'.
	middleHistory addPreHistory: oldestHistory.

	currentHistory := AIAHistory new.
	currentHistory fileStore: refAIAHistoryFileStore.
	currentHistory addPreHistory: middleHistory.

	loadedCurrent := refAIAHistoryFileStore load.
	loadedMiddle := loadedCurrent preHistories first.
	loadedOldest := loadedMiddle preHistories first.

	self assert: loadedCurrent preHistories size equals: 1.
	self assert: loadedMiddle preHistories size equals: 1.
	self assert: loadedOldest preHistories isEmpty.

	self
		assert: loadedMiddle messages
		equals: middleHistory messages.
	self
		assert: loadedOldest messages
		equals: oldestHistory messages
]

{ #category : 'tests' }
AIAHistoryFileStoreTest >> testSavedHistoryPreservesPreHistory [
	"A stored history must preserve its reference to a pre-history.
	Loading it must reconstruct the referenced history and its messages."

	| preStore preHistory history loadedHistory loadedPreHistory |
	preStore := AIAHistoryFileStore new.
	preStore rootDirectory: refAIAHistoryFileStore rootDirectory.

	preHistory := AIAHistory new.
	preHistory fileStore: preStore.
	preHistory user: 'Kilroy was here'.

	history := AIAHistory new.
	history fileStore: refAIAHistoryFileStore.
	history addPreHistory: preHistory.
	refAIAHistoryFileStore save: history.

	loadedHistory := refAIAHistoryFileStore load.
	loadedPreHistory := loadedHistory preHistories first.

	self assert: loadedHistory preHistories size equals: 1.
	self assert: loadedPreHistory messages equals: preHistory messages.
	self
		assert: loadedPreHistory fileStore fileReference
		equals: preHistory fileStore fileReference
]
