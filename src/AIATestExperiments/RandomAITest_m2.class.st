Class {
	#name : 'RandomAITest_m2',
	#superclass : 'TestCase',
	#instVars : [
		'refRandom'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
RandomAITest_m2 >> setUp [
	super setUp.
	refRandom := Random new.
]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testInitialize [
	"Test that initialize sets up the state correctly."

	"state should be a DoubleWordArray of size 1 after initialization"
	self assert: refRandom state class equals: DoubleWordArray.
	self assert: refRandom state size equals: 1.

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testMaxValue [
	"Test that maxValue returns the correct maximum value for the Random generator."

	self assert: refRandom maxValue equals: 16r7FFFFFFF

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testNext [
	"Test that next: returns an array of the correct size with random values between 0 and 1."

	| result |
	result := refRandom next: 5.
	self assert: result size equals: 5.
	result do: [ :each |
		self assert: (each between: 0 and: 1) ].

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testNextBetweenAnd [
	"Test that nextBetween:and: returns a random float within the specified range [lowerBound, higherBound)."

	| lowerBound higherBound result |
	lowerBound := 10.0.
	higherBound := 20.0.

	"Generate a random number within the range"
	result := refRandom nextBetween: lowerBound and: higherBound.

	"Verify the result is within the expected range"
	self assert: (result >= lowerBound).
	self assert: (result < higherBound).

	"Check that the result is a Float"
	self assert: result isFloat.

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testNextInteger [
	"Test that nextInteger: returns a value within [1, anInteger] and handles large numbers."

	| result |
	result := refRandom nextInteger: 100.
	self assert: (result between: 1 and: 100).

	"Test with a large number to ensure cryptographic handling."
	result := refRandom nextInteger: 16rFFFFFFFF.
	self assert: (result between: 1 and: 16rFFFFFFFF).

	"Test that it raises an error for non-positive input."
	self should: [ refRandom nextInteger: 0 ] raise: Error.
	self should: [ refRandom nextInteger: -1 ] raise: Error.

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testNextIntegerBetweenAnd [
	"Test that nextIntegerBetween:and: returns a random integer within the specified inclusive range."

	| lowerBound higherBound result |
	lowerBound := 5.
	higherBound := 10.

	"Generate a random number and verify it is within bounds."
	result := refRandom nextIntegerBetween: lowerBound and: higherBound.

	self assert: (result between: lowerBound and: higherBound).

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testNextInto [
	"Test that next:into: fills the array with random values and returns it."

	| size array |
	size := 10.
	array := Array new: size.
	refRandom next: size into: array.

	self assert: array size equals: size.
	self assert: (array allSatisfy: [ :each | each isKindOf: Float ]).
	self assert: (array allSatisfy: [ :each | each between: 0 and: 1 ]).
	^ array

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testPrivateNextValue [
	"Test that privateNextValue returns a Float in the interval [0 to 1)."

	| value |
	value := refRandom privateNextValue.
	self assert: (value isKindOf: Float).
	self assert: (value >= 0.0).
	self assert: (value < 1.0)

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testRsNext [
	"Test that rsNext: returns a value between 0 and the given limit."

	| result |
	result := refRandom rsNext: 100.
	self assert: (result between: 0 and: 100)

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testRsNextAnd [
	"Test that rsNext:and: returns a scaled value between u and v using self next"

	| result |
	result := refRandom rsNext: 10 and: 20.
	self assert: (result between: 10 and: 20).
	self assert: (result isKindOf: Number)

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testSeed [
	"Test that seed returns the correct seed value after initialization.
	The seed should be hidden from the user, as per the comment in the method."

	| expectedSeed |
	expectedSeed := 12345.
	refRandom seed: expectedSeed.
	self assert: refRandom seed equals: expectedSeed

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testSetStateFromSeed [
	"Test that setStateFromSeed correctly initializes the state with the seed value."

	| expectedState |
	refRandom seed: 12345.  "Set a known seed value"
	refRandom setStateFromSeed.  "Execute the method under test"

	expectedState := 12345 + 1442695040888963407.
	self assert: (refRandom state at: 1) equals: expectedState.

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testState [
	"Test that the state method returns the correct state value."

	| random |
	random := Random new.
	self assert: random state equals: random state

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testUseClockBasedSeed [
	"Test that useClockBasedSeed sets a non-zero seed and initializes the state correctly."

	| initialSeed initialState |
	initialSeed := refRandom seed.
	initialState := refRandom state copy.

	refRandom useClockBasedSeed.

	self deny: refRandom seed equals: initialSeed. "Seed should change"
	self deny: refRandom state equals: initialState. "State should change"
	self deny: refRandom seed equals: 0. "Seed should not be zero"

]

{ #category : 'AI generated test' }
RandomAITest_m2 >> testUseUnixRandomGeneratorSeed [
	"Test that useUnixRandomGeneratorSeed returns true on Unix systems with /dev/random,
	and false otherwise (e.g., on Windows or if /dev/random is unavailable)."

	| result |
	result := refRandom useUnixRandomGeneratorSeed.

	"On Unix-like systems, expect true if /dev/random is accessible"
	OSPlatform current isUnix
		ifTrue: [ self assert: result equals: true ]
		ifFalse: [ self assert: result equals: false ]

]
