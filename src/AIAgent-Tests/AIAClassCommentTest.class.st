Class {
	#name : 'AIAClassCommentTest',
	#superclass : 'AIACommentBuildingTest',
	#instVars : [
		'classCommenter'
	],
	#category : 'AIAgent-Tests-CommentBuilder-Tests',
	#package : 'AIAgent-Tests',
	#tag : 'CommentBuilder-Tests'
}

{ #category : 'running' }
AIAClassCommentTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	classCommenter := AIAClassComment new.
]

{ #category : 'tests' }
AIAClassCommentTest >> testGetComment [
	classCommenter getComment: AIAClassCommentTest .
	self assert: (classCommenter response includesSubstring: self class name asString).
	self assert: (classCommenter response includesSubstring: '## Example')
]

{ #category : 'tests' }
AIAClassCommentTest >> testSetComment [
	classCommenter class comment: 'Killroy test'.
	self assert:( classCommenter class comment includesSubstring: 'roy te').
]
