Class {
	#name : 'AIAHistoryPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAHistoryPresenter',
		'originalHistories'
	],
	#category : 'AIActions-Tests-UIPresenters-Tests',
	#package : 'AIActions-Tests',
	#tag : 'UIPresenters-Tests'
}

{ #category : 'running' }
AIAHistoryPresenterTest >> setUp [
	| history |
	super setUp.
	originalHistories := AIAHistory histories copy.
	AIAHistory clearHistories.

	history := AIAHistory new.
	history fileStore rootDirectory:
		FileSystem memory root / 'history'.
	history user: 'A message without an answer'.

	refAIAHistoryPresenter := AIAHistoryPresenter new
]

{ #category : 'running' }
AIAHistoryPresenterTest >> tearDown [
	SystemAnnouncer uniqueInstance
		unsubscribe: refAIAHistoryPresenter.
	AIAHistory clearHistories.
	AIAHistory histories addAll: originalHistories.
	super tearDown
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testPreHistoryHasRootAndReferenceOccurrences [
	"A stored pre-history remains available as its own editable root while
	also appearing as a read-only reference below every history using it."

	| historyTree currentHistory preHistory roots currentRoot preRoot preReference |
	historyTree := refAIAHistoryPresenter
		instVarNamed: #historyTree.
	currentHistory := AIAHistory histories first.

	preHistory := AIAHistory new.
	preHistory fileStore rootDirectory:
		currentHistory fileStore rootDirectory.
	preHistory user: 'Shared pre-history'.
	currentHistory addPreHistory: preHistory.

	roots := historyTree roots.
	currentRoot := roots detect: [ :node |
		node history == currentHistory ].
	preRoot := roots detect: [ :node |
		node history == preHistory ].
	preReference := currentRoot children first.

	self deny: preRoot isReference.
	self assert: preReference isReference.
	self assert: preReference history identicalTo: preRoot history
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testPresenterLoadsHistoriesFromDirectory [
	"Creating a presenter for a history directory must load its stored
	histories before constructing the history tree."

	| directory expectedMessages historyTree |
	directory := AIAHistory histories first fileStore rootDirectory.
	expectedMessages := AIAHistory histories first messages copy.

	SystemAnnouncer uniqueInstance
		unsubscribe: refAIAHistoryPresenter.
	AIAHistory clearHistories.

	refAIAHistoryPresenter :=
		AIAHistoryPresenter forDirectory: directory.
	historyTree := refAIAHistoryPresenter
		instVarNamed: #historyTree. 

	self assert: historyTree roots size equals: 1.
	self
		assert: historyTree roots first history messages
		equals: expectedMessages
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testPresenterLoadsPreHistoryReferencesFromDirectory [
	"Loading the presenter must reconstruct shared pre-histories. A stored
	pre-history appears as a root and as the identical referenced object."

	| directory preHistory currentHistory roots preRoot currentRoot reference |
	preHistory := AIAHistory histories first.
	directory := preHistory fileStore rootDirectory.

	currentHistory := AIAHistory new.
	currentHistory fileStore rootDirectory: directory.
	currentHistory user: 'History using shared context'.
	currentHistory addPreHistory: preHistory.

	SystemAnnouncer uniqueInstance
		unsubscribe: refAIAHistoryPresenter.
	AIAHistory clearHistories.

	refAIAHistoryPresenter :=
		AIAHistoryPresenter forDirectory: directory.
	roots := (refAIAHistoryPresenter instVarNamed: #historyTree) roots.

	preRoot := roots detect: [ :node |
		node history messages = preHistory messages ].
	currentRoot := roots detect: [ :node |
		node history messages = currentHistory messages ].
	reference := currentRoot children first.

	self deny: preRoot isReference.
	self assert: reference isReference.
	self assert: reference history identicalTo: preRoot history
]

{ #category : 'running' }
AIAHistoryPresenterTest >> testStoredHistoriesAreTreeRoots [
	"Every stored history must have one canonical top-level occurrence.
	Top-level occurrences are editable rather than references."

	| historyTree roots histories |
	historyTree := refAIAHistoryPresenter
		instVarNamed: #historyTree.
	roots := historyTree roots.
	histories := AIAHistory histories.

	self assert: roots size equals: histories size.
	roots with: histories do: [ :node :history |
		self assert: node history identicalTo: history.
		self deny: node isReference ]
]
