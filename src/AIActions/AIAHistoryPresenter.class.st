"
# Class Comment for AIAHistoryPresenter

The `AIAHistoryPresenter` is a Spec2 presenter designed to display and manage AI interaction history. It provides a user interface for viewing past AI conversations, prompts, and responses in a structured layout.

## Features

- Displays a list of AI history sessions
- Shows individual prompts and responses
- Provides text areas for viewing and editing content
- Organises content in a horizontal split layout with left and right panels

## Usage Example

```smalltalk
""AIAHistoryPresenter example usage in Playground""

""Open the presenter""
presenter := AIAHistoryPresenter new.
presenter open.

""Inspect the presenter's components""
presenter inspect
```

This presenter is part of the AIActions package and is tagged as an 'Experiments' class.
"
Class {
	#name : 'AIAHistoryPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'historyTree',
		'historyDetails',
		'messageText',
		'promptInput',
		'addButton',
		'sendButton',
		'newButton',
		'evalButton',
		'newHistoryFactory',
		'rootDirectory',
		'reloadButton',
		'deleteButton'
	],
	#category : 'AIActions-UIPresenters',
	#package : 'AIActions',
	#tag : 'UIPresenters'
}

{ #category : 'as yet unclassified' }
AIAHistoryPresenter class >> forDirectory: aDirectory [
	| presenter |
	AIAHistory reloadHistoriesFrom: aDirectory.
	presenter := self new.
	presenter rootDirectory: aDirectory.
	^ presenter
]

{ #category : 'examples' }
AIAHistoryPresenter class >> open [
	<example>

	^ (self forDirectory:
		AIAHistoryFileStore new rootDirectory)
			open
]

{ #category : 'visiting' }
AIAHistoryPresenter >> acceptHistoryDetail: anAssociation value: aString [
	| selectedNode history |
	selectedNode := historyTree selectedItem.

	selectedNode ifNil: [
		historyDetails items: #().
		^ self ].

	(anAssociation key = 'Title'
		and: [ selectedNode isReference not ])
		ifFalse: [
			self displayDetailsForHistory: selectedNode history.
			^ self ].

	history := selectedNode history.
	history title:
		(aString
			ifEmpty: [ nil ]
			ifNotEmpty: [ aString ]).
	history fileStore save: history.

	self displayDetailsForHistory: history.

	SystemAnnouncer uniqueInstance
		announce: AIAHistoriesChanged new
]

{ #category : 'adding' }
AIAHistoryPresenter >> addPrompt [
	| selectedNode prompt |
	selectedNode := historyTree selectedItem.
	selectedNode ifNil: [ ^ self ].
	selectedNode isReference ifTrue: [ ^ self ].

	prompt := promptInput text asString.
	prompt ifEmpty: [ ^ self ].

	self addPrompt: prompt to: selectedNode history.
	promptInput text: ''
]

{ #category : 'adding' }
AIAHistoryPresenter >> addPrompt: aString to: aHistory [
	| shouldEvaluate evaluatedPrompt |
	shouldEvaluate := evalButton state.
	evalButton state: false.

	shouldEvaluate ifFalse: [
		aHistory user: aString.
		^ self ].

	evaluatedPrompt :=
		(OpalCompiler new evaluate: aString) asString.

	aHistory user: ':eval: ', aString.
	aHistory user: evaluatedPrompt
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> assocString: assoc [
	^ assoc key, String lf, assoc value
]

{ #category : 'testing' }
AIAHistoryPresenter >> canDeleteNode: aNode [
	aNode ifNil: [ ^ false ].
	aNode isReference ifTrue: [ ^ false ].

	^ (AIAHistory histories anySatisfy: [ :history |
		history preHistories anySatisfy: [ :preHistory |
			preHistory == aNode history ] ]) not
]

{ #category : 'testing' }
AIAHistoryPresenter >> canDeleteNodes: nodes [
	nodes ifEmpty: [ ^ false ].

	^ nodes allSatisfy: [ :node |
		self canDeleteNode: node ]
]

{ #category : 'layout' }
AIAHistoryPresenter >> defaultLayout [
	| left leftContent right both composer composerButtons leftButtons |

	composerButtons := SpBoxLayout newLeftToRight
		add: addButton;
		add: sendButton;
		add: SpBoxLayout newLeftToRight;
		add: evalButton;
		add: SpBoxLayout newLeftToRight;
		add: newButton;
		yourself.

	composer := SpBoxLayout newTopToBottom
		add: promptInput;
		add: composerButtons expand: false;
		yourself.

	leftButtons := SpBoxLayout newLeftToRight
		add: reloadButton expand: false;
		add: deleteButton expand: false;
		yourself.

	leftContent := SpPanedLayout newVertical
		add: historyTree;
		add: historyDetails;
		yourself.

	left := SpBoxLayout newTopToBottom
		add: leftContent;
		add: leftButtons expand: false;
		yourself.

	right := SpPanedLayout newVertical
		add: messageText;
		add: composer;
		yourself.

	both := SpPanedLayout newHorizontal
		add: left;
		add: right;
		yourself.

	^ both
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> deleteSelectedHistories [
	| selectedNodes histories |
	selectedNodes := historyTree selectedItems.
	(self canDeleteNodes: selectedNodes) ifFalse: [ ^ self ].

	histories := selectedNodes collect: [ :node |
		node history ].

	histories do: [ :history |
		history fileStore moveToTrash.
		AIAHistory histories
			remove: history
			ifAbsent: [ ] ].

	SystemAnnouncer uniqueInstance
		announce: AIAHistoriesChanged new
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> deleteSelectedHistory [
	| selectedNode history |
	selectedNode := historyTree selectedItem.
	(self canDeleteNode: selectedNode) ifFalse: [ ^ self ].

	history := selectedNode history.
	history fileStore delete.
	AIAHistory histories
		remove: history
		ifAbsent: [ ^ self ].

	SystemAnnouncer uniqueInstance
		announce: AIAHistoriesChanged new
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> detailsForHistory: aHistory [
	| fileStore usedBy |
	fileStore := aHistory fileStore.
	usedBy := AIAHistory histories select: [ :history |
		history preHistories anySatisfy: [ :preHistory |
			preHistory == aHistory ] ].

	^ OrderedDictionary new
		at: 'Title'
			put: (aHistory title ifNil: [ '' ]);
		at: 'Created'
			put: fileStore createdAt asString;
		at: 'Modified'
			put: fileStore modifiedAt asString;
		at: 'Pre-histories'
			put: (self historyListString: aHistory preHistories);
		at: 'Used by'
			put: (self historyListString: usedBy);
		yourself
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> displayDetailsForHistory: aHistory [
	historyDetails items:
		(self detailsForHistory: aHistory) associations
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> displayHistory: aHistory [
	self displayMessages: aHistory apiMessageList
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> displayMessages: messages [
	messageText ifNil: [ ^ self ].
	messageText text:
		(self stringFromMessages: messages)
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> getHistoryTreeRoots [
	| sortedHistories |
	sortedHistories := AIAHistory histories sorted: [ :first :second |
		first fileStore modifiedAt >
			second fileStore modifiedAt ].

	^ sortedHistories collect: [ :history |
		AIAHistoryPresenterTreeNode rootFor: history ]
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> historyActions [
	historyTree
		roots: self getHistoryTreeRoots;
		children: [ :node | node children ];
		display: [ :node |  self historyLabelFor: node  ];
		displayItalic: [ :node | node isReference ].
	self
		historyObserveTree;
		historyChangeAction
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> historyChangeAction [
	historyTree whenMultiSelectionChangedDo: [ :selection |
		| selectedNodes selected |
		selectedNodes := historyTree selectedItems.

		selected := selectedNodes size = 1
			ifTrue: [ selectedNodes first ]
			ifFalse: [ nil ].

		addButton enabled:
			(selected notNil and: [ selected isReference not ]).
		sendButton enabled:
			(selected notNil and: [ selected isReference not ]).
		deleteButton enabled:
			(self canDeleteNodes: selectedNodes).

		selected
			ifNil: [
				self displayMessages: #().
				historyDetails items: #() ]
			ifNotNil: [
				self displayHistory: selected history.
				self displayDetailsForHistory: selected history ] ]
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> historyLabelFor: aNode [
	| history |
	history := aNode history.

	^ history title
		ifNil: [ '• ', history printString ]
		ifNotNil: [ history printString ]
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> historyListString: histories [
	^ ', ' join: (histories collect: [ :history |
		history printString ])
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> historyObserveTree [
	SystemAnnouncer uniqueInstance
		when: AIAHistoriesChanged
		do: [ self refreshHistoryTreePreservingSelection ]
		for: self
]

{ #category : 'initialization' }
AIAHistoryPresenter >> initializePresenters [
	super initializePresenters.

	messageText := self newText.
	messageText beNotEditable.

	historyTree := self newTree.
	historyTree beMultipleSelection.
	historyDetails := self newTable.
	historyDetails
		addColumn: (SpStringTableColumn
			title: 'Property'
			evaluated: [ :association | association key ]);
		addColumn: ((SpStringTableColumn
			title: 'Value'
			evaluated: [ :association | association value ])
				beEditable;
				onAcceptEdition: [ :association :newValue |
					self
						acceptHistoryDetail: association
						value: newValue ];
				yourself);
		items: #().

	promptInput := self newText.

	evalButton := self newToggleButton
		label: 'Eval';
		yourself.

	addButton := self newButton
		label: 'Add';
		action: [ self addPrompt ];
		yourself.
	addButton disable.

	sendButton := self newButton
		label: 'Send';
		action: [ self sendPrompt ];
		yourself.
	sendButton disable.

	newHistoryFactory := [ AIAHistory new ].

	newButton := self newButton
		label: 'New';
		action: [ self newPrompt ];
		yourself.

	rootDirectory ifNil: [
		rootDirectory := AIAHistoryFileStore new rootDirectory ].

	reloadButton := self newButton
		label: 'Reload';
		action: [ self reloadHistories ];
		yourself.

	deleteButton := self newButton
		label: 'Delete';
		action: [ self deleteSelectedHistories ];
		yourself.
	deleteButton disable.

	self historyActions.
	self messageActions
]

{ #category : 'initialization' }
AIAHistoryPresenter >> initializeWindow: aWindow [
    super initializeWindow: aWindow.
    aWindow title: 'AIA History'.
    aWindow whenClosedDo: [
        SystemAnnouncer uniqueInstance unsubscribe: self ].
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> messageActions [
	self
		displayMessages: #();
		messageRefreshTree
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> messageRefreshTree [
	| selected |
	SystemAnnouncer uniqueInstance
		when: AIAReplyChanged
		do: [
			self refreshHistoryTreePreservingSelection.
			selected := historyTree selectedItem.
			selected ifNotNil: [
				self displayHistory: selected history.
				self displayDetailsForHistory:
					selected history ] ]
		for: self
]

{ #category : 'instance creation' }
AIAHistoryPresenter >> newPrompt [
	| prompt history root |
	prompt := promptInput text asString.
	prompt ifEmpty: [ ^ self ].

	history := newHistoryFactory value.
	history fileStore rootDirectory: rootDirectory.

	root := historyTree roots
		detect: [ :node | node history == history ].
	historyTree selectItem: root.

	self addPrompt: prompt to: history.

	promptInput text: ''
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> refreshHistoryTreePreservingSelection [
	| selectedHistories roots replacements |
	selectedHistories := historyTree selectedItems collect: [ :node |
		node history ].

	roots := self getHistoryTreeRoots.
	historyTree roots: roots.

	selectedHistories ifEmpty: [ ^ self ].

	replacements := roots select: [ :node |
		selectedHistories anySatisfy: [ :history |
			node history == history ] ].

	replacements ifNotEmpty: [
		historyTree selectItems: replacements ]
]

{ #category : 'history globals' }
AIAHistoryPresenter >> reloadHistories [
	| selectedNode selectedFileName selectedRoot |
	selectedNode := historyTree selectedItem.
	selectedFileName := nil.

	selectedNode ifNotNil: [
		selectedFileName :=
			selectedNode history fileStore fileName ].

	AIAHistory reloadHistoriesFrom: rootDirectory.
	historyTree roots: self getHistoryTreeRoots.

	selectedFileName ifNil: [ ^ self ].

	selectedRoot := historyTree roots
		detect: [ :node |
			node history fileStore fileName = selectedFileName ]
		ifNone: [ ^ self ].

	historyTree selectItem: selectedRoot
]

{ #category : 'accessing' }
AIAHistoryPresenter >> rootDirectory: aDirectory [
	rootDirectory := aDirectory
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> sendPrompt [
	| selectedNode prompt |
	selectedNode := historyTree selectedItem.
	selectedNode ifNil: [ ^ self ].
	selectedNode isReference ifTrue: [ ^ self ].

	prompt := promptInput text asString.
	prompt ifEmpty: [ ^ self ].

	self addPrompt: prompt to: selectedNode history.
	selectedNode history getResponse.

	promptInput text: ''
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> stringFromMessages: messages [
	^ String streamContents: [ :stream |
		messages withIndexDo: [ :message :index |
			index > 1 ifTrue: [
				stream nextPutAll: String lf.
				stream nextPutAll: String lf ].

			stream
				nextPutAll: message key asString;
				nextPutAll: ':';
				nextPutAll: String lf;
				nextPutAll: message value asString ] ]
]
