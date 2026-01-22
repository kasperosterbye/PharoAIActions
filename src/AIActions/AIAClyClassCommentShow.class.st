"
# Class Comment for `AIAClyClassCommentShow`

The `AIAClyClassCommentShow` class is designed to display the comments associated with a class in a Pharo system. This class is part of the `AIActions` package and is tagged with `BrowserAIAComments`. It provides functionality to read parameters from a context and execute the display of class comments.

"
Class {
	#name : 'AIAClyClassCommentShow',
	#superclass : 'AIAClyCommentShow',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'action' }
AIAClyClassCommentShow class >> aiaCommentActivation [
	<classAnnotation>
	^ CmdShortcutActivation by: $p meta for: ClyFullBrowserClassContext
]

{ #category : 'action' }
AIAClyClassCommentShow class >> clyMenuActivation [
	<classAnnotation>
	^ CmdContextMenuActivation 
		byRootGroupItemFor: ClyFullBrowserClassContext
]

{ #category : 'execution' }
AIAClyClassCommentShow >> execute [
	"Displays the AI-generated comment for the selected class in the browser"
	AIAPresenter onText: self element browserItem actualObject aiaComment.
	
]

{ #category : 'execution' }
AIAClyClassCommentShow >> readParametersFromContext: aContext [
	"Reads parameters from the context and sets the element if a class is selected"
	aContext selectedClassItems isEmpty ifTrue: [ ^ self ].
	self element: aContext selectedClassItems first.
]
