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
		'messageList',
		'messageItem1',
		'messageItem2',
		'promptInput',
		'addButton',
		'sendButton',
		'newButton',
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

{ #category : 'adding' }
AIAHistoryPresenter >> addPrompt [
	| selectedNode prompt |
	selectedNode := historyTree selectedItem.
	selectedNode ifNil: [ ^ self ].
	selectedNode isReference ifTrue: [ ^ self ].

	prompt := promptInput text asString.
	prompt ifEmpty: [ ^ self ].

	selectedNode history user: prompt.
	promptInput text: ''
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

{ #category : 'layout' }
AIAHistoryPresenter >> defaultLayout [
	| left right both promptRow |
	left := SpPanedLayout newVertical
		add: historyTree;
		add: messageList;
		yourself.

	right := SpPanedLayout newVertical
		add: messageItem1;
		add: messageItem2;
		yourself.

	both := SpPanedLayout newHorizontal
		add: left;
		add: right;
		yourself.

	promptRow := SpBoxLayout newLeftToRight
		add: promptInput;
		add: newButton expand: false;
		add: addButton expand: false;
		add: sendButton expand: false;
		add: reloadButton expand: false;
		add: deleteButton expand: false;
		yourself.

	^ SpBoxLayout newTopToBottom
		add: both;
		add: promptRow expand: false;
		yourself
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
AIAHistoryPresenter >> getHistoryTreeRoots [
	^ AIAHistory histories collect: [ :history |
		AIAHistoryPresenterTreeNode rootFor: history ]
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> getMessageList [
    ^ #()
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> historyActions [
	historyTree
		roots: self getHistoryTreeRoots;
		children: [ :node | node children ];
		display: [ :node | node history printString ];
		displayItalic: [ :node | node isReference ].
	self
		historyChangeAction;
		historyObserveTree
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> historyChangeAction [
	historyTree whenSelectionChangedDo: [ :selection |
		| selected messages |
		selected := selection selectedItem.
		addButton enabled: (selected notNil and: [ selected isReference not ]).
		sendButton enabled: (selected notNil and: [ selected isReference not ]).
		deleteButton enabled: (self canDeleteNode: selected).
		selected ifNotNil: [
			messages := selected history messages.
			messageList items: messages.

			messageItem1 text: ''.
			messageItem2 text: ''.

			messages ifNotEmpty: [
				messageItem1 text:
					(self assocString: messages first) ].

			messages size > 1 ifTrue: [
				messageItem2 text:
					(self assocString: messages second) ] ] ]
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> historyObserveTree [
	SystemAnnouncer uniqueInstance
        when: AIAHistoriesChanged
        do: [ historyTree roots: self getHistoryTreeRoots ]
        for: self.
]

{ #category : 'initialization' }
AIAHistoryPresenter >> initializePresenters [

	super initializePresenters.
	historyTree := self newTree.
	messageList := self newList.
	messageItem1 := self newText.
	messageItem2 := self newText.
	promptInput := self newText.
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
	messageList items: self getMessageList.
	rootDirectory ifNil: [ rootDirectory := AIAHistoryFileStore new rootDirectory ].

	reloadButton := self newButton
		label: 'Reload';
		action: [ self reloadHistories ];
		yourself.

	deleteButton := self newButton
		label: 'Delete';
		action: [ self deleteSelectedHistory ];
		yourself.
	deleteButton disable.
		
	self historyActions.
	self messageActions.
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
	
	messageList items: self getMessageList.
	self 
		messageChangeAction ;
		messageRefreshTree.
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> messageChangeAction [
    messageList whenSelectionChangedDo: [ :selection |
        | selected newReply1Text |
        selected := selection selectedItem.
        selected ifNotNil: [
				newReply1Text := selected key, String lf, selected value.
				messageItem2 text: messageItem1 text.
            messageItem1 text: newReply1Text ] ].
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> messageRefreshTree [

	| selected |
	SystemAnnouncer uniqueInstance
		when: AIAReplyChanged
		do: [
				historyTree refresh.
				selected := historyTree selection selectedItem.
				selected ifNotNil: [ messageList items: selected history messages ] ]
		for: self
]

{ #category : 'instance creation' }
AIAHistoryPresenter >> newPrompt [
	| prompt history root |
	prompt := promptInput text asString.
	prompt ifEmpty: [ ^ self ].

	history := newHistoryFactory value.
	history fileStore rootDirectory: rootDirectory.
	
	root := historyTree roots detect: [ :node |
		node history == history ].
	historyTree selectItem: root.

	history
		user: prompt;
		getResponse.

	promptInput text: ''
]

{ #category : 'history globals' }
AIAHistoryPresenter >> reloadHistories [
	AIAHistory reloadHistoriesFrom: rootDirectory.
	historyTree roots: self getHistoryTreeRoots
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

	selectedNode history
		user: prompt;
		getResponse.
	promptInput text: ''
]
