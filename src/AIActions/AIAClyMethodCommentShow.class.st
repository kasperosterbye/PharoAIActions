Class {
	#name : 'AIAClyMethodCommentShow',
	#superclass : 'AIAClyCommentShow',
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
}

{ #category : 'as yet unclassified' }
AIAClyMethodCommentShow class >> aiaCommentActivation [
	<classAnnotation>
	^ CmdShortcutActivation by: $p meta for: ClyFullBrowserMethodContext
]

{ #category : 'as yet unclassified' }
AIAClyMethodCommentShow class >> clyMenuActivation [
	<classAnnotation>
	^ CmdContextMenuActivation 
		byRootGroupItemFor: ClyFullBrowserMethodContext
]

{ #category : 'execution' }
AIAClyMethodCommentShow >> execute [
	AIACommentPresenter onText: self element browserItem actualObject aiaComment.
	
]

{ #category : 'execution' }
AIAClyMethodCommentShow >> readParametersFromContext: aContext [
	aContext selectedMethodItems isEmpty ifTrue: [ ^ self ].
	self element: aContext selectedMethodItems first.
]
