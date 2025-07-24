Class {
	#name : 'AIATestGeneratorTest',
	#superclass : 'TestCase',
	#instVars : [
		'refTestGenerator'
	],
	#category : 'AIActions-Tests-CommentBuilder-Tests',
	#package : 'AIActions-Tests',
	#tag : 'CommentBuilder-Tests'
}

{ #category : 'running' }
AIATestGeneratorTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	refTestGenerator := AIATestGenerator new.
]

{ #category : 'tests' }
AIATestGeneratorTest >> testBuildTestForMethod [
	|res1 res2|
	Smalltalk globals 
		at: #AIASillyClassAITest
		ifPresent: [ (Smalltalk globals at: #AIASillyClassAITest) removeFromSystem ] .
	self deny: (Smalltalk globals includesKey: #AIASillyClassAITest).
	refTestGenerator sourceMethod: AIASillyClass >> #foo:.
	
	res1 := refTestGenerator buildTestForMethod: AIASillyClass >> #foo:.
	self assert: res1  equals: AIASillyClassAITest.
	self assert: (Smalltalk globals includesKey: #AIASillyClassAITest) .
	res2:=  refTestGenerator buildTestForMethod: AIASillyClass >> #foo:.
	self assert: res2 equals: res1.
]

{ #category : 'tests' }
AIATestGeneratorTest >> testChatBuilder [
	self assert: refTestGenerator chatBuilder notNil 
]

{ #category : 'tests' }
AIATestGeneratorTest >> testHist1GeneratorMethods [
	refTestGenerator sourceMethod: String >> #occursInWithEmpty:caseSensitive:.
	refTestGenerator hist1GeneratorMethods.
	self assert: refTestGenerator chatBuilder history first key equals: 'user'.
	self assert: (refTestGenerator chatBuilder history first value first: 17) equals: 'I have heard that'.
	self 
		assert: (refTestGenerator chatBuilder history second value first: 57)
		equals: '
Important Coding Rule

When writing Pharo code or tests:'
]

{ #category : 'tests' }
AIATestGeneratorTest >> testHist2WhereToPlaceTestMethod [
	refTestGenerator sourceMethod: String >> #occursInWithEmpty:caseSensitive:.
	refTestGenerator hist2WhereToPlaceTestMethod.
	self assert: refTestGenerator chatBuilder history first key equals: 'user'.
	self assert: (refTestGenerator chatBuilder history first value first: 15) equals: 'I want to write'.
	self 
		assert: refTestGenerator chatBuilder history second value 
		equals: 'There is an existing test class named StringAITest which is to be used. 
		The name of the test method is testOccursInWithEmptyCaseSensitive'
]

{ #category : 'tests' }
AIATestGeneratorTest >> testHist3WhatIsTheBasics [
	refTestGenerator sourceMethod: String >> #occursInWithEmpty:caseSensitive:.
	refTestGenerator hist3WhatIsTheBasics.
	self assert: refTestGenerator chatBuilder history first key equals: 'user'.
	self assert: (refTestGenerator chatBuilder history first value first: 19) equals: 'What are the basics'.
	self 
		assert: refTestGenerator chatBuilder history second value
		equals: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
]

{ #category : 'tests' }
AIATestGeneratorTest >> testInitialize [
	self assert: refTestGenerator chatBuilder notNil 
]

{ #category : 'tests' }
AIATestGeneratorTest >> testRepairResponseMethod [
	| repair |
	refTestGenerator sourceMethod: AIASourceCodeBuilder >> #forMethod:.
	refTestGenerator testMethod: 
'```Kilroy
testForMethodGeneratorFor: joe
^42
```
'.
	repair := refTestGenerator repairResponseMethod.
	self assert: repair equals: 
'testForMethod
^42'.
]

{ #category : 'tests' }
AIATestGeneratorTest >> testSourceClassStringName [
	refTestGenerator sourceMethod: String >> #occursInWithEmpty:caseSensitive:.
	self assert: refTestGenerator sourceClassStringName equals: 'String'
]

{ #category : 'tests' }
AIATestGeneratorTest >> testSourceMethod [
	refTestGenerator sourceMethod: 'Joe should not be a class, but for this test it works'.
	self assert: refTestGenerator sourceMethod equals: 'Joe should not be a class, but for this test it works'
]

{ #category : 'tests' }
AIATestGeneratorTest >> testSourceMethodStringName [
	refTestGenerator sourceMethod: String >> #occursInWithEmpty:caseSensitive:.
	self 
		assert: refTestGenerator sourceMethodStringName 
		equals: 'occursInWithEmpty:caseSensitive:'
]

{ #category : 'tests' }
AIATestGeneratorTest >> testSystemGenerator [
	refTestGenerator sourceMethod: AIASourceCodeBuilder >> #forMethod:.
	refTestGenerator systemGenerator.
	self assert: refTestGenerator chatBuilder history first key equals: 'system'.
	self assert: (refTestGenerator chatBuilder history first value includesSubstring: '## Class: ','AIASourceCodeBuilder').
]

{ #category : 'tests' }
AIATestGeneratorTest >> testTestMethod [
	refTestGenerator testMethod: 'Joe should not be a class, but for this test it works'.
	self assert: refTestGenerator testMethod equals: 'Joe should not be a class, but for this test it works'
]

{ #category : 'tests' }
AIATestGeneratorTest >> testTestMethodName [
	refTestGenerator sourceMethod: String >> #occursInWithEmpty:caseSensitive:.
	self assert: refTestGenerator testMethodName equals: 'testOccursInWithEmptyCaseSensitive'
]
