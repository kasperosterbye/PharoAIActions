"
## Class Comment for `AIAClyPackageCommentShow`

The `AIAClyPackageCommentShow` class is designed to display comments associated with a package in the Pharo environment. This class is part of the `AIActions` package and is tagged with `BrowserAIAComments`. It provides functionality to read parameters from a context and execute the display of package comments.

"
Class {
	#name : 'AIAClyPackageCommentShow',
	#superclass : 'AIAClyCommentShow',
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
}

{ #category : 'actions' }
AIAClyPackageCommentShow class >> aiaCommentActivation [
	<classAnnotation>
	^ CmdShortcutActivation by: $p meta for: ClyFullBrowserPackageContext
]

{ #category : 'actions' }
AIAClyPackageCommentShow class >> clyMenuActivation [
	<classAnnotation>
	^ CmdContextMenuActivation 
		byRootGroupItemFor: ClyFullBrowserPackageContext
]

{ #category : 'execution' }
AIAClyPackageCommentShow >> execute [
	"Displays the package comment for the selected package in the browser"
	AIAPresenter onText: (self element browserItem actualObject name asString aiaComment).
	
]

{ #category : 'execution' }
AIAClyPackageCommentShow >> readParametersFromContext: aContext [
	"Reads parameters from the context and sets the element if a package is selected"
	aContext selectedPackageItems isEmpty ifTrue: [ ^ self ].
	self element: aContext selectedPackageItems first.
]
