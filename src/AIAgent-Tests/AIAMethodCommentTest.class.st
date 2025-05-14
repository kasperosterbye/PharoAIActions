Class {
	#name : 'AIAMethodCommentTest',
	#superclass : 'AIACommentBuildingTest',
	#instVars : [
		'testMethod',
		'methodCommenter'
	],
	#category : 'AIAgent-Tests-CommentBuilder-Tests',
	#package : 'AIAgent-Tests',
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
	testMethod := self class >> #methodExample.
	self methodExampleSetComment.
	methodCommenter := AIAMethodComment for: testMethod 
	
]

{ #category : 'tests' }
AIAMethodCommentTest >> testCommentSourceFor [
	|  commentSource |
	commentSource := methodCommenter commentSourceFor: testMethod .
	self assert: commentSource lines first equals: 'AIAMethodCommentTest >> #methodExample'.
	
	self assert: commentSource lines second equals: '	"this is just an example method"'
]

{ #category : 'tests' }
AIAMethodCommentTest >> testGetComment [
	|  comment |
	self methodExampleRemoveComment.
	methodCommenter getComment: testMethod .
	comment := methodCommenter response.
	self assert: comment size > 5.
	self assert: (comment includesSubstring: '88').
]

{ #category : 'tests' }
AIAMethodCommentTest >> testInitialize [
	self assert: methodCommenter compiledMethod equals: testMethod .
	self assert: (methodCommenter methodSource includesSubstring: '^ foo + 12.')
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
		methodSourceAddComment: '"this is just an example method"'.
	self assert: (commentedSource includesSubstring: 'is just an example')
]

{ #category : 'tests' }
AIAMethodCommentTest >> testSetComment [
	self methodExampleRemoveComment.
	methodCommenter setComment: testMethod .
	testMethod := self class >> #methodExample.
	self assert: testMethod comment size > 5.
	self assert: (testMethod comment includesSubstring: '88').
]
