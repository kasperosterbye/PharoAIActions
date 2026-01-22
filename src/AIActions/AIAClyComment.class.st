"
# Class Comment for AIAClyComment

The `AIAClyComment` class is designed to facilitate the creation and management of comments within the context of a browser, specifically for AI-generated comments. This class extends the functionality of `CmdCommand` and is tagged under 'BrowserAIAComments' within the 'AIActions' package.
"
Class {
	#name : 'AIAClyComment',
	#superclass : 'CmdCommand',
	#instVars : [
		'element'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'testing' }
AIAClyComment class >> canBeExecutedInContext: aToolContext [
	^aToolContext hasSelectedItems
]

{ #category : 'testing' }
AIAClyComment >> canBeExecutedInContext: aContext [
	^ aContext selectedMethodItems notEmpty
]

{ #category : 'accessing' }
AIAClyComment >> element [

	^ element
]

{ #category : 'accessing' }
AIAClyComment >> element: anObject [

	element := anObject
]
