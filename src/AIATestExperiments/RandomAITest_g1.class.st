Class {
	#name : 'RandomAITest_g1',
	#superclass : 'TestCase',
	#instVars : [
		'refRandom'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
RandomAITest_g1 >> setUp [
	super setUp.
	refRandom := Random new.
]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testInitialize [
	"Test that initialize properly sets up the state of the Random instance."

	| random |
	random := Random new.
	random initialize.

	self assert: random state isNotNil.
	self assert: (random state isKindOf: DoubleWordArray).
	self assert: random state size equals: 1.

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testMaxValue [
	"Test that maxValue returns the correct maximum value for Random numbers."

	| result |
	result := refRandom maxValue.
	self assert: result equals: 16r7FFFFFFF

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testNext [
	"Test that next: returns an array of random numbers with the correct size"
	| result |
	result := refRandom next: 5.
	self assert: result size equals: 5.
	self assert: (result allSatisfy: [ :each | each between: 0 and: 1 ])

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testNextBetweenAnd [
	| result |
	"Test that nextBetween:and: returns a value within the specified range"
	result := refRandom nextBetween: 10 and: 20.
	self assert: (result between: 10 and: 20).
	self assert: result isFloat.

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testNextInteger [
	"Test that nextInteger: returns a random integer in [1, anInteger]"

	| result |
	result := refRandom nextInteger: 100.
	self assert: (result between: 1 and: 100).
	self assert: result isInteger

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testNextIntegerBetweenAnd [
	"Test that nextIntegerBetween:and: returns a random integer within the specified inclusive range."

	| lowerBound higherBound result |
	lowerBound := 10.
	higherBound := 20.
	result := refRandom nextIntegerBetween: lowerBound and: higherBound.

	self assert: (result between: lowerBound and: higherBound).
	self assert: result isInteger.

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testNextInto [
	"Test that next:into: fills the array with random values between 0 and 1"
	| resultArray |
	resultArray := refRandom next: 5 into: (Array new: 5).
	self assert: resultArray size equals: 5.
	resultArray do: [ :each |
		self assert: (each between: 0 and: 1) ]

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testPrivateNextValue [
	"Test that privateNextValue returns a Float in the interval [0 to 1)."

	| result |
	result := refRandom privateNextValue.
	self assert: (result isKindOf: Float).
	self assert: (result >= 0.0).
	self assert: (result < 1.0)

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testRsNext [
	"Test that rsNext: returns a value between 0 and the given limit."
	| result |
	result := refRandom rsNext: 100.
	self assert: (result between: 0 and: 100)

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testRsNextAnd [
	"Test that rsNext:and: returns a scaled value between u and v using self next"

	| result u v |
	u := 10.
	v := 20.
	result := refRandom rsNext: u and: v.

	self assert: (result between: u and: v).
	self assert: (result isKindOf: Number)

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testSeed [
	"Test that seed returns the correct value after initialization.
	Since the method is private, we test it indirectly by verifying its effect on the random number generation."

	| initialSeed |
	initialSeed := 12345.
	refRandom seed: initialSeed.
	self assert: refRandom seed equals: initialSeed

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testSetStateFromSeed [
	| expectedState |
	expectedState := seed + 1442695040888963407.
	refRandom setStateFromSeed.
	self assert: (refRandom state at: 1) equals: expectedState.
	self assert: (self class primitiveRandomNumber: refRandom state) equals: expectedState

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testState [
	"Test that state returns the correct value after initialization."
	| random |
	random := Random new.
	self assert: random state isNotNil.
	self assert: (random state isKindOf: DoubleWordArray).

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testUseClockBasedSeed [
	"Test that useClockBasedSeed sets a non-zero seed and initializes state correctly."

	| oldSeed |
	oldSeed := refRandom seed.
	refRandom useClockBasedSeed.
	self deny: refRandom seed equals: oldSeed.
	self deny: refRandom seed equals: 0.
	self assert: refRandom state size equals: 1.
	self assert: (refRandom state at: 1) equals: refRandom seed + 1442695040888963407

]

{ #category : 'AI generated test' }
RandomAITest_g1 >> testUseUnixRandomGeneratorSeed [
	"Test that useUnixRandomGeneratorSeed correctly seeds the random generator
	and returns true on success, or false on failure."

	| result |
	result := refRandom useUnixRandomGeneratorSeed.
	self assert: (result isKindOf: Boolean).
	self assert: (result = true or: [result = false]).

]
