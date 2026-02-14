Class {
	#name : 'MicSingleLineBlockAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicSingleLineBlock'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicSingleLineBlockAITest >> setUp [
	super setUp.
	refMicSingleLineBlock := MicSingleLineBlock new.
]

{ #category : 'AI generated test' }
MicSingleLineBlockAITest >> testAddLineAndReturnNextNode [
	"Test that addLineAndReturnNextNode: skips the rest of the line by default."

	| result |
	result := refMicSingleLineBlock addLineAndReturnNextNode: 'some line'.
	self assert: result equals: refMicSingleLineBlock
]
