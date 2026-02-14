Class {
	#name : 'MicInlineHttpBlockAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicInlineHttpBlock'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicInlineHttpBlockAITest >> setUp [
	super setUp.
	refMicInlineHttpBlock := MicInlineHttpBlock new.
]

{ #category : 'AI generated test' }
MicInlineHttpBlockAITest >> testAccept [
	"Test that accept: raises an error as it should not be instantiated and used by visitor"

	self
		should: [ refMicInlineHttpBlock accept: nil ]
		raise: Error
		whoseDescriptionIncludes: 'I should not be instantiatied and used by visitor'
]
