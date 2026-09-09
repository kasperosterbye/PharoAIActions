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

	refAIAHistoryPresenter :=
	AIAHistoryPresenter forDirectory: history fileStore rootDirectory
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
AIAHistoryPresenterTest >> testAddInPharoModeRecordsExpressionAndResult [
	"In Pharo mode, Add must preserve the entered expression and its
	evaluated result. Both become visible parts of the history."

	| historyTree promptInput promptMode addButton history previousSize |
	historyTree := refAIAHistoryPresenter instVarNamed: #historyTree.
	promptInput := refAIAHistoryPresenter instVarNamed: #promptInput.
	promptMode := refAIAHistoryPresenter instVarNamed: #promptMode.
	addButton := refAIAHistoryPresenter instVarNamed: #addButton.

	historyTree selectItem: historyTree roots first.
	history := historyTree selectedItem history.
	previousSize := history messages size.

	promptMode selectIndex: 2.
	promptInput text: '40 + 2'.
	addButton action value.

	self assert: history messages size equals: previousSize + 2.
	self
		assert: (history messages at: previousSize + 1)
		equals: 'user' -> ':eval: 40 + 2'.
	self
		assert: (history messages at: previousSize + 2)
		equals: 'user' -> '42'
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
AIAHistoryPresenterTest >> testDeleteRemovesSelectedUnreferencedHistory [
	"Deleting an unreferenced root removes its file, its in-memory history
	and its root from the presenter."

	| historyTree deleteButton root history file |
	historyTree := refAIAHistoryPresenter
		instVarNamed: #historyTree.
	deleteButton := refAIAHistoryPresenter
		instVarNamed: #deleteButton.

	root := historyTree roots first.
	history := root history.
	file := history fileStore fileReference.
	historyTree selectItem: root.

	self assert: file exists.
	deleteButton action value.

	self deny: file exists.
	self deny: (AIAHistory histories anySatisfy: [ :each |
		each == history ]).
	self deny: (historyTree roots anySatisfy: [ :node |
		node history == history ])
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testDeletingHistoryKeepsItsPreHistories [
	"Deleting a history must delete only that history. Its pre-histories
	remain independently stored and available as editable roots."

	| historyTree deleteButton preHistory history
	  preHistoryFile historyFile root |

	historyTree := refAIAHistoryPresenter instVarNamed: #historyTree.
	deleteButton := refAIAHistoryPresenter instVarNamed: #deleteButton.

	preHistory := AIAHistory histories first.

	history := AIAHistory new.
	history fileStore rootDirectory:
		preHistory fileStore rootDirectory.
	history user: 'History using shared context'.
	history addPreHistory: preHistory.

	preHistoryFile := preHistory fileStore fileReference.
	historyFile := history fileStore fileReference.

	root := historyTree roots detect: [ :node |
		node history == history ].
	historyTree selectItem: root.

	deleteButton action value.

	self deny: historyFile exists.
	self assert: preHistoryFile exists.
	self assert: (AIAHistory histories anySatisfy: [ :each |
		each == preHistory ])
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testExternalHistoryCreationPreservesSelection [
	"Adding a history outside the presenter must refresh its tree without
	changing the history on which the user is currently working."

	| historyTree selectedHistory externalHistory |
	historyTree := refAIAHistoryPresenter
		instVarNamed: #historyTree.

	historyTree selectItem: historyTree roots first.
	selectedHistory := historyTree selectedItem history.

	externalHistory := AIAHistory new.
	externalHistory fileStore rootDirectory:
		selectedHistory fileStore rootDirectory.
	externalHistory user: 'An externally created history'.

	self assert: historyTree selectedItem isNotNil.
	self assert:
		historyTree selectedItem history
			identicalTo: selectedHistory
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testExternalMessageRefreshesSelectedConversation [
	"An external messageThis is a test message must refresh the displayed conversation."

	| historyTree messageText root |
	historyTree := refAIAHistoryPresenter instVarNamed: #historyTree.
	messageText := refAIAHistoryPresenter instVarNamed: #messageText.
	root := historyTree roots first.

	historyTree selectItem: root.
	messageText text: ''.

	root history user: 'Added outside the presenter'.

	self assert: (messageText text asString
		includesSubstring: 'Added outside the presenter')
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
	self assert: newHistory messages size equals: 1.
	self assert: newHistory messages first
		equals: 'user' -> 'An independent prompt'.
	self assert:
		(refAIAHistoryPresenter instVarNamed: #historyTree)
			selectedItem history
		identicalTo: newHistory.
	self assert: promptInput text equals: ''
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testNewStoresHistoryInPresenterDirectory [
	"New histories must be stored in the directory represented by the
	presenter, regardless of the factory history's initial file store."

	| directory wrongDirectory promptInput newButton createdHistory |
	directory := AIAHistory histories first fileStore rootDirectory.
	wrongDirectory := directory parent / 'wrong-history'.

	SystemAnnouncer uniqueInstance
		unsubscribe: refAIAHistoryPresenter.
	refAIAHistoryPresenter :=
		AIAHistoryPresenter forDirectory: directory.

	promptInput := refAIAHistoryPresenter instVarNamed: #promptInput.
	newButton := refAIAHistoryPresenter instVarNamed: #newButton.

	refAIAHistoryPresenter
		instVarNamed: #newHistoryFactory
		put: [
			createdHistory := AIAHistory new.
			createdHistory fileStore rootDirectory: wrongDirectory.
			createdHistory api: AIAHistoryPresenterTestApi new.
			createdHistory ].

	promptInput text: 'Stored in the presenter directory'.
	newButton action value.

	self
		assert: createdHistory fileStore rootDirectory
		equals: directory.
	self assert: createdHistory fileStore fileReference exists.
	self deny:
		(wrongDirectory / createdHistory fileStore fileName) exists
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
AIAHistoryPresenterTest >> testReferencedHistoryCannotBeDeleted [
	"A history used as pre-history must remain stored. Delete is disabled,
	and calling the action directly must still leave the history intact."

	| historyTree deleteButton preHistory currentHistory preRoot file |
	historyTree := refAIAHistoryPresenter
		instVarNamed: #historyTree.
	deleteButton := refAIAHistoryPresenter
		instVarNamed: #deleteButton.

	preHistory := AIAHistory histories first.
	file := preHistory fileStore fileReference.

	currentHistory := AIAHistory new.
	currentHistory fileStore rootDirectory:
		preHistory fileStore rootDirectory.
	currentHistory user: 'History using shared context'.
	currentHistory addPreHistory: preHistory.

	preRoot := historyTree roots detect: [ :node |
		node history == preHistory ].
	historyTree selectItem: preRoot.

	self deny: deleteButton isEnabled.

	deleteButton action value.

	self assert: file exists.
	self assert: (AIAHistory histories anySatisfy: [ :history |
		history == preHistory ])
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testReloadAfterFileDeletionClearsDisplayedConversation [
	"Reloading after deletion of the selected file must clear its display."

	| historyTree messageText reloadButton history |
	historyTree := refAIAHistoryPresenter instVarNamed: #historyTree.
	messageText := refAIAHistoryPresenter instVarNamed: #messageText.
	reloadButton := refAIAHistoryPresenter instVarNamed: #reloadButton.

	historyTree selectItem: historyTree roots first.
	history := historyTree selectedItem history.

	self assert: messageText text asString isNotEmpty.
	history fileStore delete.
	reloadButton action value.

	self assert: historyTree selectedItem isNil..
	self assert: messageText text asString isEmpty
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testReloadLoadsFileCreatedOutsidePresenter [
	"Reload must discard the current in-memory view and reconstruct the tree
	from the files, including files created while the presenter was open."

	| directory historyTree reloadButton initialSize externalHistory |
	directory := AIAHistory histories first fileStore rootDirectory.

	SystemAnnouncer uniqueInstance
		unsubscribe: refAIAHistoryPresenter.
	refAIAHistoryPresenter :=
		AIAHistoryPresenter forDirectory: directory.
	historyTree := refAIAHistoryPresenter instVarNamed: #historyTree.
	initialSize := historyTree roots size.

	"Prevent announcements from updating the presenter automatically."
	SystemAnnouncer uniqueInstance
		unsubscribe: refAIAHistoryPresenter.

	externalHistory := AIAHistory new.
	externalHistory fileStore rootDirectory: directory.
	externalHistory user: 'Created outside the presenter'.

	self assert: historyTree roots size equals: initialSize.

	reloadButton := refAIAHistoryPresenter
		instVarNamed: #reloadButton.
	reloadButton action value.

	self assert: historyTree roots size equals: initialSize + 1
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testReloadPreservesSelectedHistory [
	"Reloading must preserve the selected history when its file still exists.
	Object identity may change, but the persistent file remains the same."

	| directory historyTree reloadButton selectedFileName |
	directory := AIAHistory histories first fileStore rootDirectory.

	SystemAnnouncer uniqueInstance
		unsubscribe: refAIAHistoryPresenter.
	refAIAHistoryPresenter :=
		AIAHistoryPresenter forDirectory: directory.

	historyTree := refAIAHistoryPresenter
		instVarNamed: #historyTree.
	reloadButton := refAIAHistoryPresenter
		instVarNamed: #reloadButton.

	historyTree selectItem: historyTree roots first.
	selectedFileName :=
		historyTree selectedItem history fileStore fileName.

	reloadButton action value.

	self assert: historyTree selectedItem isNotNil.
	self
		assert: historyTree selectedItem history fileStore fileName
		equals: selectedFileName
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testReloadRemovesHistoryDeletedOutsidePresenter [
	"Reload must remove the history whose file was deleted externally,
	without assuming that the history directory contains no other files."

	| historyTree reloadButton root fileName |
	historyTree := refAIAHistoryPresenter instVarNamed: #historyTree.
	reloadButton := refAIAHistoryPresenter instVarNamed: #reloadButton.
	root := historyTree roots first.
	fileName := root history fileStore fileName.

	root history fileStore fileReference delete.

	self assert: (historyTree roots anySatisfy: [ :node |
		node history fileStore fileName = fileName ]).

	reloadButton action value.

	self deny: (AIAHistory histories anySatisfy: [ :history |
		history fileStore fileName = fileName ]).
	self deny: (historyTree roots anySatisfy: [ :node |
		node history fileStore fileName = fileName ])
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testSelectedHistoryDisplaysCompleteConversation [
	"The selected history must display every role and complete message
	in chronological order."

	| historyTree messageText root answer expected |
	historyTree := refAIAHistoryPresenter instVarNamed: #historyTree.
	messageText := refAIAHistoryPresenter instVarNamed: #messageText.
	root := historyTree roots first.

	answer := 'First answer line', String lf, 'Second answer line'.
	root history
		user: 'Second question';
		assistant: answer.

	historyTree selectItem: root.

	expected :=
		'user:', String lf,
		'A message without an answer', String lf, String lf,
		'user:', String lf,
		'Second question', String lf, String lf,
		'assistant:', String lf,
		answer.

	self assert: messageText text asString equals: expected
]

{ #category : 'tests' }
AIAHistoryPresenterTest >> testSelectingAnotherHistoryReplacesDisplayedConversation [
	"Selecting another history must replace the complete displayed text;
	content from the previous selection must not remain."

	| historyTree messageText firstRoot secondHistory secondRoot directory |
	historyTree := refAIAHistoryPresenter instVarNamed: #historyTree.
	messageText := refAIAHistoryPresenter instVarNamed: #messageText.
	firstRoot := historyTree roots first.
	directory := firstRoot history fileStore rootDirectory.

	secondHistory := AIAHistory new.
	secondHistory fileStore rootDirectory: directory.
	secondHistory user: 'Only in the second history'.

	secondRoot := historyTree roots detect: [ :node |
		node history == secondHistory ].

	historyTree selectItem: firstRoot.
	historyTree selectItem: secondRoot.

	self
		assert: messageText text asString
		equals: 'user:', String lf, 'Only in the second history'
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
