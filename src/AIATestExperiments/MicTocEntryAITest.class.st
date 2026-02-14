Class {
	#name : 'MicTocEntryAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicTocEntry'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicTocEntryAITest >> setUp [
	super setUp.
	refMicTocEntry := MicTocEntry new.
]

{ #category : 'AI generated test' }
MicTocEntryAITest >> testAddChild [
	"Test that addChild: adds a child to the children collection"
	| childEntry |
	childEntry := MicTocEntry new.
	
	"Add the child to the reference entry"
	refMicTocEntry addChild: childEntry.
	
	"Verify the child was added to the children collection"
	self assert: (refMicTocEntry children includes: childEntry)
]

{ #category : 'AI generated test' }
MicTocEntryAITest >> testChildren [
	"Test that children method returns the children instance variable"
	"Since children is nil by default, we expect nil to be returned"
	self assert: refMicTocEntry children equals: nil
]

{ #category : 'AI generated test' }
MicTocEntryAITest >> testFor [
	"Test that for: sets the header instance variable correctly"
	| headerBlock |
	
	"Create a test header block"
	headerBlock := MicHeaderBlock new.
	
	"Call the method under test"
	refMicTocEntry for: headerBlock.
	
	"Verify the header was set correctly"
	self assert: refMicTocEntry header equals: headerBlock
]

{ #category : 'AI generated test' }
MicTocEntryAITest >> testHeader [
	"Test that header method returns the header instance variable"
	"Since the comment indicates header returns nil, we test for nil"
	self assert: refMicTocEntry header isNil
]

{ #category : 'AI generated test' }
MicTocEntryAITest >> testInitialize [
	"Test that initialize properly sets up the MicTocEntry instance"
	
	"Verify that children is initialized as an OrderedCollection"
	self assert: refMicTocEntry children class equals: OrderedCollection.
	
	"Verify that children collection is empty initially"
	self assert: refMicTocEntry children isEmpty
]

{ #category : 'AI generated test' }
MicTocEntryAITest >> testIsLeaf [
	"Test that isLeaf returns true when children collection is empty"
	"Test that isLeaf returns false when children collection has elements"
	
	| childEntry |
	childEntry := MicTocEntry new.
	
	"Test empty children - should be a leaf"
	self assert: refMicTocEntry isLeaf.
	
	"Test with children - should not be a leaf"
	refMicTocEntry children add: childEntry.
	self deny: refMicTocEntry isLeaf
]

{ #category : 'AI generated test' }
MicTocEntryAITest >> testLevel [
	| header |
	"Create a header with a known level"
	header := MicHeaderBlock new level: 2.
	"Set the header on the test instance"
	refMicTocEntry header: header.
	"Verify that level returns the header's level"
	self assert: refMicTocEntry level equals: 2
]

{ #category : 'AI generated test' }
MicTocEntryAITest >> testPrintOn [
	"Test that printOn: writes the object representation to a stream"
	| stream result |
	
	"Create a string stream to capture output"
	stream := String new writeStream.
	
	"Call printOn: with our test stream"
	refMicTocEntry printOn: stream.
	
	"Get the result from the stream"
	result := stream contents.
	
	"Verify the result is not empty"
	self deny: result isEmpty.
	
	"Verify the result contains expected content"
	self assert: (result includesSubString: 'MicTocEntry').
]
