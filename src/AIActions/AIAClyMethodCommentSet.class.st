Class {
	#name : 'AIAClyMethodCommentSet',
	#superclass : 'AIAClyCommentSet',
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
}

{ #category : 'as yet unclassified' }
AIAClyMethodCommentSet class >> aiaCommentActivation [
	<classAnnotation>
	^ CmdShortcutActivation by: $p meta shift for: ClyFullBrowserMethodContext
]

{ #category : 'as yet unclassified' }
AIAClyMethodCommentSet class >> clyMenuActivation [
	<classAnnotation>
	^ CmdContextMenuActivation 
		byRootGroupItemFor: ClyFullBrowserMethodContext
]

{ #category : 'execution' }
AIAClyMethodCommentSet >> execute [
	self element browserItem actualObject setAIAComment .
	
]

{ #category : 'execution' }
AIAClyMethodCommentSet >> readParametersFromContext: aContext [
	aContext selectedMethodItems isEmpty ifTrue: [ ^ self ].
	self element: aContext selectedMethodItems first.
]
