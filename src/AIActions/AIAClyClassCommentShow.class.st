Class {
	#name : 'AIAClyClassCommentShow',
	#superclass : 'AIAClyCommentShow',
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
}

{ #category : 'as yet unclassified' }
AIAClyClassCommentShow class >> aiaCommentActivation [
	<classAnnotation>
	^ CmdShortcutActivation by: $p meta for: ClyFullBrowserClassContext
]

{ #category : 'as yet unclassified' }
AIAClyClassCommentShow class >> clyMenuActivation [
	<classAnnotation>
	^ CmdContextMenuActivation 
		byRootGroupItemFor: ClyFullBrowserClassContext
]

{ #category : 'execution' }
AIAClyClassCommentShow >> execute [
	AIACommentPresenter onText: self element browserItem actualObject aiaComment.
	
]

{ #category : 'execution' }
AIAClyClassCommentShow >> readParametersFromContext: aContext [
	aContext selectedClassItems isEmpty ifTrue: [ ^ self ].
	self element: aContext selectedClassItems first.
]
