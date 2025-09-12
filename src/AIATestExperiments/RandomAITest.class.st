Class {
	#name : 'RandomAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refRandom'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
RandomAITest >> setUp [
	super setUp.
	refRandom := Random new.
]

{ #category : 'AI generated test' }
RandomAITest >> testNextInteger [
	"Test that nextInteger: returns a random integer in [1, anInteger] and handles large numbers."

	| result |
	"Test with a small positive integer"
	result := refRandom nextInteger: 10.
	self assert: (result between: 1 and: 10).

	"Test with a large number (for cryptography)"
	result := refRandom nextInteger: 16rFFFFFFFF.
	self assert: (result between: 1 and: 16rFFFFFFFF).

	"Test that it raises an error for non-positive integers"
	self should: [ refRandom nextInteger: 0 ] raise: Error.
	self should: [ refRandom nextInteger: -5 ] raise: Error.

]
