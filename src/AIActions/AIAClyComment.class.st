Class {
	#name : 'AIAClyComment',
	#superclass : 'CmdCommand',
	#instVars : [
		'element'
	],
	#category : 'AIActions-BrowserAIAComments',
	#package : 'AIActions',
	#tag : 'BrowserAIAComments'
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
