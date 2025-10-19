Class {
	#name : 'RandomAITest_Grok1',
	#superclass : 'TestCase',
	#instVars : [
		'refRandom'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
RandomAITest_Grok1 >> setUp [
	super setUp.
	refRandom := Random new.
]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testInitialize [
	"Test that initialize sets the state to a DoubleWordArray of size 1."
	| random |
	random := Random basicNew.
	random initialize.
	self assert: (random state isKindOf: DoubleWordArray).
	self assert: random state size equals: 1

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testMaxValue [
	"Test that maxValue returns the expected maximum value for the random number generator."
	
	self assert: refRandom maxValue equals: 16r7FFFFFFF

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testNext [
    "Test that next returns a Float in the interval [0, 1)."
    | random result |
    random := Random new.
    result := random next.
    self assert: result isFloat.
    self assert: (result >= 0 and: [result < 1]).

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testNextBetweenAnd [
	"Test that nextBetween:and: returns a float in the inclusive lower bound and exclusive upper bound range."
	| random result lowerBound higherBound |
	random := Random new.
	lowerBound := 1.
	higherBound := 3.
	result := random nextBetween: lowerBound and: higherBound.
	self assert: result isFloat.
	self assert: (result >= lowerBound and: [result < higherBound])

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testNextInteger [
	"Test that nextInteger: returns an integer in [1, anInteger] and handles large numbers.
	Test error for non-positive anInteger."

	| random result |
	random := Random new.
	"Test with small positive integer"
	100 timesRepeat: [
		result := random nextInteger: 10.
		self assert: (result between: 1 and: 10).
		self assert: result isInteger ].
	"Test with large positive integer for cryptography handling"
	result := random nextInteger: 1000000000000.
	self assert: (result between: 1 and: 1000000000000).
	self assert: result isInteger.
	"Test error for zero"
	self should: [ random nextInteger: 0 ] raise: Error.
	"Test error for negative"
	self should: [ random nextInteger: -1 ] raise: Error

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testNextIntegerBetweenAnd [
	"Test that nextIntegerBetween:and: returns an integer within the inclusive range [lowerBound, higherBound]"
	| random lowerBound higherBound result |
	random := Random new.
	lowerBound := 1.
	higherBound := 10.
	result := random nextIntegerBetween: lowerBound and: higherBound.
	self assert: (result isInteger).
	self assert: (result between: lowerBound and: higherBound).
	"Test with different bounds"
	lowerBound := -5.
	higherBound := 5.
	result := random nextIntegerBetween: lowerBound and: higherBound.
	self assert: (result between: lowerBound and: higherBound).
	"Test edge case where lowerBound equals higherBound"
	result := random nextIntegerBetween: 7 and: 7.
	self assert: result equals: 7

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testNextInto [
	"Test that next:into: fills the array with random floats in [0,1)."
	| random array |
	random := Random new.
	array := Array new: 5.
	random next: 5 into: array.
	self assert: array size equals: 5.
	array do: [:each | 
		self assert: each isFloat.
		self assert: each >= 0.
		self assert: each < 1].

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testPrivateNextValue [
	"This test verifies that privateNextValue returns a Float in the interval [0, 1)."

	| random value |
	random := Random new.
	10 timesRepeat: [
		value := random privateNextValue.
		self assert: value isFloat.
		self assert: value >= 0.
		self assert: value < 1.
	].

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testRsNext [
	"Test the rsNext: method which should return a scaled random value between 0 and the limit."
	| limit result |
	limit := 10.
	result := refRandom rsNext: limit.
	self assert: (result isKindOf: Number).
	self assert: result >= 0.
	self assert: result < limit.

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testRsNextAnd [
	"Test that rsNext:and: returns a value scaled linearly between u and v using a random value from self next."
	| result |
	
	result := refRandom rsNext: 0 and: 10.
	
	"Assert that the result is a number"
	self assert: result isNumber.
	
	"Assert that the result is within the expected range [0, 10)"
	self assert: result >= 0.
	self assert: result < 10

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testSeed [
	"Test that the seed method returns the seed value set during initialization.
	Note: This method is private as per its comment, but we test it for completeness."
	| random |
	random := Random seed: 42.
	self assert: random seed equals: 42

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testSetStateFromSeed [
	| random seedValue expectedState result |
	seedValue := 12345.
	random := Random new seed: seedValue.
	"setStateFromSeed updates the state array based on the seed and returns self"
	result := random setStateFromSeed.
	expectedState := ((seedValue + 1442695040888963407) * 6364136223846793005 + 1442695040888963407) bitAnd: 16rFFFFFFFFFFFFFFFF.
	self assert: (random state at: 1) equals: expectedState.
	self assert: result == random

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testState [
	"Test that the state method returns the state instance variable, which should be a DoubleWordArray of size 1 after initialization."
	| random |
	random := Random new.
	self assert: (random state isKindOf: DoubleWordArray).
	self assert: random state size equals: 1

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testUseClockBasedSeed [
	"Test that useClockBasedSeed sets a non-zero seed based on the millisecond clock, retrying if necessary."
	
	| random |
	random := Random new.
	random useClockBasedSeed.
	self assert: random seed > 0.
	self assert: (random next between: 0 and: 1)

]

{ #category : 'AI generated test' }
RandomAITest_Grok1 >> testUseUnixRandomGeneratorSeed [
	"Test that useUnixRandomGeneratorSeed returns a boolean value.
	It should return true if seeding from /dev/random succeeds, false otherwise.
	Note that this method may block on systems with low entropy."

	| result |
	result := refRandom useUnixRandomGeneratorSeed.
	self assert: result

]
