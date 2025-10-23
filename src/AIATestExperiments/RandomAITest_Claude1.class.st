Class {
	#name : 'RandomAITest_Claude1',
	#superclass : 'TestCase',
	#instVars : [
		'refRandom'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
RandomAITest_Claude1 >> setUp [
	super setUp.
	refRandom := Random new.
]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testInitialize [
	"Test that initialize properly sets up the Random instance"
	| random |
	
	random := Random new.
	
	"Test that state is initialized as a DoubleWordArray with size 1"
	self assert: random state class equals: DoubleWordArray.
	self assert: random state size equals: 1

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testMaxValue [
	"Test that maxValue returns the expected hexadecimal constant"
	| expectedValue actualValue |
	
	"The expected maximum value is 16r7FFFFFFF (2147483647 in decimal)"
	expectedValue := 16r7FFFFFFF.
	
	"Get the actual value from the method"
	actualValue := random maxValue.
	
	"Assert they are equal"
	self assert: actualValue equals: expectedValue

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testNext [
	"Test that next returns a Float in the interval [0 to 1)"
	| result |
	
	"Get a random float from the generator"
	result := random next.
	
	"Verify it is a Float"
	self assert: result class equals: Float.
	
	"Verify it is >= 0"
	self assert: result >= 0.
	
	"Verify it is < 1"
	self assert: result < 1

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testNextBetweenAnd [
	"Test that nextBetween:and: returns a float in the correct range [lowerBound, higherBound)"
	| result lowerBound higherBound random |
	
	random := Random new.
	lowerBound := 5.0.
	higherBound := 10.0.
	
	"Test that result is within the expected range"
	result := random nextBetween: lowerBound and: higherBound.
	self assert: result >= lowerBound.
	self assert: result < higherBound.
	
	"Test with negative bounds"
	result := random nextBetween: -10.0 and: -5.0.
	self assert: result >= -10.0.
	self assert: result < -5.0.
	
	"Test with zero as lower bound"
	result := random nextBetween: 0.0 and: 1.0.
	self assert: result >= 0.0.
	self assert: result < 1.0.

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testNextInteger [
	"Test that nextInteger: returns values in the correct range [1, anInteger]"
	| result results |
	
	"Test basic functionality with small numbers"
	result := random nextInteger: 10.
	self assert: result >= 1.
	self assert: result <= 10.
	self assert: result isInteger.
	
	"Test with larger numbers"
	result := random nextInteger: 1000.
	self assert: result >= 1.
	self assert: result <= 1000.
	
	"Test that multiple calls produce different results (statistical test)"
	results := Set new.
	100 timesRepeat: [ results add: (random nextInteger: 100) ].
	self assert: results size > 10.
	
	"Test error handling for non-positive input"
	self should: [ random nextInteger: 0 ] raise: Error.
	self should: [ random nextInteger: -5 ] raise: Error.

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testNextIntegerBetweenAnd [
	"Test that nextIntegerBetween:and: returns integers within the specified inclusive range"
	| result lowerBound higherBound |
	lowerBound := 5.
	higherBound := 10.
	
	"Test that result is within bounds"
	result := random nextIntegerBetween: lowerBound and: higherBound.
	self assert: result >= lowerBound.
	self assert: result <= higherBound.
	
	"Test with equal bounds"
	result := random nextIntegerBetween: 7 and: 7.
	self assert: result = 7.
	
	"Test with negative numbers"
	result := random nextIntegerBetween: -5 and: -1.
	self assert: result >= -5.
	self assert: result <= -1.

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testNextInto [
	"Test that next:into: fills the array with random values and returns the array"
	| array result |
	array := Array new: 5.
	result := random next: 5 into: array.
	
	"Test that the method returns the same array that was passed in"
	self assert: result identicalTo: array.
	
	"Test that all positions in the array are filled with Float values between 0 and 1"
	1 to: 5 do: [:index |
		| value |
		value := array at: index.
		self assert: value isFloat.
		self assert: value >= 0.0.
		self assert: value < 1.0].
	
	"Test that the array contains different values (very unlikely to be all the same)"
	self deny: (array allSatisfy: [:each | each = (array at: 1)])

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testPrivateNextValue [
	"Test that privateNextValue returns a Float in the interval [0 to 1)"
	| result |
	
	"Get a random value from privateNextValue"
	result := random privateNextValue.
	
	"Assert it is a Float"
	self assert: result isFloat.
	
	"Assert it is >= 0"
	self assert: result >= 0.
	
	"Assert it is < 1"
	self assert: result < 1

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testRsNext [
	"Test that rsNext: with a single limit parameter delegates to rsNext:and: with 0 as lower bound"
	| result limit |
	limit := 10.
	
	"Test that rsNext: returns a value between 0 and the limit"
	result := random rsNext: limit.
	self assert: result >= 0.
	self assert: result <= limit

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testRsNextAnd [
	"Test that rsNext:and: returns a value between the two provided bounds"
	| result lowerBound upperBound |
	lowerBound := 10.
	upperBound := 20.
	result := random rsNext: lowerBound and: upperBound.
	self assert: result >= lowerBound.
	self assert: result <= upperBound

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testSeed [
	"Test that seed method returns the internal seed value"
	| testSeed retrievedSeed |
	
	"Create a random generator with a known seed"
	testSeed := 12345.
	random := Random seed: testSeed.
	
	"Retrieve the seed using the seed method"
	retrievedSeed := random seed.
	
	"Verify the seed matches what was set"
	self assert: retrievedSeed equals: testSeed

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testSetStateFromSeed [
	"Test that setStateFromSeed properly initializes the state array with seed plus constant"
	| initialSeed expectedStateValue |
	
	"Set a known seed value"
	initialSeed := 12345.
	random seed: initialSeed.
	
	"Calculate expected state value"
	expectedStateValue := initialSeed + 1442695040888963407.
	
	"Call the method under test"
	random setStateFromSeed.
	
	"Verify state was set correctly"
	self assert: (random state at: 1) equals: expectedStateValue.
	
	"Verify the method returns the receiver"
	self assert: random setStateFromSeed equals: random

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testState [
	"Test that state returns the internal state instance variable"
	| initialState |
	
	"Get the initial state after setup"
	initialState := random state.
	
	"Verify state returns the same object consistently"
	self assert: random state equals: initialState.
	
	"Verify state is not nil after initialization"
	self deny: random state isNil

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testUseClockBasedSeed [
	| initialSeed finalSeed |
	"Store initial seed value"
	initialSeed := random seed.
	
	"Execute the method under test"
	random useClockBasedSeed.
	
	"Get the seed after execution"
	finalSeed := random seed.
	
	"Verify that seed was changed"
	self deny: finalSeed = initialSeed.
	
	"Verify that seed is not zero"
	self deny: finalSeed = 0.
	
	"Verify that seed is a positive integer"
	self assert: finalSeed > 0

]

{ #category : 'AI generated test' }
RandomAITest_Claude1 >> testUseUnixRandomGeneratorSeed [
	| random result |
	"Create a new Random instance for testing"
	random := Random new.
	
	"Call the method under test"
	result := random useUnixRandomGeneratorSeed.
	
	"Verify the method returns a boolean"
	self assert: (result isKindOf: Boolean).
	
	"If successful, verify the seed was set to a non-zero value"
	result ifTrue: [
		self deny: random seed equals: 0
	]

]
