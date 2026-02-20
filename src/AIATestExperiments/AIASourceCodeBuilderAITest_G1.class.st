Class {
	#name : 'AIASourceCodeBuilderAITest_G1',
	#superclass : 'TestCase',
	#instVars : [
		'refAIASourceCodeBuilder'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIASourceCodeBuilderAITest_G1 >> setUp [
	super setUp.
	refAIASourceCodeBuilder := AIASourceCodeBuilder new.
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testClassHeaderFor [
	"Test the classHeaderFor: method by generating the header for the Object class and verifying the response contains expected elements."
	
	refAIASourceCodeBuilder classHeaderFor: Object.
	
	self assert: (refAIASourceCodeBuilder response contents includesSubstring: '## Class: Object').
	self assert: (refAIASourceCodeBuilder response contents includesSubstring: '### Instance variables: ').
	self assert: (refAIASourceCodeBuilder response contents includesSubstring: '### Class comment:').
	self assert: (refAIASourceCodeBuilder response contents includesSubstring: '````markdown').
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testClassHeaderForSuperOn [
	"Test the classHeaderFor:super:on: method by generating a superclass header for ProtoObject as the superclass of Object and verifying the output starts with the expected string."

	| stream result |
	stream := WriteStream on: String new.
	refAIASourceCodeBuilder classHeaderFor: Object super: ProtoObject on: stream.
	result := stream contents.
	self assert: (result beginsWith: '## Superclass: ProtoObject for class: Object').
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testClassList [
	"Test the setter method classList: by setting a value and asserting it is correctly stored."
	| testValue |
	
	testValue := #testSymbol.
	refAIASourceCodeBuilder classList: testValue.
	self assert: refAIASourceCodeBuilder classList equals: testValue
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testClassesInPackage [
	"Test the classesInPackage: method by generating documentation for classes in a package and verifying the response stream contains expected content."

	| aPackage |
	refAIASourceCodeBuilder response: (WriteStream on: String new).
	aPackage := PackageOrganizer default packageNamed: 'AIActions'.
	refAIASourceCodeBuilder classesInPackage: aPackage.
	self assert: (refAIASourceCodeBuilder response contents includesSubstring: 'AIASourceCodeBuilder')
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testFor [
	"Test the for: method by passing a list of existing packages and verifying the output string contains expected package headers."

	| result |
	result := refAIASourceCodeBuilder for: #('BaselineOfBasicTools' 'BaselineOfAthens').
	self assert: result isString.
	self assert: (result includesSubstring: '# Package: BaselineOfBasicTools').
	self assert: (result includesSubstring: '# Package: BaselineOfAthens').
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testForClass [
	"Test the forClass: method by calling it on a class and verifying the result is a string containing the class name, and that subsequent calls return the same result due to caching."

	| result1 result2 |

	result1 := refAIASourceCodeBuilder forClass: Object.
	result2 := refAIASourceCodeBuilder forClass: Object.

	self assert: result1 = result2 description: 'Second call should return the same result as the first due to caching'.
	self assert: result1 isString description: 'Result should be a string'.
	self assert: (result1 includesSubstring: 'Object') description: 'Result should include the class name'
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testForClasses [
	"Test that forClasses: generates formatted source code for a list of classes by calling forClass: on each and returning the accumulated response contents."
	
	| result |
	result := refAIASourceCodeBuilder forClasses: {Object. Point}.
	self assert: result isString.
	self assert: (result includesSubstring: '## Class: Object').
	self assert: (result includesSubstring: '## Class: Point').
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testForMethod [
	"Test the forMethod: method by passing a method that has callers in the same package."

	| aMethod result |
	aMethod := AIASourceCodeBuilder >> #forMethod:.
	result := refAIASourceCodeBuilder forMethod: aMethod.
	self assert: result isNotNil
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testForSuperClassesOf [
	"Test the forSuperClassesOf: method with Object and a subclass"

	| result |
	refAIASourceCodeBuilder sourcePackage: 'Kernel'.
	refAIASourceCodeBuilder classList: OrderedCollection new.
	result := refAIASourceCodeBuilder forSuperClassesOf: ProtoObject.
	self assert: result equals: ''.
	result := refAIASourceCodeBuilder forSuperClassesOf: Magnitude.
	self assert: result isString.
	self assert: result isNotEmpty
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testForTagIn [
	"Test the forTag:in: method to ensure it generates source code descriptions for classes in a specific tag within a package."
	
	| result |
	result := refAIASourceCodeBuilder forTag: 'BasicObjects' in: 'Kernel'.
	self assert: result isString.
	self assert: result isNotEmpty.
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testForTagsLike [
	"Test the forTagsLike: method by passing AIASourceCodeBuilder and verifying the result is a string containing source code for classes with the same package tag."

	| result |
	result := refAIASourceCodeBuilder forTagsLike: AIASourceCodeBuilder.
	self assert: result isString.
	self assert: (result includesSubstring: '## Class: AIASourceCodeBuilder class').
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testForWildcard [
	"Test the forWildcard: method with a wildcard pattern starting with '*' to match packages beginning with 'Kernel'."

	| result |
	result := refAIASourceCodeBuilder forWildcard: '*AIA'.
	self assert: result isString.
	self assert: (result includesSubstring: '# Package: AIAActions').
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testInitialize [
	"Test that initialize sets response to a WriteStream on an empty string and classList to an empty Set."
	
	self assert: refAIASourceCodeBuilder response class equals: WriteStream.
	self assert: refAIASourceCodeBuilder response contents equals: ''.
	self assert: refAIASourceCodeBuilder classList class equals: Set.
	self assert: refAIASourceCodeBuilder classList isEmpty
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testMethodNameAndCommentForIn [
	"Test the methodNameAndCommentFor:in: method with a method that has no comment"
	| method stream expected |
	method := AIASourceCodeBuilder >> #methodNameAndCommentFor:in:.
	stream := WriteStream on: String new.
	refAIASourceCodeBuilder methodNameAndCommentFor: method in: stream.
	expected := 'Method: AIASourceCodeBuilder>>#methodNameAndCommentFor:in:' , String cr , String cr.
	self assert: stream contents equals: expected.
	
	"Test the methodNameAndCommentFor:in: method with a method that has a comment"
	stream := WriteStream on: String new.
	method := Object >> #printString.
	refAIASourceCodeBuilder methodNameAndCommentFor: method in: stream.
	expected := 'Method: Object>>#printString' , String cr , 'comment: "' , method comment , '"' , String cr , String cr.
	self assert: stream contents equals: expected
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testMethodsFor [
	"Test the methodsFor: method by calling it on a class and verifying the response includes the expected header and content"
	refAIASourceCodeBuilder methodsFor: Object.
	self assert: (refAIASourceCodeBuilder response contents includesSubstring: '### Methods for Object:').
	self assert: refAIASourceCodeBuilder response contents size > '### Methods for Object:###' size
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testResponse [
	"Test the response method which returns the WriteStream for accumulating source code."
	| result |
	
	result := refAIASourceCodeBuilder response.
	
	"Assert that response is not nil"
	self assert: result isNotNil.
	
	"Assert that response is a WriteStream"
	self assert: result class equals: WriteStream.
	
	"Assert that the WriteStream contents is an empty string as initialized"
	self assert: result contents equals: ''.
]

{ #category : 'AI generated test' }
AIASourceCodeBuilderAITest_G1 >> testStopNow [
	"Test the stopNow: method which checks if the source package differs from the given class's package."
	
	refAIASourceCodeBuilder instVarNamed: #sourcePackage put: 'Collections-Abstract'.
	
	self assert: (refAIASourceCodeBuilder stopNow: Collection) equals: false.
	self assert: (refAIASourceCodeBuilder stopNow: Array) equals: true
]
