Class {
	#name : 'AIAHistoryPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'historyList',
		'promptList',
		'promptText',
		'responseText'
	],
	#category : 'AIActions-HistoryPresenter',
	#package : 'AIActions',
	#tag : 'HistoryPresenter'
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
