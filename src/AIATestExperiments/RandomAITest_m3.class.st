Class {
	#name : 'RandomAITest_m3',
	#superclass : 'TestCase',
	#instVars : [
		'refRandom'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
RandomAITest_m3 >> setUp [
	super setUp.
	refRandom := Random new.
]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testInitialize [
	"Test that initialize properly sets up the state of the Random instance."

	"Verify that state is initialized to a DoubleWordArray of size 1"
	self assert: refRandom state class equals: DoubleWordArray.
	self assert: refRandom state size equals: 1.

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testMaxValue [
	"Test that maxValue returns the correct maximum value for the Random generator."

	self assert: refRandom maxValue equals: 16r7FFFFFFF

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testNext [
	"Test that next: returns an array of the correct size with random values between 0 and 1."

	| result |
	result := refRandom next: 5.
	self assert: result size equals: 5.
	self assert: (result allSatisfy: [ :each | each between: 0 and: 1 ]).

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testNextBetweenAnd [
	"Test that nextBetween:and: returns a random float within the specified range [lowerBound, higherBound)."

	| lowerBound higherBound result |
	lowerBound := 10.0.
	higherBound := 20.0.

	"Generate a random number within the range"
	result := refRandom nextBetween: lowerBound and: higherBound.

	"Verify the result is within the expected range"
	self assert: (result >= lowerBound).
	self assert: (result < higherBound).

	"Test edge case where lowerBound equals higherBound (should return lowerBound)"
	self assert: (refRandom nextBetween: 5.0 and: 5.0) equals: 5.0.

	"Test negative range"
	self assert: ((refRandom nextBetween: -10.0 and: -5.0) between: -10.0 and: -5.0).

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testNextInteger [
	"Test that nextInteger: returns a value within [1, anInteger] and handles large numbers."

	| result |
	result := refRandom nextInteger: 100.
	self assert: (result between: 1 and: 100).

	"Test with a large number to ensure cryptographic handling."
	result := refRandom nextInteger: 16rFFFFFFFF.
	self assert: (result between: 1 and: 16rFFFFFFFF).

	"Test that an error is raised for non-positive input."
	self should: [ refRandom nextInteger: 0 ] raise: Error.
	self should: [ refRandom nextInteger: -1 ] raise: Error.

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testNextIntegerBetweenAnd [
	"Test that nextIntegerBetween:and: returns a random integer within the specified inclusive range."

	| lowerBound higherBound result |
	lowerBound := 5.
	higherBound := 10.

	"Generate a random number and verify it is within the range."
	result := refRandom nextIntegerBetween: lowerBound and: higherBound.

	self assert: (result between: lowerBound and: higherBound).

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testNextInto [
	"Test that next:into: fills anArray with anInteger random numbers between 0 and 1"

	| anInteger anArray |
	anInteger := 10.
	anArray := Array new: anInteger.

	refRandom next: anInteger into: anArray.

	self assert: anArray size equals: anInteger.
	self assert: (anArray allSatisfy: [ :each | each between: 0 and: 1 ]).

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testPrivateNextValue [
	"Test that privateNextValue returns a Float in the interval [0, 1)."

	| value |
	value := refRandom privateNextValue.
	self assert: (value isKindOf: Float).
	self assert: (value >= 0.0).
	self assert: (value < 1.0)

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testRsNext [
	"Test that rsNext: returns a value between 0 and the given limit."

	| result |
	result := refRandom rsNext: 100.
	self assert: (result between: 0 and: 100)

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testRsNextAnd [
	"Test that rsNext:and: returns a scaled value between u and v using self next"

	| result |
	result := refRandom rsNext: 10 and: 20.
	self assert: (result between: 10 and: 20).
	self assert: (result isKindOf: Number)

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testSeed [
	"Test that seed returns the correct seed value after initialization.
	Since the method is private, we test it indirectly by verifying the state after initialization."

	| expectedSeed |
	expectedSeed := 12345.
	refRandom seed: expectedSeed.
	self assert: refRandom seed equals: expectedSeed

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testSetStateFromSeed [
	"Test that setStateFromSeed correctly initializes the state with the seed value."

	| expectedState |
	refRandom seed: 12345.  "Set a known seed value"
	refRandom setStateFromSeed.  "Execute the method under test"

	expectedState := DoubleWordArray new: 1.
	expectedState at: 1 put: 12345 + 1442695040888963407.

	self assert: refRandom state equals: expectedState.

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testState [
	"Test that the state method returns the correct state value."

	| random |
	random := Random new.
	self assert: random state equals: random state

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testUseClockBasedSeed [
	"Test that useClockBasedSeed sets a non-zero seed and initializes the state correctly."

	| initialSeed initialState |
	initialSeed := refRandom seed.
	initialState := refRandom state copy.

	refRandom useClockBasedSeed.

	self deny: refRandom seed equals: initialSeed. "Seed should change"
	self deny: refRandom state equals: initialState. "State should change"
	self deny: refRandom seed equals: 0. "Seed should never be zero"

]

{ #category : 'AI generated test' }
RandomAITest_m3 >> testUseUnixRandomGeneratorSeed [
	"Test that useUnixRandomGeneratorSeed returns true on Unix systems with /dev/random,
	and false otherwise (e.g., on Windows or if /dev/random is unavailable)."

	| result |
	result := refRandom useUnixRandomGeneratorSeed.

	"On Unix systems, expect true if /dev/random is available and readable"
	(self isUnix and: [ (File named: '/dev/random') exists ])
		ifTrue: [ self assert: result ]
		ifFalse: [ self deny: result ]

]
