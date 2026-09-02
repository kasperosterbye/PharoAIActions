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
		'messageItem2'
	],
	#category : 'AIActions-UIPresenters',
	#package : 'AIActions',
	#tag : 'UIPresenters'
}

{ #category : 'as yet unclassified' }
AIAHistoryPresenter class >> forDirectory: aDirectory [
	"Load the stored histories before constructing the presenter."

	AIAHistory reloadHistoriesFrom: aDirectory.
	^ self new
]

{ #category : 'examples' }
AIAHistoryPresenter class >> open [
	<example>

	^ (self forDirectory:
		AIAHistoryFileStore new rootDirectory)
			open
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> assocString: assoc [
	^ assoc key, String lf, assoc value
]

{ #category : 'layout' }
AIAHistoryPresenter >> defaultLayout [
    | left right both |
    left := SpPanedLayout newVertical
        add: historyTree;
        add: messageList;
        yourself.

    right := SpPanedLayout newVertical
        add: messageItem1;
        add: messageItem2;
        yourself.

    both :=  SpPanedLayout newHorizontal
        add: left;
        add: right;
        yourself.
	^ both
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
		display: [ :node | node history printString ].
	self
		historyChangeAction;
		historyObserveTree
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> historyChangeAction [
	historyTree whenSelectionChangedDo: [ :selection |
		| selected messages |
		selected := selection selectedItem.
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
	messageList items: self getMessageList.
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
				selected := historyTree selection selectedItem.
				selected ifNotNil: [ messageList items: selected messages ] ]
		for: self
]
