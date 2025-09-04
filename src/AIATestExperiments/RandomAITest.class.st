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
	"Test that nextInteger: returns a random integer in the interval [1, anInteger]."

	| result |
	result := refRandom nextInteger: 100.
	self assert: (result between: 1 and: 100).
	self assert: result isInteger.

]
