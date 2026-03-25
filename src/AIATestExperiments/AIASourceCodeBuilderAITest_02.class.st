Class {
	#name : 'AIASourceCodeBuilderAITest_02',
	#superclass : 'TestCase',
	#instVars : [
		'refAIASourceCode'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIASourceCodeBuilderAITest_02 >> setUp [
	super setUp.
	refAIASourceCode := AIASourceCode new.
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testInitialize [
	"Test that AIASourceCodeBuilder initializes with an empty WriteStream and empty Set for classList."

	self assert: ((refAIASourceCode instVarNamed: #response) isKindOf: WriteStream).
	self assert: ((refAIASourceCode instVarNamed: #response) contents isEmpty).
	self assert: ((refAIASourceCode instVarNamed: #classList) isKindOf: Set).
	self assert: ((refAIASourceCode instVarNamed: #classList) isEmpty)
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testInitialize01 [
	"Test that initialize sets up an empty WriteStream for response and an empty Set for classList"

	self assert: ((refAIASourceCode instVarNamed: #response) isKindOf: WriteStream).
	"Verify response is a WriteStream"
	
	self assert: (((refAIASourceCode instVarNamed: #response) contents) isEmpty).
	"Verify response contents are empty"
	
	self assert: ((refAIASourceCode instVarNamed: #classList) isKindOf: Set).
	"Verify classList is a Set"
	
	self assert: ((refAIASourceCode instVarNamed: #classList) isEmpty).
	"Verify classList is empty"
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testInitialize02 [
	"Test that initialize sets response to a WriteStream on an empty string and classList to an empty Set."
	
	self assert: (refAIASourceCode instVarNamed: #response) isKindOf: WriteStream.
	self assert: ((refAIASourceCode instVarNamed: #response) contents = '').
	self assert: (refAIASourceCode instVarNamed: #classList) isKindOf: Set.
	self assert: (refAIASourceCode instVarNamed: #classList) isEmpty
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testInitialize03 [
	"Test that AIASourceCodeBuilder initializes with an empty WriteStream and empty Set for classList."

	self assert: (refAIASourceCode instVarNamed: #response) isKindOf: WriteStream.
	self assert: (refAIASourceCode instVarNamed: #classList) isKindOf: Set.
	self assert: ((refAIASourceCode instVarNamed: #response) isEmpty).
	self assert: ((refAIASourceCode instVarNamed: #classList) isEmpty).
	self assert: ((refAIASourceCode instVarNamed: #response) position) equals: 0
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_02 >> testMethodNameAndCommentForIn [
	| superComment methodWithComment methodWithoutComment expectedWith expectedWithout |
	
	methodWithComment := Object >> #printString.
	methodWithoutComment := Object >> #writeSlot:value:.
	
	"Test the method with a CompiledMethod that has a comment"
	superComment := WriteStream on: String new.
	refAIASourceCode
		methodNameAndCommentFor: methodWithComment
		in: superComment.
	expectedWith := 'Method: ' , methodWithComment name , String cr ,
		'comment: "' , methodWithComment comment , '"' , String cr ,
		String cr.
	self assert: superComment contents equals: expectedWith.
	
	"Test the method with a CompiledMethod that has no comment"
	superComment := WriteStream on: String new.
	refAIASourceCode
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
	refAIASourceCode methodNameAndCommentFor: (AIASourceCode >> #methodNameAndCommentFor:in:) in: stream.
	expected := 'Method: methodNameAndCommentFor:in:' , String cr , String cr.
	self assert: stream contents equals: expected.
	
	"Test with a method that has a comment"
	stream := WriteStream on: String new.
	refAIASourceCode methodNameAndCommentFor: (Object >> #=) in: stream.
	expected := 'Method: =' , String cr , 'comment: "' , (Object >> #=) comment , '"' , String cr , String cr.
	self assert: stream contents equals: expected
]
