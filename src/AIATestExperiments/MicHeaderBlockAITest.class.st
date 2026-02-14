Class {
	#name : 'MicHeaderBlockAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicHeaderBlock'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicHeaderBlockAITest >> setUp [
	super setUp.
	refMicHeaderBlock := MicHeaderBlock new.
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest >> testAccept [
	| visitor result1 result2 |
	visitor := MicrodownVisitor new.
	result1 := refMicHeaderBlock accept: visitor.
	result2 := visitor visitHeader: refMicHeaderBlock.
	self assert: result1 equals: result2
	"Verifies that accept: correctly delegates to the visitor's visitHeader: method, returning the same result as direct invocation."
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest >> testAddLineAndReturnNextNode [
	"Test that addLineAndReturnNextNode: sets level and children correctly and returns self"

	| line result |
	"Given a markdown header line with four # characters"
	line := '#### my heading at forth level'.

	"When we add the line to the MicHeaderBlock"
	result := refMicHeaderBlock addLineAndReturnNextNode: line.

	"Then the level should be 4"
	self assert: refMicHeaderBlock level equals: 4.

	"And the children should contain the parsed inline content"
	self assert: refMicHeaderBlock children notEmpty.

	"And the method should return the receiver"
	self assert: result identicalTo: refMicHeaderBlock
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest >> testFormattedCode [
	"Test that formattedCode returns a string containing the level and header information"
	| result |
	"Set up the header block with a level and header text"
	refMicHeaderBlock level: 2.
	refMicHeaderBlock header: 'Test Header'.
	"Call the method under test"
	result := refMicHeaderBlock formattedCode.
	"Verify the result contains the expected level and header"
	self assert: (result includesSubstring: '2').
	self assert: (result includesSubstring: 'Test Header')
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest >> testHeader [
	| child1 child2 expected |
	"Create two text children with known body strings"
	child1 := MicTextBlock new.
	child1 bodyString: 'hello'.
	child2 := MicTextBlock new.
	child2 bodyString: ' world'.
	
	"Add the children to the header block"
	refMicHeaderBlock addChild: child1.
	refMicHeaderBlock addChild: child2.
	
	"Define the expected concatenated string"
	expected := 'hello world'.
	
	"Assert that header returns the concatenation of children's bodyStrings"
	self assert: refMicHeaderBlock header equals: expected
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest >> testHeaderElements [
	| testCollection |
	testCollection := OrderedCollection new.
	"Test that headerElements: sets the children instance variable correctly"
	refMicHeaderBlock headerElements: testCollection.
	self assert: refMicHeaderBlock children equals: testCollection.
	"Test that the method returns self implicitly"
	self assert: (refMicHeaderBlock headerElements: testCollection) equals: refMicHeaderBlock
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest >> testIsHeader [
	"Test that isHeader returns true for a MicHeaderBlock instance"
	self assert: refMicHeaderBlock isHeader
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest >> testLevel [
	"Test that the level accessor returns nil for a newly initialized MicHeaderBlock instance."

	self assert: refMicHeaderBlock level isNil
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest >> testPrintOn [
	"Test that printOn: appends ' - ' followed by the header to the superclass representation."

	| contents |
	refMicHeaderBlock addLineAndReturnNextNode: '# Test Header'.
	contents := String streamContents: [ :s | refMicHeaderBlock printOn: s ].
	self assert: contents equals: 'a MicHeaderBlock - Test Header'
]
