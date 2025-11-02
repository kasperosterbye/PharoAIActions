"
# Class Comment for AIAClyCommentSet

The `AIAClyCommentSet` class is designed to manage and manipulate sets of comments within the context of AI actions. This class provides functionality to create, modify, and compare comment sets, facilitating the integration of AI-generated comments into the system.

"
Class {
	#name : 'AIAClyCommentSet',
	#superclass : 'AIAClyComment',
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
}

{ #category : 'accessing' }
AIAClyCommentSet >> defaultMenuItemName [
	"Returns the default menu item name for the AI comment set"
	^ 'AI set comment'
]
