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
		'promptList',
		'promptText',
		'responseText'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'initialization' }
AIAHistoryPresenter >> defaultLayout [
    | left right |
    left := SpPanedLayout newVertical
        add: historyList;
        add: promptList;
        yourself.

    right := SpPanedLayout newVertical
        add: responseText;
        add: promptText;
        yourself.

    ^ SpPanedLayout newHorizontal
        add: left;
        add: right;
        yourself
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> getHistoryList [
	^ AIAHistory histories 
]

{ #category : 'as yet unclassified' }
AIAHistoryPresenter >> getPromptList [
	
    ^ #('Session 1' 'Session 2' 'Session 3')
]

{ #category : 'nil' }
AIAHistoryPresenter >> initializePresenters [
    super initializePresenters.

    historyList := self newList.
	 promptList   := SpListPresenter new.
    responseText  := SpTextPresenter new.
    promptText := SpTextPresenter new.


    "Fyld history-listen via din egen metode"
    historyList items: self getHistoryList.
	 promptList items: self getPromptList.
]

{ #category : 'initialization' }
AIAHistoryPresenter >> initializeWindow: aWindow [
    super initializeWindow: aWindow.
    aWindow title: 'AIA History'
]
