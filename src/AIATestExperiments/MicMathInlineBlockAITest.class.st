Class {
	#name : 'MicMathInlineBlockAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicMathInlineBlock'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicMathInlineBlockAITest >> setUp [
	super setUp.
	refMicMathInlineBlock := MicMathInlineBlock new.
]

{ #category : 'AI generated test' }
MicMathInlineBlockAITest >> testAccept [
	| visitor result |
	"Create a dummy visitor object"
	visitor := Object new.
	"Compile a simple visitMathInline: method that returns a specific value"
	visitor class compile: 'visitMathInline: anObject ^ #mathInlineVisited'.
	"Invoke accept: on the reference instance"
	result := refMicMathInlineBlock accept: visitor.
	"Assert that accept: delegates to visitMathInline: and returns its result"
	self assert: result equals: #mathInlineVisited
]
