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
		'historyList',
		'messageList',
		'messageItem1',
		'messageItem2'
	],
	#category : 'AIAExperiments-UIPresenters',
	#package : 'AIAExperiments',
	#tag : 'UIPresenters'
}

{ #category : 'examples' }
AIAHistoryPresenter class >> open [
	<example>
	
	^ self new open
]

{ #category : 'layout' }
AIAHistoryPresenter >> defaultLayout [
    | left right both |
    left := SpPanedLayout newVertical
        add: historyList;
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
AIAHistoryPresenter >> getHistoryList [
	^ AIAHistory histories 
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> getMessageList [
    ^ #()
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> historyChangeAction [
    historyList whenSelectionChangedDo: [ :selection |
        | selected |
        selected := selection selectedItem.
        selected ifNotNil: [ 
            messageList items: selected messages.
            messageItem1 text: ''.
				messageItem2 text: '' ] ].
]

{ #category : 'initialization' }
AIAHistoryPresenter >> initializePresenters [
    super initializePresenters.

    historyList := self newList.
	 messageList   := self newList.
    messageItem1  := self newText.
    messageItem2 := self newText.

    historyList items: self getHistoryList.
	 messageList items: self getMessageList.
	
	self historyChangeAction.
	self promptChangeAction.
	
SystemAnnouncer uniqueInstance
    when: AIAHistoriesChanged
    do: [ self refreshHistoryList ]
    for: self.

SystemAnnouncer uniqueInstance
    when: AIAReplyChanged 
    do: [ self refreshMessageList ]
    for: self.
]

{ #category : 'initialization' }
AIAHistoryPresenter >> initializeWindow: aWindow [
    super initializeWindow: aWindow.
    aWindow title: 'AIA History'.
    aWindow whenClosedDo: [
        SystemAnnouncer uniqueInstance unsubscribe: self ].
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> promptChangeAction [
    messageList whenSelectionChangedDo: [ :selection |
        | selected newReply1Text |
        selected := selection selectedItem.
        selected ifNotNil: [
				newReply1Text := selected key, String lf, selected value.
				messageItem2 text: messageItem1 text.
            messageItem1 text: newReply1Text ] ].
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> refreshHistoryList [
    historyList items: self getHistoryList.
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> refreshMessageList [
    messageList items: self getMessageList.
]
