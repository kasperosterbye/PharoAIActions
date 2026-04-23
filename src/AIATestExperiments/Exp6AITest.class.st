Class {
	#name : 'Exp6AITest',
	#superclass : 'TestCase',
	#instVars : [
		'refExp6'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
Exp6AITest >> setUp [
	super setUp.
	refExp6 := Exp6 new.
]

{ #category : 'AI generated test' }
Exp6AITest >> testSubtractTwoArg [
	"Test the subtractTwo: method with various inputs"
	| result |
	
	"Test with value greater than 2 - should create new instance and recurse"
	result := refExp6 subtractTwo: 5.
	self assert: (result = 1).
	
	"Test with value equal to 2 - should return 0"
	result := refExp6 subtractTwo: 2.
	self assert: (result = 0).
	
	"Test with value less than 2 - should return value directly"
	result := refExp6 subtractTwo: 1.
	self assert: (result = -1).
	
	"Test with value 0 - should return -2"
	result := refExp6 subtractTwo: 0.
	self assert: (result = -2).
]
