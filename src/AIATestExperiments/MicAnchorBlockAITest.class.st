Class {
	#name : 'MicAnchorBlockAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicAnchorBlock'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicAnchorBlockAITest >> setUp [
	super setUp.
	refMicAnchorBlock := MicAnchorBlock new.
]

{ #category : 'AI generated test' }
MicAnchorBlockAITest >> testAccept [
	| dumper result contents |
	
	"Set a label for the anchor block to avoid nil error in dumping"
	refMicAnchorBlock label: 'mylabel'.
	
	"Create a real dumper visitor"
	dumper := MicRealDumper new.
	
	"Perform the accept: call"
	result := refMicAnchorBlock accept: dumper.
	
	"Assert that accept: returns the visitor (implicit return of visitAnchor:)"
	self assert: result equals: dumper.
	
	"Get the dumped contents"
	contents := dumper contents.
	
	"Assert the dumped representation is correct"
	self assert: contents equals: '(MicAnchorBlock new textElement: " mylabel ")'
]

{ #category : 'AI generated test' }
MicAnchorBlockAITest >> testAddLineAndReturnNextNode [
	| line result |
	"Test that the method sets the label from the provided line after the anchor markup"
	line := '@myanchor'.
	result := refMicAnchorBlock addLineAndReturnNextNode: line.
	self assert: result equals: refMicAnchorBlock.
	self assert: refMicAnchorBlock label equals: 'myanchor'
]

{ #category : 'AI generated test' }
MicAnchorBlockAITest >> testAnchorLabel [
	"Test that anchorLabel returns the same as label, as per its implementation."

	self assert: refMicAnchorBlock anchorLabel equals: refMicAnchorBlock label
]

{ #category : 'AI generated test' }
MicAnchorBlockAITest >> testHasLabel [
	"Test that hasLabel returns false when label is nil and true otherwise."

	| originalLabel |
	originalLabel := refMicAnchorBlock label.
	
	refMicAnchorBlock label: nil.
	self assert: refMicAnchorBlock hasLabel not.
	
	refMicAnchorBlock label: 'test label'.
	self assert: refMicAnchorBlock hasLabel.
	
	"Restore original label"
	refMicAnchorBlock label: originalLabel
]

{ #category : 'AI generated test' }
MicAnchorBlockAITest >> testLabel [
	"Test that label: sets the label correctly and returns self"

	refMicAnchorBlock label: 'testLabel'.
	self assert: refMicAnchorBlock label equals: 'testLabel'.
	self assert: (refMicAnchorBlock label: 'anotherLabel') equals: refMicAnchorBlock
]

{ #category : 'AI generated test' }
MicAnchorBlockAITest >> testPrintOn [
	| stream1 stream2 expected |
	"Test the printOn: behavior when label is nil"
	stream1 := WriteStream on: String new.
	refMicAnchorBlock printOn: stream1.
	
	"Set a non-nil label and test printing again"
	refMicAnchorBlock label: 'testLabel'.
	stream2 := WriteStream on: String new.
	refMicAnchorBlock printOn: stream2.
	
	"Verify that the output appends ' (testLabel)' to the super printOn: result"
	expected := stream1 contents , ' (testLabel)'.
	self assert: stream2 contents equals: expected
]

{ #category : 'AI generated test' }
MicAnchorBlockAITest >> testTarget [
	| headerBlock |
	headerBlock := MicHeaderBlock new.
	"Test that target: sets the target correctly"
	refMicAnchorBlock target: headerBlock.
	self assert: refMicAnchorBlock target equals: headerBlock.
	"Test that target: returns self"
	self assert: (refMicAnchorBlock target: headerBlock) equals: refMicAnchorBlock
]
