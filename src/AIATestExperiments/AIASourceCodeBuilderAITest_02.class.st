Class {
	#name : 'AIASourceCodeBuilderAITest_02',
	#superclass : 'TestCase',
	#instVars : [
		'refAIASourceCodeBuilder'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIASourceCodeBuilderAITest_02 >> setUp [
	super setUp.
	refAIASourceCodeBuilder := AIASourceCodeBuilder new.
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testInitialize [
	"Test that AIASourceCodeBuilder initializes with an empty WriteStream and empty Set for classList."

	self assert: ((refAIASourceCodeBuilder instVarNamed: #response) isKindOf: WriteStream).
	self assert: ((refAIASourceCodeBuilder instVarNamed: #response) contents isEmpty).
	self assert: ((refAIASourceCodeBuilder instVarNamed: #classList) isKindOf: Set).
	self assert: ((refAIASourceCodeBuilder instVarNamed: #classList) isEmpty)
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testInitialize01 [
	"Test that initialize sets up an empty WriteStream for response and an empty Set for classList"

	self assert: ((refAIASourceCodeBuilder instVarNamed: #response) isKindOf: WriteStream).
	"Verify response is a WriteStream"
	
	self assert: (((refAIASourceCodeBuilder instVarNamed: #response) contents) isEmpty).
	"Verify response contents are empty"
	
	self assert: ((refAIASourceCodeBuilder instVarNamed: #classList) isKindOf: Set).
	"Verify classList is a Set"
	
	self assert: ((refAIASourceCodeBuilder instVarNamed: #classList) isEmpty).
	"Verify classList is empty"
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testInitialize02 [
	"Test that initialize sets response to a WriteStream on an empty string and classList to an empty Set."
	
	self assert: (refAIASourceCodeBuilder instVarNamed: #response) isKindOf: WriteStream.
	self assert: ((refAIASourceCodeBuilder instVarNamed: #response) contents = '').
	self assert: (refAIASourceCodeBuilder instVarNamed: #classList) isKindOf: Set.
	self assert: (refAIASourceCodeBuilder instVarNamed: #classList) isEmpty
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testInitialize03 [
	"Test that AIASourceCodeBuilder initializes with an empty WriteStream and empty Set for classList."

	self assert: (refAIASourceCodeBuilder instVarNamed: #response) isKindOf: WriteStream.
	self assert: (refAIASourceCodeBuilder instVarNamed: #classList) isKindOf: Set.
	self assert: ((refAIASourceCodeBuilder instVarNamed: #response) isEmpty).
	self assert: ((refAIASourceCodeBuilder instVarNamed: #classList) isEmpty).
	self assert: ((refAIASourceCodeBuilder instVarNamed: #response) position) equals: 0
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testMethodNameAndCommentForIn [
	| superComment methodWithComment methodWithoutComment expectedWith expectedWithout |
	
	methodWithComment := Object >> #printString.
	methodWithoutComment := Object >> #writeSlot:value:.
	
	"Test the method with a CompiledMethod that has a comment"
	superComment := WriteStream on: String new.
	refAIASourceCodeBuilder
		methodNameAndCommentFor: methodWithComment
		in: superComment.
	expectedWith := 'Method: ' , methodWithComment name , String cr ,
		'comment: "' , methodWithComment comment , '"' , String cr ,
		String cr.
	self assert: superComment contents equals: expectedWith.
	
	"Test the method with a CompiledMethod that has no comment"
	superComment := WriteStream on: String new.
	refAIASourceCodeBuilder
		methodNameAndCommentFor: methodWithoutComment
		in: superComment.
	expectedWithout := 'Method: ' , methodWithoutComment name , String cr ,
		String cr.
	self assert: superComment contents equals: expectedWithout
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testMethodNameAndCommentForIn01 [
	"Test the methodNameAndCommentFor:in: method for formatting method name and comment."
	| stream expected |
	
	"Test with a method that has no comment"
	stream := WriteStream on: String new.
	refAIASourceCodeBuilder methodNameAndCommentFor: (AIASourceCodeBuilder >> #methodNameAndCommentFor:in:) in: stream.
	expected := 'Method: methodNameAndCommentFor:in:' , String cr , String cr.
	self assert: stream contents equals: expected.
	
	"Test with a method that has a comment"
	stream := WriteStream on: String new.
	refAIASourceCodeBuilder methodNameAndCommentFor: (Object >> #=) in: stream.
	expected := 'Method: =' , String cr , 'comment: "' , (Object >> #=) comment , '"' , String cr , String cr.
	self assert: stream contents equals: expected
]
