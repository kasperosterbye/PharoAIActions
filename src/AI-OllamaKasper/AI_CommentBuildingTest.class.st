"
All tests use RxParser as the example class, since it is small, stable, and unchanged for decades. This avoids meta-level confusion and ensures consistent test behavior.
## Instance variables (AI generated comments)
**commentBuilder** : Creates and tests CommentBuilder instance for parsing and commenting code
-----


"
Class {
	#name : 'AI_CommentBuildingTest',
	#superclass : 'TestCase',
	#instVars : [
		'commentBuilder'
	],
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'running' }
AI_CommentBuildingTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	"self setDummyMethod."
	commentBuilder :=   AI_CommentBuilding new initialize: RxParser
]

{ #category : 'tests' }
AI_CommentBuildingTest >> testAddCommentToUncommented [
	"test if the comment propsed makes sence."
	| testCommentText comment res |
	"RxParser >> #signalParseError does not contain a comment"
	testCommentText := (RxParser >> #signalParseError) sourceCode.
	comment := 'To be "or" not to be'.
	res := commentBuilder addComment: comment toUncommented: testCommentText.
	self assert: res lines second equals: comment asComment
	
]

{ #category : 'tests' }
AI_CommentBuildingTest >> testAiCommentedInstanceVariables [ 
	"The test is actually tested in testInitialize, but here is an explict test"
	| classToBeCommented classComment|
	classToBeCommented := commentBuilder class commentClass: RxParser.
	self timeLimit: 100 seconds.
	classComment  := classToBeCommented aiCommentedInstanceVariables lines.
	self 
		assert: ((classComment at: 1) beginsWith: '## Instance variables').
	self 
		assert: ((classComment at: 2) beginsWith: '**input** :').
	self 
		assert: ((classComment at: 3) beginsWith: '**lookahead** :')
	
]

{ #category : 'tests' }
AI_CommentBuildingTest >> testAiCommentedMethod [
	"Test the comment adding to a single method given as praramter"

	| classToBeCommented aMethod |
	classToBeCommented := commentBuilder class commentClass: RxParser.
	aMethod := classToBeCommented aiCommentedMethod:
		           RxParser >> #signalParseError:.
	self timeLimit: 100 seconds.
	self assert: aMethod first equals: 'private'.
	self assert: (commentBuilder containsComment: aMethod second)
]

{ #category : 'tests' }
AI_CommentBuildingTest >> testAiCommentedMethods [ 
	"The test is actually tested in testInitialize, but here is an explict test"
	| classToBeCommented methodComments |
	classToBeCommented := commentBuilder class commentClass: RxParser.
	self timeLimit: 100 seconds.
	methodComments  := classToBeCommented aiCommentedMethods.
	self assert: methodComments size = 3.
	methodComments do: [ :method |
		self assert: (method second lines second trimBoth beginsWith: '"').
		self assert: (method second lines second trimBoth endsWith: '"').
	]
]

{ #category : 'helper methods' }
AI_CommentBuildingTest >> testContainsComment [
	"Check that non-commented methods are fount"
    | result |
    
    "Check if it wrongly detects a comment"
    result := commentBuilder containsComment: (RxParser >> #signalParseError) sourceCode.
    self deny: result.

	"Check if it wrongly detects a comment"
    result := commentBuilder containsComment: (RxParser >> #lookAround) sourceCode.
    self assert: result .


]

{ #category : 'tests' }
AI_CommentBuildingTest >> testInitialize [
	"test that the commentClass on class side is working"
	| classToBeCommented |
	classToBeCommented := commentBuilder class commentClass: RxParser.
	self 
		assert: classToBeCommented classObj 
		equals: RxParser.
	self 
		assert: classToBeCommented methodsToComment size
		equals: 3.
	self 
		assert: (classToBeCommented system beginsWith: 'Give respose of maximum 100').
	self 
		assert: (classToBeCommented prompt beginsWith: 'Write short commentfor').
]

{ #category : 'tests' }
AI_CommentBuildingTest >> testNonCommentedMethods [
	"The test is actually tested in testInitialize, but here is an explict test"
	| classToBeCommented |
	classToBeCommented := commentBuilder class commentClass: RxParser.
	self 
		assert: classToBeCommented nonCommentedMethods size
		equals: 3.
]
