Class {
	#name : 'AIAHistoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAHistory',
		'rootDirectory',
		'originalHistories'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'running' }
AIAHistoryTest >> setUp [
	super setUp.
	originalHistories := AIAHistory histories copy.
	AIAHistory clearHistories.
	refAIAHistory := AIAHistory new.
	refAIAHistory class clearHistories.
	rootDirectory := FileSystem memory root / 'history'
]

{ #category : 'running' }
AIAHistoryTest >> tearDown [
	refAIAHistory class clearHistories.
	refAIAHistory class histories addAll: originalHistories.
	super tearDown
]

{ #category : 'tests' }
AIAHistoryTest >> testAddingUserMessageAnnouncesReplyChanged [
	"Adding a message outside the presenter must announce the change so an
	open presenter can refresh the displayed conversation."

	| wasAnnounced |
	wasAnnounced := false.
	refAIAHistory fileStore rootDirectory: rootDirectory.

	[
		SystemAnnouncer uniqueInstance
			when: AIAReplyChanged
			do: [ wasAnnounced := true ]
			for: self.

		refAIAHistory user: 'Message added outside the UI'.

		self assert: wasAnnounced
	] ensure: [
		SystemAnnouncer uniqueInstance unsubscribe: self ]
]

{ #category : 'tests' }
AIAHistoryTest >> testFirstMessageIsStoredWithoutAssigningFileStore [
	"A newly created history must persist its first message without the
	caller explicitly creating or assigning a file store."

	refAIAHistory fileStore rootDirectory: rootDirectory.
	refAIAHistory user: 'Automatically stored message'.

	self assert: rootDirectory files size equals: 1
]

{ #category : 'tests' }
AIAHistoryTest >> testReloadHistoriesDoesNotDuplicatePreHistories [
	"A history referenced as a pre-history also has its own file. Reloading
	must create exactly one object per file and reuse that same object in
	the reconstructed pre-history graph."

	| currentHistory preHistory currentStore preStore
	  histories loadedCurrent matchingPreHistories loadedPreHistory |

	currentStore := AIAHistoryFileStore new.
	currentStore rootDirectory: rootDirectory.

	preStore := AIAHistoryFileStore new.
	preStore rootDirectory: rootDirectory.

	preHistory := refAIAHistory class new.
	preHistory fileStore: preStore.
	preHistory user: 'Shared pre-history'.

	currentHistory := refAIAHistory.
	currentHistory fileStore: currentStore.
	currentHistory user: 'Current history'.
	currentHistory addPreHistory: preHistory.

	refAIAHistory class clearHistories.
	refAIAHistory class reloadHistoriesFrom: rootDirectory.
	histories := refAIAHistory class histories.

	loadedCurrent := histories detect: [ :each |
		each messages = currentHistory messages ].

	matchingPreHistories := histories select: [ :each |
		each messages = preHistory messages ].

	self assert: histories size equals: 2.
	self assert: matchingPreHistories size equals: 1.

	loadedPreHistory := matchingPreHistories first.
	self assert: loadedCurrent preHistories size equals: 1.
	self assert:
		loadedCurrent preHistories first == loadedPreHistory
]

{ #category : 'tests' }
AIAHistoryTest >> testReloadHistoriesRestoresAllStoredHistories [
	"Reloading must discard the current in-memory collection and reconstruct
	every stored history. File order is irrelevant; observable conversations
	must be preserved."

	| firstHistory secondHistory firstStore secondStore histories |
	firstStore := AIAHistoryFileStore new.
	firstStore rootDirectory: rootDirectory.
	secondStore := AIAHistoryFileStore new.
	secondStore rootDirectory: rootDirectory.

	firstHistory := refAIAHistory.
	firstHistory fileStore: firstStore.
	firstHistory user: 'First stored history'.

	secondHistory := AIAHistory new.
	secondHistory fileStore: secondStore.
	secondHistory user: 'Second stored history'.

	refAIAHistory class clearHistories.
	refAIAHistory class reloadHistoriesFrom: rootDirectory.
	histories := refAIAHistory class histories.

	self assert: histories size equals: 2.
	self assert: (histories anySatisfy: [ :each |
		each messages = firstHistory messages ]).
	self assert: (histories anySatisfy: [ :each |
		each messages = secondHistory messages ])
]
