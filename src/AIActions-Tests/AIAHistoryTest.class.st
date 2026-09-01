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
