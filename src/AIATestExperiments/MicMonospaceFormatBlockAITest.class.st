Class {
	#name : 'MicMonospaceFormatBlockAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicMonospaceFormatBlock'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicMonospaceFormatBlockAITest >> setUp [
	super setUp.
	refMicMonospaceFormatBlock := MicMonospaceFormatBlock new.
]

{ #category : 'AI generated test' }
MicMonospaceFormatBlockAITest >> testAccept [
	| visitor result |
	"Ensure the block has content for proper visitation"
	refMicMonospaceFormatBlock bodyString: 'test'.
	refMicMonospaceFormatBlock closeMe.
	
	"Create a standard visitor"
	visitor := MicrodownVisitor new.
	
	"Invoke the accept: method"
	result := refMicMonospaceFormatBlock accept: visitor.
	
	"Verify that accept: delegates correctly to the visitor's visitMonospace: method"
	self assert: result equals: (visitor visitMonospace: refMicMonospaceFormatBlock)
]

{ #category : 'AI generated test' }
MicMonospaceFormatBlockAITest >> testChildren [
	"Test that children returns an empty collection for a new instance."

	self assert: refMicMonospaceFormatBlock children isEmpty
]

{ #category : 'AI generated test' }
MicMonospaceFormatBlockAITest >> testCloseMe [
	"Test that closeMe sets children to an array with a single MicTextBlock having the same bodyString, and sets the parent's basicParent correctly."

	| originalBody |
	originalBody := refMicMonospaceFormatBlock bodyString.
	refMicMonospaceFormatBlock closeMe.
	self assert: refMicMonospaceFormatBlock children size equals: 1.
	self assert: (refMicMonospaceFormatBlock children first isKindOf: MicTextBlock).
	self assert: refMicMonospaceFormatBlock children first bodyString equals: originalBody.
	self assert: refMicMonospaceFormatBlock children first basicParent equals: refMicMonospaceFormatBlock
]

{ #category : 'AI generated test' }
MicMonospaceFormatBlockAITest >> testText [
	"Test that the text method returns the bodyString of the monospace format block"
	self assert: refMicMonospaceFormatBlock text equals: refMicMonospaceFormatBlock bodyString
]
