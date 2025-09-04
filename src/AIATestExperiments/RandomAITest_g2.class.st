Class {
	#name : 'RandomAITest_g2',
	#superclass : 'TestCase',
	#instVars : [
		'refRandom'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
RandomAITest_g2 >> setUp [
	super setUp.
	refRandom := Random new.
]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testInitialize [
	"Test that initialize sets up the state correctly."

	| random |
	random := Random new.
	self assert: random state isNotNil.
	self assert: (random state isKindOf: DoubleWordArray).
	self assert: random state size equals: 1.

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testMaxValue [
	"Test that maxValue returns the correct maximum value for Random numbers."

	| result |
	result := refRandom maxValue.
	self assert: result equals: 16r7FFFFFFF

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testNext [
	"Test that next: returns an array of random numbers with the correct size."

	| result |
	result := refRandom next: 5.
	self assert: result size equals: 5.
	self assert: (result allSatisfy: [ :each | each between: 0 and: 1 ])

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testNextBetweenAnd [
	"Test that nextBetween:and: returns a random float within the specified range [lowerBound, higherBound)."

	| lowerBound higherBound result |
	lowerBound := 10.
	higherBound := 20.
	result := refRandom nextBetween: lowerBound and: higherBound.

	self assert: (result >= lowerBound).
	self assert: (result < higherBound).

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testNextInteger [
	"Test that nextInteger: returns a random integer in [1, anInteger] and handles large numbers."

	| result |
	result := refRandom nextInteger: 100.
	self assert: (result between: 1 and: 100).

	"Test error for non-positive input"
	self should: [ refRandom nextInteger: 0 ] raise: Error.
	self should: [ refRandom nextInteger: -5 ] raise: Error.

	"Test large number handling"
	result := refRandom nextInteger: 16rFFFFFFFF.
	self assert: (result between: 1 and: 16rFFFFFFFF).

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testNextIntegerBetweenAnd [
	"Test that nextIntegerBetween:and: returns a random integer within the specified inclusive range."

	| lowerBound higherBound result |
	lowerBound := 5.
	higherBound := 10.
	result := refRandom nextIntegerBetween: lowerBound and: higherBound.

	self assert: (result between: lowerBound and: higherBound).
	self assert: result isInteger.

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testNextInto [
	"Test that next:into: fills anArray with anInteger random numbers between 0 and 1."

	| anInteger anArray result |
	anInteger := 5.
	anArray := Array new: anInteger.
	result := refRandom next: anInteger into: anArray.

	self assert: result size equals: anInteger.
	self assert: (result allSatisfy: [ :each | each between: 0 and: 1 ]).
	self assert: result identicalTo: anArray.

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testPrivateNextValue [
	"Test that privateNextValue returns a Float in the interval [0, 1)."

	| result |
	result := refRandom privateNextValue.
	self assert: (result isKindOf: Float).
	self assert: (result >= 0).
	self assert: (result < 1)

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testRsNext [
	"Test that rsNext: returns a value between 0 and the given limit."

	| result |
	result := refRandom rsNext: 100.
	self assert: (result between: 0 and: 100)

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testRsNextAnd [
	"Test that rsNext:and: returns a scaled value between u and v using self next"

	| result u v |
	u := 10.
	v := 20.
	result := refRandom rsNext: u and: v.

	self assert: (result between: u and: v).
	self assert: (result isKindOf: Number).

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testSeed [
	"Test that seed returns the correct value after initialization.
	Since the method is private, we test it indirectly through public methods."

	| initialSeed |
	initialSeed := 12345.
	refRandom seed: initialSeed.
	self assert: refRandom seed equals: initialSeed

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testSetStateFromSeed [
	"Test that setStateFromSeed correctly initializes the state with the seed value."

	| expectedState |
	refRandom seed: 42.
	refRandom setStateFromSeed.
	expectedState := DoubleWordArray new: 1.
	expectedState at: 1 put: 42 + 1442695040888963407.
	self assert: refRandom state equals: expectedState

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testState [
	"Test that state returns the correct value."

	| result |
	result := refRandom state.
	self assert: result equals: refRandom state

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testUseClockBasedSeed [
	"Test that useClockBasedSeed sets a non-zero seed and initializes state correctly."

	| oldSeed newSeed |
	oldSeed := refRandom seed.
	refRandom useClockBasedSeed.
	newSeed := refRandom seed.

	self deny: newSeed = 0.
	self deny: newSeed = oldSeed.
	self assert: (refRandom state at: 1) isInteger.

]

{ #category : 'AI generated test' }
RandomAITest_g2 >> testUseUnixRandomGeneratorSeed [
	"Test that useUnixRandomGeneratorSeed returns true on Unix systems with /dev/random"
	| result |
	result := refRandom useUnixRandomGeneratorSeed.
	self assert: result equals: true.

]
