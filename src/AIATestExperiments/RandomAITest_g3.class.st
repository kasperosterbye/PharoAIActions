Class {
	#name : 'RandomAITest_g3',
	#superclass : 'TestCase',
	#instVars : [
		'refRandom'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
RandomAITest_g3 >> setUp [
	super setUp.
	refRandom := Random new.
]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testInitialize [
	"Test that initialize properly sets up the state of the Random instance."

	| initialState |
	initialState := refRandom state.
	self assert: initialState isNil.
	refRandom initialize.
	self deny: refRandom state isNil.
	self assert: refRandom state class equals: DoubleWordArray.
	self assert: refRandom state size equals: 1

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testMaxValue [
	"Test that maxValue returns the correct maximum value for Random numbers."

	| result |
	result := refRandom maxValue.
	self assert: result equals: 16r7FFFFFFF

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testNext [
	"Test that next: returns an array of the correct size and contains random values."

	| result |
	result := refRandom next: 5.
	self assert: result size equals: 5.
	self assert: (result allSatisfy: [ :each | each between: 0 and: 1 ])

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testNextBetweenAnd [
	"Test that nextBetween:and: returns a random float within the specified range [lowerBound, higherBound)"

	| lowerBound higherBound result |
	lowerBound := 10.0.
	higherBound := 20.0.
	result := refRandom nextBetween: lowerBound and: higherBound.

	self assert: (result >= lowerBound).
	self assert: (result < higherBound).

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testNextInteger [
	"Test that nextInteger: returns a random integer in the interval [1, anInteger]."

	| result |
	result := refRandom nextInteger: 100.
	self assert: (result between: 1 and: 100).
	self assert: result isInteger.

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testNextIntegerBetweenAnd [
	"Test that nextIntegerBetween:and: returns a random integer within the specified inclusive range."

	| result lowerBound higherBound |
	lowerBound := 5.
	higherBound := 10.

	"Generate a random number within the range"
	result := refRandom nextIntegerBetween: lowerBound and: higherBound.

	"Verify the result is within the expected range"
	self assert: (result between: lowerBound and: higherBound).

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testNextInto [
	"Test that next:into: fills the array with random values and returns it."

	| resultArray |
	resultArray := refRandom next: 3 into: (Array new: 3).
	self assert: resultArray size equals: 3.
	self assert: (resultArray allSatisfy: [ :each | each between: 0 and: 1 ]).
	self assert: resultArray identicalTo: resultArray

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testPrivateNextValue [
	"Test that privateNextValue returns a Float in the interval [0 to 1)."

	| result |
	result := refRandom privateNextValue.
	self assert: (result isKindOf: Float).
	self assert: (result >= 0).
	self assert: (result < 1)

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testRsNext [
	| result |
	result := refRandom rsNext: 100.
	self assert: (result between: 0 and: 100)

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testRsNextAnd [
	"Test that rsNext:and: returns a scaled value between u and v using self next"

	| result u v |
	u := 10.
	v := 20.
	result := refRandom rsNext: u and: v.

	self assert: (result between: u and: v).
	self assert: (result isKindOf: Number)

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testSeed [
	"Test that seed returns the correct value after initialization.
	Since the method is private, we test it indirectly by verifying its effect on the random number generation."

	| expectedSeed |
	expectedSeed := 12345.
	refRandom seed: expectedSeed.
	self assert: refRandom seed equals: expectedSeed

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testSetStateFromSeed [
	| expectedState |
	expectedState := DoubleWordArray new: 1.
	expectedState at: 1 put: refRandom seed + 1442695040888963407.
	refRandom setStateFromSeed.
	self assert: refRandom state equals: expectedState.
	self assert: (refRandom class primitiveRandomNumber: refRandom state) isInteger.

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testState [
	"Test that state returns the correct value."
	| result |
	result := refRandom state.
	self assert: result equals: refRandom state

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testUseClockBasedSeed [
	"Test that useClockBasedSeed sets a non-zero seed and initializes state correctly."

	| oldSeed |
	oldSeed := refRandom seed.
	refRandom useClockBasedSeed.
	self deny: refRandom seed equals: oldSeed.
	self deny: refRandom seed equals: 0.
	self assert: refRandom state size equals: 1.
	self assert: (refRandom state at: 1) isInteger.

]

{ #category : 'AI generated test' }
RandomAITest_g3 >> testUseUnixRandomGeneratorSeed [
	"Test that useUnixRandomGeneratorSeed correctly seeds the random generator
	from /dev/random and returns true on success, false on failure."

	| result |
	result := refRandom useUnixRandomGeneratorSeed.
	self assert: (result isKindOf: Boolean).
	"On non-Unix systems, this should return false"
	OSPlatform current isUnix
		ifTrue: [ self assert: result ]
		ifFalse: [ self deny: result ]

]
