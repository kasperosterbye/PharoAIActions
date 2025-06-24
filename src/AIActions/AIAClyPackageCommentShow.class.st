Class {
	#name : 'AIAClyPackageCommentShow',
	#superclass : 'AIAClyCommentShow',
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
}

{ #category : 'as yet unclassified' }
AIAClyPackageCommentShow class >> aiaCommentActivation [
	<classAnnotation>
	^ CmdShortcutActivation by: $p meta for: ClyFullBrowserPackageContext
]

{ #category : 'as yet unclassified' }
AIAClyPackageCommentShow class >> clyMenuActivation [
	<classAnnotation>
	^ CmdContextMenuActivation 
		byRootGroupItemFor: ClyFullBrowserPackageContext
]

{ #category : 'execution' }
AIAClyPackageCommentShow >> execute [
	AIACommentPresenter onText: (self element browserItem actualObject name asString aiaComment).
	
]

{ #category : 'execution' }
AIAClyPackageCommentShow >> readParametersFromContext: aContext [
	aContext selectedPackageItems isEmpty ifTrue: [ ^ self ].
	self element: aContext selectedPackageItems first.
]
