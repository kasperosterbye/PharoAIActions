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
AIAHistoryPresenterTest >> testAddPromptAppendsUserMessageToSelectedRoot [
	"Add must append the entered text as a user message to the selected
	top-level history without requesting an AI response. The prompt field
	is cleared after the addition."

	| historyTree promptInput addButton root previousSize |
	historyTree := refAIAHistoryPresenter
		instVarNamed: #historyTree.
	promptInput := refAIAHistoryPresenter
		instVarNamed: #promptInput.
	addButton := refAIAHistoryPresenter
		instVarNamed: #addButton.

	root := historyTree roots first.
	previousSize := root history messages size.
	historyTree selectItem: root.
	promptInput text: 'A prompt added through the UI'.

	addButton action value.

	self
		assert: root history messages size
		equals: previousSize + 1.
	self
		assert: root history messages last
		equals: 'user' -> 'A prompt added through the UI'.
	self assert: promptInput text equals: ''
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testAddPromptDoesNotModifyReference [
	"A nested pre-history is a read-only reference. Add must therefore leave
	its underlying history unchanged."

	| directory preHistory currentHistory historyTree roots currentRoot
	  currentIndex reference promptInput addButton previousSize |

	preHistory := AIAHistory histories first.
	directory := preHistory fileStore rootDirectory.

	currentHistory := AIAHistory new.
	currentHistory fileStore rootDirectory: directory.
	currentHistory user: 'History using the pre-history'.
	currentHistory addPreHistory: preHistory.

	SystemAnnouncer uniqueInstance
		unsubscribe: refAIAHistoryPresenter.
	AIAHistory clearHistories.
	refAIAHistoryPresenter :=
		AIAHistoryPresenter forDirectory: directory.

	historyTree := refAIAHistoryPresenter instVarNamed: #historyTree.
	promptInput := refAIAHistoryPresenter instVarNamed: #promptInput.
	addButton := refAIAHistoryPresenter instVarNamed: #addButton.

	roots := historyTree roots.
	currentRoot := roots detect: [ :node |
		node history messages = currentHistory messages ].
	currentIndex := roots indexOf: currentRoot.
	historyTree selectItem: currentRoot.
	self assert: addButton isEnabled.
	
	historyTree selectPath:
		(Array with: currentIndex with: 1).
	reference := historyTree selectedItem.
	
	self deny: addButton isEnabled.
	
	previousSize := reference history messages size.

	promptInput text: 'This must not be added'.
	addButton action value.

	self assert: reference isReference.
	self assert: reference history messages size equals: previousSize
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testExternalMessageRefreshesSelectedConversation [
	"When the selected history changes outside the presenter, the reply
	announcement must refresh the message list."

	| historyTree messageList root |
	historyTree := refAIAHistoryPresenter
		instVarNamed: #historyTree.
	messageList := refAIAHistoryPresenter
		instVarNamed: #messageList.
	root := historyTree roots first.

	historyTree selectItem: root.
	messageList items: #().

	root history user: 'Added outside the presenter'.

	self
		assert: messageList items
		equals: root history messages
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testNewPromptCreatesIndependentHistory [
	"New creates an independent history, sends the entered prompt, selects
	the new root and leaves the new history without pre-histories."

	| promptInput newButton directory previousSize newHistory |
	promptInput := refAIAHistoryPresenter
		instVarNamed: #promptInput.
	newButton := refAIAHistoryPresenter
		instVarNamed: #newButton.
	directory := AIAHistory histories first fileStore rootDirectory.
	previousSize := AIAHistory histories size.

	refAIAHistoryPresenter
		instVarNamed: #newHistoryFactory
		put: [
			| history |
			history := AIAHistory new.
			history fileStore rootDirectory: directory.
			history api: AIAHistoryPresenterTestApi new.
			history ].

	promptInput text: 'An independent prompt'.
	newButton action value.
	newHistory := AIAHistory histories last.

	self assert: AIAHistory histories size equals: previousSize + 1.
	self assert: newHistory preHistories isEmpty.
	self assert: newHistory messages first
		equals: 'user' -> 'An independent prompt'.
	self assert: newHistory messages last
		equals: 'assistant' -> 'Deterministic test response'.
	self assert:
		(refAIAHistoryPresenter instVarNamed: #historyTree)
			selectedItem history
		identicalTo: newHistory.
	self assert: promptInput text equals: ''
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

{ #category : 'tests' }
AIAHistoryPresenterTest >> testSelectingHistoryDisplaysAllMessages [
	"Selecting a history root must display the complete conversation in the
	message list, preserving roles, contents and order."

	| historyTree messageList root |
	historyTree := refAIAHistoryPresenter
		instVarNamed: #historyTree.
	messageList := refAIAHistoryPresenter
		instVarNamed: #messageList.
	root := historyTree roots first.

	historyTree selectItem: root.

	self
		assert: messageList items
		equals: root history messages
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testSendPromptAddsUserAndAssistantMessages [
	"Send adds the prompt to the selected root, requests a response and
	clears the prompt field."

	| historyTree promptInput sendButton root previousSize |
	historyTree := refAIAHistoryPresenter instVarNamed: #historyTree.
	promptInput := refAIAHistoryPresenter instVarNamed: #promptInput.
	sendButton := refAIAHistoryPresenter instVarNamed: #sendButton.

	root := historyTree roots first.
	root history api: AIAHistoryPresenterTestApi new.
	previousSize := root history messages size.
	historyTree selectItem: root.
	promptInput text: 'Prompt sent through the UI'.

	sendButton action value.

	self assert: root history messages size equals: previousSize + 2.
	self assert: root history messages last
		equals: 'assistant' -> 'Deterministic test response'.
	self assert: promptInput text equals: ''
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
