Class {
	#name : 'AIAClyPackageCommentSet',
	#superclass : 'AIAClyCommentSet',
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
}

{ #category : 'as yet unclassified' }
AIAClyPackageCommentSet class >> aiaCommentActivation [
	<classAnnotation>
	^ CmdShortcutActivation by: $p meta shift for: ClyFullBrowserPackageContext
]

{ #category : 'as yet unclassified' }
AIAClyPackageCommentSet class >> clyMenuActivation [
	<classAnnotation>
	^ CmdContextMenuActivation 
		byRootGroupItemFor: ClyFullBrowserPackageContext
]

{ #category : 'execution' }
AIAClyPackageCommentSet >> execute [
	self element browserItem actualObject methodClass packageName asString setAIAComment.
	
]

{ #category : 'execution' }
AIAClyPackageCommentSet >> readParametersFromContext: aContext [
	aContext selectedPackageItems isEmpty ifTrue: [ ^ self ].
	self element: aContext selectedPackageItems first.
]
