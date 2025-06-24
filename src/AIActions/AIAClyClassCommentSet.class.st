Class {
	#name : 'AIAClyClassCommentSet',
	#superclass : 'AIAClyCommentSet',
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
}

{ #category : 'as yet unclassified' }
AIAClyClassCommentSet class >> aiaCommentActivation [
	<classAnnotation>
	^ CmdShortcutActivation by: $p meta shift for: ClyFullBrowserClassContext
]

{ #category : 'as yet unclassified' }
AIAClyClassCommentSet class >> clyMenuActivation [
	<classAnnotation>
	^ CmdContextMenuActivation 
		byRootGroupItemFor: ClyFullBrowserClassContext
]

{ #category : 'execution' }
AIAClyClassCommentSet >> execute [
	"This method executes the command to set an AI comment for the selected class in the browser."
	self element browserItem actualObject setAIAComment.
	
]

{ #category : 'execution' }
AIAClyClassCommentSet >> readParametersFromContext: aContext [
	aContext selectedClassItems isEmpty ifTrue: [ ^ self ].
	self element: aContext selectedClassItems first.
]
