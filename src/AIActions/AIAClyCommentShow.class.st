"
# Class Comment for AIAClyCommentShow

The `AIAClyCommentShow` class is designed to facilitate the creation and management of AI-generated comments within a Pharo environment. This class leverages a fluid syntax to define and build classes, making it easy to script class creation interactively. It is particularly useful for developers who need to dynamically create and inspect classes without modifying existing objects or installing them into the system.

"
Class {
	#name : 'AIAClyCommentShow',
	#superclass : 'AIAClyComment',
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
}

{ #category : 'accessing' }
AIAClyCommentShow >> defaultMenuItemName [
	"Returns the name of the menu item for the AI comment command"
	^ 'AI comment'
]
