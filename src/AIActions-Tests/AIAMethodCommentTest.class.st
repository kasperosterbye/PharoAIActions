Class {
	#name : 'AIAMethodCommentTest',
	#superclass : 'TestCase',
	#instVars : [
		'testMethod',
		'methodCommenter'
	],
	#category : 'AIActions-Tests-CommentBuilder-Tests',
	#package : 'AIActions-Tests',
	#tag : 'CommentBuilder-Tests'
}

{ #category : 'method example' }
AIAMethodCommentTest >> methodExample [
	"this is just an example method"
	| foo |
	foo := 88.
	^ foo + 12.
]

{ #category : 'method examples' }
AIAMethodCommentTest >> methodExampleRemoveComment [
	| source |
	source := testMethod sourceCode lines asOrderedCollection.	
	testMethod comment ifNotNil: [ source removeAt: 2 ].
	
	self class
		compile: (String cr join: source)
		classified: 'method example'.
	
	testMethod := self class >> #methodExample.
]

{ #category : 'method examples' }
AIAMethodCommentTest >> methodExampleSetComment [
	| source |
	source := testMethod sourceCode lines asOrderedCollection.	
	testMethod comment ifNotNil: [ source removeAt: 2 ].
	source add: (String tab,  '"this is just an example method"') afterIndex: 1.
	
	self class
		compile: (String cr join: source)
		classified: 'method example'
]

{ #category : 'running' }
AIAMethodCommentTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	methodCommenter := AIAMethodComment new. 
	testMethod := self class >> #methodExample.
	self methodExampleSetComment.
	
]

{ #category : 'tests' }
AIAMethodCommentTest >> testAiaComment [
	|  comment |
	self methodExampleRemoveComment.
	methodCommenter aiaComment: testMethod .
	comment := methodCommenter response.
	self assert: comment size > 5.
	self assert: (comment includesSubstring: 'method').
]

{ #category : 'tests' }
AIAMethodCommentTest >> testAiaWhiteComment [
	|  comment |
	self methodExampleRemoveComment.
	methodCommenter aiaComment: testMethod .
	comment := methodCommenter response.
	self assert: comment size > 5.
	self assert: (comment includesSubstring: 'demonstrates').
]

{ #category : 'tests' }
AIAMethodCommentTest >> testMethodSourceAddComment [
	| source commentedSource|
	testMethod comment ifNotNil: [  
		source := testMethod sourceCode lines asOrderedCollection.
		source removeAt: 2.
		source := String cr join: source
	].
	commentedSource := methodCommenter 
		methodSource: testMethod addComment: '"this is just an example method"'.
	self assert: (commentedSource includesSubstring: 'is just an example')
]

{ #category : 'tests' }
AIAMethodCommentTest >> testSetComment [
	self methodExampleRemoveComment.
	methodCommenter setComment: testMethod .
	testMethod := self class >> #methodExample.
	self assert: testMethod comment size > 5.
	self assert: (testMethod comment includesSubstring: 'method').
]

{ #category : 'tests' }
AIAMethodCommentTest >> testSetWhiteComment [
	self methodExampleRemoveComment.
	methodCommenter setComment: testMethod .
	testMethod := self class >> #methodExample.
	self assert: testMethod comment size > 5.
	self assert: (testMethod comment includesSubstring: 'demonstra').
]
