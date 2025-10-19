Class {
	#name : 'RandomAITest_Grok2',
	#superclass : 'TestCase',
	#instVars : [
		'refRandom'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
RandomAITest_Grok2 >> setUp [
	super setUp.
	refRandom := Random new.
]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testInitialize [
	"Test that initialize sets state to a DoubleWordArray of size 1."
	| random |
	random := Random basicNew.
	random initialize.
	self assert: (random state isKindOf: DoubleWordArray).
	self assert: random state size equals: 1

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testMaxValue [
	"Test that maxValue returns the expected maximum value for the random number generator."
	| generator |
	generator := Random new.
	self assert: generator maxValue equals: 16r7FFFFFFF

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testNext [
	"Test that the next method returns a Float in the interval [0, 1)."
	| random result |
	random := Random new.
	result := random next.
	self assert: result isFloat.
	self assert: (result >= 0 and: [result < 1])

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testNextBetweenAnd [
	"Test that nextBetween:and: returns a float in the inclusive-exclusive range [lowerBound, higherBound)"
	| random result lowerBound higherBound |
	random := Random new.
	lowerBound := 5.
	higherBound := 10.
	result := random nextBetween: lowerBound and: higherBound.
	self assert: result isFloat.
	self assert: (result >= lowerBound and: [result < higherBound])

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testNextInteger [
	"Test that nextInteger: returns a random integer in the interval [1, anInteger] and handles large numbers.
	It should raise an error if anInteger is not strictly positive."

	| random result largeNumber |

	random := Random new.

	"Test with a small positive integer"
	result := random nextInteger: 10.
	self assert: (result isInteger and: [result between: 1 and: 10]).

	"Test with a large number to ensure it handles cryptography-sized ranges"
	largeNumber := 16rFFFFFFFFFFFFFFFF. "A very large number"
	result := random nextInteger: largeNumber.
	self assert: (result isInteger and: [result between: 1 and: largeNumber]).

	"Test error case: anInteger not strictly positive"
	self should: [random nextInteger: 0] raise: Error.
	self should: [random nextInteger: -1] raise: Error.

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testNextIntegerBetweenAnd [
	"Test that nextIntegerBetween:and: returns integers within the inclusive range [lowerBound, higherBound]"
	| random result lowerBound higherBound |
	random := Random new.
	lowerBound := 1.
	higherBound := 10.
	100 timesRepeat: [
		result := random nextIntegerBetween: lowerBound and: higherBound.
		self assert: (result between: lowerBound and: higherBound).
		self assert: result isInteger ].
	"Test edge case where lowerBound equals higherBound"
	result := random nextIntegerBetween: 5 and: 5.
	self assert: result equals: 5.
	"Test with negative bounds"
	lowerBound := -10.
	higherBound := -1.
	100 timesRepeat: [
		result := random nextIntegerBetween: lowerBound and: higherBound.
		self assert: (result between: lowerBound and: higherBound).
		self assert: result isInteger ]

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testNextInto [
	"Test that next:into: fills the specified number of positions in the array with random floats between 0 and 1, and returns the array."
	| generator array result |
	generator := Random new.
	array := Array new: 5.
	result := generator next: 3 into: array.
	self assert: result equals: array.
	1 to: 3 do: [:index |
		| value |
		value := array at: index.
		self assert: value isFloat.
		self assert: value >= 0.
		self assert: value < 1].
	4 to: 5 do: [:index |
		self assert: (array at: index) isNil]

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testPrivateNextValue [
	"Test that privateNextValue returns a random integer in the range [0, maxValue], as per its implementation. Note: the method's comment incorrectly states it returns a Float, but the code returns an integer."
	| random value |
	random := Random new.
	value := random privateNextValue.
	self assert: value isInteger.
	self assert: (value between: 0 and: random maxValue).

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testRsNext [
	"Test that rsNext: returns a value between 0 and the limit."
	| random result limit |
	random := Random new.
	limit := 10.
	result := random rsNext: limit.
	self assert: (result >= 0 and: [result < limit])

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testRsNextAnd [
	| random result u v |
	"Test that rsNext:and: returns a value scaled linearly between u and v"
	u := 0.
	v := 10.
	random := Random seed: 42.  "Use a fixed seed for reproducible results"
	
	result := random rsNext: u and: v.
	
	"Assert that the result is a number within the specified range"
	self assert: result isNumber.
	self assert: (result between: u and: v)

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testSeed [
	"This test verifies that the seed method returns the seed value that was set during initialization, despite being in the private protocol."
	| random |
	random := Random seed: 123.
	self assert: random seed equals: 123

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testSetStateFromSeed [
	"Test that setStateFromSeed initializes the state from the seed and allows subsequent random number generation."
	| random value |
	random := Random seed: 42.
	random setStateFromSeed.
	value := random next.
	self assert: value >= 0.
	self assert: value < 1.

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testState [
    "Test that the state method returns the state instance variable, which is a DoubleWordArray of size 1."
    | random |
    random := Random new.
    self assert: (random state isKindOf: DoubleWordArray).
    self assert: random state size equals: 1

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testUseClockBasedSeed [
	"Test that useClockBasedSeed sets a non-zero seed based on the millisecond clock and self hash, ensuring the seed is positive and the generator is initialized."

	| random |
	random := Random new.
	random useClockBasedSeed.
	"Assert that the seed is set to a positive integer value, not zero"
	self assert: random seed > 0.
	self assert: random seed isInteger.
	"Assert that the random generator can produce a valid random float in [0, 1)"
	self assert: (random next >= 0 and: [random next < 1])

]

{ #category : 'AI generated test' }
RandomAITest_Grok2 >> testUseUnixRandomGeneratorSeed [
	"Test that useUnixRandomGeneratorSeed returns a boolean value.
	It should return true if seeding from /dev/random succeeds, false otherwise.
	On systems without /dev/random, it will likely return false due to Error."

	| result |
	result := refRandom useUnixRandomGeneratorSeed.
	self assert: result 

]
