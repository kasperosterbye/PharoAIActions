Class {
	#name : 'AIAHistoryFileStoresTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAHistoryFileStores',
		'rootDirectory',
		'originalHistories'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'running' }
AIAHistoryFileStoresTest >> setUp [
	super setUp.
	originalHistories := AIAHistory histories copy.
	AIAHistory clearHistories.
	rootDirectory := FileSystem memory root / 'history'.
	refAIAHistoryFileStores := AIAHistoryFileStores new.
	refAIAHistoryFileStores rootDirectory: rootDirectory
]

{ #category : 'running' }
AIAHistoryFileStoresTest >> tearDown [
	AIAHistory clearHistories.
	AIAHistory histories addAll: originalHistories.
	super tearDown
]

{ #category : 'tests' }
AIAHistoryFileStoresTest >> testLoadAllLoadsEveryFileOnce [
	"Each stored file represents one observable history. Loading all files
	must reconstruct every conversation exactly once; file order is irrelevant."

	| firstStore secondStore firstHistory secondHistory histories |
	firstStore := AIAHistoryFileStore new.
	firstStore rootDirectory: rootDirectory.
	secondStore := AIAHistoryFileStore new.
	secondStore rootDirectory: rootDirectory.

	firstHistory := AIAHistory new.
	firstHistory fileStore: firstStore.
	firstHistory user: 'First history'.

	secondHistory := AIAHistory new.
	secondHistory fileStore: secondStore.
	secondHistory user: 'Second history'.

	AIAHistory clearHistories.
	histories := refAIAHistoryFileStores loadAll.

	self assert: histories size equals: 2.
	self assert: (histories anySatisfy: [ :each |
		each messages = firstHistory messages ]).
	self assert: (histories anySatisfy: [ :each |
		each messages = secondHistory messages ])
]

{ #category : 'tests' }
AIAHistoryFileStoresTest >> testLoadAllReusesPreHistoryObject [
	"A pre-history has its own file and may also be referenced by another
	history. Loading all files must create one object per file and reuse that
	object in the reconstructed graph."

	| preStore currentStore preHistory currentHistory
	  histories loadedCurrent matchingPreHistories loadedPreHistory |

	preStore := AIAHistoryFileStore new.
	preStore rootDirectory: rootDirectory.
	currentStore := AIAHistoryFileStore new.
	currentStore rootDirectory: rootDirectory.

	preHistory := AIAHistory new.
	preHistory fileStore: preStore.
	preHistory user: 'Shared pre-history'.

	currentHistory := AIAHistory new.
	currentHistory fileStore: currentStore.
	currentHistory user: 'Current history'.
	currentHistory addPreHistory: preHistory.

	AIAHistory clearHistories.
	histories := refAIAHistoryFileStores loadAll.

	loadedCurrent := histories detect: [ :each |
		each messages = currentHistory messages ].
	matchingPreHistories := histories select: [ :each |
		each messages = preHistory messages ].

	self assert: histories size equals: 2.
	self assert: matchingPreHistories size equals: 1.

	loadedPreHistory := matchingPreHistories first.
	self assert:
		loadedCurrent preHistories first == loadedPreHistory
]
