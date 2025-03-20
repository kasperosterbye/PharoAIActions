Class {
	#name : 'AI_CommentBuildingTest',
	#superclass : 'TestCase',
	#instVars : [
		'commentBuilder'
	],
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'as yet unclassified' }
AI_CommentBuildingTest >> dummyCommentedMethod [
	"42 is really a great integer"
		^ 42.
]

{ #category : 'as yet unclassified' }
AI_CommentBuildingTest >> dummyMethod [
		^ 42.
]

{ #category : 'helper methods' }
AI_CommentBuildingTest >> setDummyMethod [
	"set the dummyMethod so we are sure it is the right method"
	self class compile: 'dummyMethod
		^ 42.'.
]

{ #category : 'running' }
AI_CommentBuildingTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	self setDummyMethod.
	commentBuilder :=   AI_CommentBuilding new initialize: self class
]

{ #category : 'tests' }
AI_CommentBuildingTest >> testAddCommentTo [
	"test if the comment propsed makes sence."
	| testCommentText comment res |
	testCommentText := 'containsComment: code
    | ast |
    ast := RBParser parseMethod: code.

    ^ ast allChildren anySatisfy: [:node | node isKindOf: RBComment].'.
	comment := 'To be "or" not to be'.
	res := commentBuilder addComment: comment to: testCommentText.
	Transcript show: 'testAddCommentTo: '; show: res lines second;cr.
	self assert: res lines second equals: comment asComment
	
]

{ #category : 'tests' }
AI_CommentBuildingTest >> testCommentClass [
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
	self 
		assert: classToBeCommented terminatePrompt 
		equals: nil.
]

{ #category : 'helper methods' }
AI_CommentBuildingTest >> testContainsComment [
	"Check that non-commented methods are fount (should only be dummyMethod"
    | result |
    
    "Check if it wrongly detects a comment"
    result := commentBuilder containsComment: (AI_CommentBuildingTest >> #dummyMethod) sourceCode.
    self deny: result.

	"Check if it wrongly detects a comment"
    result := commentBuilder containsComment: (AI_CommentBuildingTest >> #dummyCommentedMethod) sourceCode.
    self assert: result .


]

{ #category : 'helper methods' }
AI_CommentBuildingTest >> testInitialize [
	"Check that the initialize: is actually working "
   | methods  |
	methods := commentBuilder methodsToComments.
	self assert: (methods anySatisfy: [:method | method selector = #dummyMethod]) 
]

{ #category : 'tests' }
AI_CommentBuildingTest >> testNonCommentedMethods [
	"Ensure all test methods are commented, except dummyMethod"
	|  nonCommented |
	nonCommented := commentBuilder nonCommentedMethods.
	"Assert that only dummyMethod is in the list"
	self assert: (nonCommented size = 1).
	self assert: (nonCommented first selector = #dummyMethod).
]

{ #category : 'tests' }
AI_CommentBuildingTest >> testPromptForCommentTo [
	"test if the comment proposal makes sence."
	| testCommentText commentedMethod |
	"a method with no comment, could be any one"
	testCommentText := 'containsComment: code
    | ast |
    ast := RBParser parseMethod: code.

    ^ ast allChildren anySatisfy: [:node | node isKindOf: RBComment].'.
	self deny: (commentBuilder containsComment: testCommentText).
	commentedMethod := commentBuilder promptForCommentTo: testCommentText.
	self assert: (commentBuilder containsComment: commentedMethod) 
	
]

{ #category : 'tests' }
AI_CommentBuildingTest >> testProposeCommentForMethod [
	"test if the comment propsed makes sence."
	| testCommentText |
	testCommentText := 'containsComment: code
    | ast |
    ast := RBParser parseMethod: code.

    ^ ast allChildren anySatisfy: [:node | node isKindOf: RBComment].'.
	"Actual test need to be done"
	self fail.
	
]
