Class {
	#name : 'AIAChatBuildingTest',
	#superclass : 'TestCase',
	#instVars : [
		'chatBuilder'
	],
	#category : 'AIActions-Tests-CommentBuilder-Tests',
	#package : 'AIActions-Tests',
	#tag : 'CommentBuilder-Tests'
}

{ #category : 'running' }
AIAChatBuildingTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	chatBuilder := AIADiscussion new.
]
