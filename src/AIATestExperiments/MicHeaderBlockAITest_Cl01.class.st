Class {
	#name : 'MicHeaderBlockAITest_Cl01',
	#superclass : 'TestCase',
	#instVars : [
		'refMicHeaderBlock'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicHeaderBlockAITest_Cl01 >> setUp [
	super setUp.
	refMicHeaderBlock := MicHeaderBlock new.
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest_Cl01 >> testAccept [
	"Test that accept: delegates to the visitor's visitHeader: method"
	| visitor result |
	visitor := MicTextualMicrodownExporter new.
	result := refMicHeaderBlock accept: visitor.
	"Verify that accept: returns the result of visitHeader:"
	self assert: result isNotNil
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest_Cl01 >> testAddLineAndReturnNextNode [
	"Test that addLineAndReturnNextNode: correctly parses a header line"
	| result line |
	
	"Set up a test line with a level 4 header"
	line := '#### my heading at fourth level'.
	
	"Call the method under test"
	result := refMicHeaderBlock addLineAndReturnNextNode: line.
	
	"Verify the method returns self (the same instance)"
	self assert: result identicalTo: refMicHeaderBlock.
	
	"Verify the level is correctly parsed as 4"
	self assert: refMicHeaderBlock level equals: 4.
	
	"Verify children is an OrderedCollection and not empty"
	self assert: refMicHeaderBlock children isNotEmpty.
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest_Cl01 >> testFormattedCode [
	"Test that formattedCode returns a string combining super formattedCode with level and header"
	| result |
	"Set up the header block with a level and header text"
	refMicHeaderBlock level: 2.
	refMicHeaderBlock header: 'Test Header'.
	"Execute the method under test"
	result := refMicHeaderBlock formattedCode.
	"Verify the result contains the expected level and header"
	self assert: (result includesSubstring: '[ 2/Test Header ]')
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest_Cl01 >> testHeader [
	"Test that header returns a string built from the bodyString of all children"
	| child1 child2 result |
	child1 := MicTextBlock new.
	child1 bodyString: 'Hello '.
	child2 := MicTextBlock new.
	child2 bodyString: 'World'.
	refMicHeaderBlock addChild: child1.
	refMicHeaderBlock addChild: child2.
	result := refMicHeaderBlock header.
	self assert: result equals: 'Hello World'
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest_Cl01 >> testHeaderElements [
	"Test that headerElements: sets the children of the MicHeaderBlock"
	| testCollection |
	testCollection := { 'element1'. 'element2'. 'element3' }.
	
	"Send headerElements: with the test collection"
	refMicHeaderBlock headerElements: testCollection.
	
	"Verify that children was set correctly"
	self assert: refMicHeaderBlock children equals: testCollection
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest_Cl01 >> testIsHeader [
	"Test that isHeader returns true for a MicHeaderBlock instance"
	self assert: refMicHeaderBlock isHeader equals: true
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest_Cl01 >> testLevel [
	"Test that level returns the level instance variable value"
	
	| result |
	"Set a level value on the header block"
	refMicHeaderBlock level: 2.
	
	"Get the level"
	result := refMicHeaderBlock level.
	
	"Verify the level is returned correctly"
	self assert: result equals: 2
]

{ #category : 'AI generated test' }
MicHeaderBlockAITest_Cl01 >> testPrintOn [
	"Test that printOn: writes the class name followed by ' - ' and the header text to a stream"
	| stream result |
	
	"Set up the header block with a known header value"
	refMicHeaderBlock header: 'Test Header'.
	
	"Create a stream to capture the output"
	stream := WriteStream on: String new.
	
	"Execute the method under test"
	refMicHeaderBlock printOn: stream.
	
	"Get the result from the stream"
	result := stream contents.
	
	"Verify the result contains the expected header text"
	self assert: (result includesSubstring: ' - Test Header')
]
