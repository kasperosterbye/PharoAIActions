Class {
	#name : 'AIAClyMethodCommentShow',
	#superclass : 'AIAClyCommentShow',
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
}

{ #category : 'actions' }
AIAClyMethodCommentShow class >> aiaCommentActivation [
	<classAnnotation>
	^ CmdShortcutActivation by: $p meta for: ClyFullBrowserMethodContext
]

{ #category : 'actions' }
AIAClyMethodCommentShow class >> clyMenuActivation [
	<classAnnotation>
	^ CmdContextMenuActivation 
		byRootGroupItemFor: ClyFullBrowserMethodContext
]

{ #category : 'execution' }
AIAClyMethodCommentShow >> execute [
	"Displays the AI-generated comment for the selected method in the browser"
	AIAPresenter onText: self element browserItem actualObject aiaComment.
	
]

{ #category : 'execution' }
AIAClyMethodCommentShow >> readParametersFromContext: aContext [
	"Reads the selected method from the context and sets it as the element for the command"
	aContext selectedMethodItems isEmpty ifTrue: [ ^ self ].
	self element: aContext selectedMethodItems first.
]
