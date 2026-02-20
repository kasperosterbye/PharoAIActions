Class {
	#name : 'AIASourceCodeBuilderAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIASourceCodeBuilder'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIASourceCodeBuilderAITest >> setUp [
	super setUp.
	refAIASourceCodeBuilder := AIASourceCodeBuilder new.
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest >> testMethodNameAndCommentForIn [
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
AIASourceCodeBuilderAITest >> testMethodNameAndCommentForIn01 [
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
