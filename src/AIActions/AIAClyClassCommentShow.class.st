"
# Class Comment for `AIAClyClassCommentShow`

The `AIAClyClassCommentShow` class is designed to display the comments associated with a class in a Pharo system. This class is part of the `AIActions` package and is tagged with `BrowserAIAComments`. It provides functionality to read parameters from a context and execute the display of class comments.

"
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
