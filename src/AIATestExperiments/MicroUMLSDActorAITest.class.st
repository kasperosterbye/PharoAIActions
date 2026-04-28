Class {
	#name : 'MicroUMLSDActorAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDActor'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicroUMLSDActorAITest >> setUp [
	super setUp.
	refMicroUMLSDActor := MicroUMLSDActor new.
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testClickAction [
	"Test the clickAction getter and setter methods.
	Verifies that clickAction returns nil initially and the set value afterwards."

	| action |
	action := [ 42 ].
	
	"Assert that a new actor has no clickAction set (nil)"
	self assert: (refMicroUMLSDActor clickAction isNil).
	
	"Set a click action using the setter"
	refMicroUMLSDActor clickAction: action.
	
	"Assert that clickAction returns the exact block that was set (identity)"
	self assert: (refMicroUMLSDActor clickAction == action)
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testClickActionArg [
	"Test that clickAction: sets the clickAction accessor correctly"
	
	| action |
	action := [ :evt | 42 ].
	
	self assert: refMicroUMLSDActor clickAction isNil.
	
	refMicroUMLSDActor clickAction: action.
	
	self assert: (refMicroUMLSDActor clickAction == action)
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testDraw [
	"Test the draw method of MicroUMLSDActor"
	| actorElement box label actorElementWithClick labelWithClick |

	"Configure the actor with a name and position, no click action"
	refMicroUMLSDActor name: 'TestActor'.
	refMicroUMLSDActor x: 100.
	refMicroUMLSDActor clickAction: nil.

	"Execute draw"
	actorElement := refMicroUMLSDActor draw.

	"Verify the returned element is an RSComposite with 2 shapes"
	self assert: (actorElement isKindOf: RSComposite).
	self assert: actorElement shapes size equals: 2.

	"Verify the first shape is an RSBox with correct properties"
	box := actorElement shapes first.
	self assert: (box isKindOf: RSBox).
	self assert: box color equals: Color veryLightGray.
	self assert: box border color equals: Color veryDarkGray.
	self assert: (box height >= MicroUMLSDActor boxHeight).

	"Verify the second shape is an RSLabel with correct text and default color"
	label := actorElement shapes second.
	self assert: (label isKindOf: RSLabel).
	self assert: label text equals: 'TestActor'.
	self assert: label color equals: Color black.
	self deny: label font isItalic.
	self assert: label announcer subscriptions subscriptions size equals: 0.

	"Verify position is set correctly"
	self assert: actorElement position equals: 100 @ 0.

	"Now test draw with a clickAction set"
	refMicroUMLSDActor clickAction: [ ].
	actorElementWithClick := refMicroUMLSDActor draw.

	"Verify label is red, italic, and has a mouse click subscription"
	labelWithClick := actorElementWithClick shapes second.
	self assert: labelWithClick color equals: Color red.
	self assert: labelWithClick font isItalic.
	self assert: labelWithClick announcer subscriptions subscriptions size equals: 1.

]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testIndex [
	"Test that index returns the value stored in the index instance variable."

	"Set the index instance variable directly because this test targets the getter."
	refMicroUMLSDActor instVarNamed: #index put: 7.

	"Verify that the index method returns the stored value."
	self assert: (refMicroUMLSDActor index) equals: 7
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testIndexArg [
	"Test the index: setter by setting a value and verifying it via the index getter"

	| testIndex |
	testIndex := 42.

	self assert: (refMicroUMLSDActor index isNil).
	refMicroUMLSDActor index: testIndex.
	self assert: ((refMicroUMLSDActor index) = testIndex)
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testName [
	"Test the 'name' accessor method of MicroUMLSDActor.
	It should return nil for a new instance and the set value afterwards."
	| expectedName |
	"A freshly created actor should have nil as name"
	self assert: (refMicroUMLSDActor name isNil).
	"Set a name and verify it is returned correctly"
	expectedName := 'TestActor'.
	refMicroUMLSDActor name: expectedName.
	self assert: (refMicroUMLSDActor name = expectedName)
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testNameArg [
	"Test that name: sets the name slot correctly and indirectly verifies width calculation based on name"
	| widthA widthABCDEF |
	
	"Ensure initial state"
	self assert: ((refMicroUMLSDActor instVarNamed: #name) isNil).
	
	"Test setting short name and compute width"
	refMicroUMLSDActor name: 'A'.
	refMicroUMLSDActor instVarNamed: #width put: nil.
	widthA := refMicroUMLSDActor width.
	self assert: ((refMicroUMLSDActor instVarNamed: #name) = 'A').
	self assert: (widthA isNumber).
	self assert: (widthA > 20). "Minimal padding"
	
	"Test setting longer name and compute new wider width"
	refMicroUMLSDActor name: 'ABCDEF'.
	refMicroUMLSDActor instVarNamed: #width put: nil.
	widthABCDEF := refMicroUMLSDActor width.
	self assert: ((refMicroUMLSDActor instVarNamed: #name) = 'ABCDEF').
	self assert: (widthABCDEF > widthA)
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testPrintOnArg [
	"Test the printOn: method of MicroUMLSDActor.
	It appends 'Actor: ' followed by the name asString to the stream.
	Initially name is nil, so prints 'Actor: nil'.
	After setting name, prints 'Actor: TestActor'."

	| stream expected |

	stream := WriteStream on: String new.
	refMicroUMLSDActor printOn: stream.
	expected := 'Actor: nil'.
	self assert: (stream contents = expected).

	refMicroUMLSDActor instVarNamed: #name put: 'TestActor'.

	stream := WriteStream on: String new.
	refMicroUMLSDActor printOn: stream.
	expected := 'Actor: TestActor'.
	self assert: (stream contents = expected)
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testWidth [
	| expected newName |

	"Test initial state: width should be nil before first access"
	self assert: (refMicroUMLSDActor instVarNamed: #width) isNil description: 'Width should be nil before first access'.

	"Set name so width can be computed from label text"
	refMicroUMLSDActor name: 'Actor1'.
	expected := (RSLabel new text: 'Actor1') textWidth + (MicroUMLSDActor boxPadding * 2).

	"First access computes and caches the width"
	self assert: refMicroUMLSDActor width equals: expected.

	"Verify the width is now cached in the instance variable"
	self assert: (refMicroUMLSDActor instVarNamed: #width) equals: expected.

	"Second access returns the same cached value"
	self assert: refMicroUMLSDActor width equals: expected.

	"Changing the name does not update the already cached width"
	newName := 'LongerActorName'.
	refMicroUMLSDActor name: newName.
	self assert: refMicroUMLSDActor width equals: expected.

	"Reset width to nil and verify recomputation with the new name"
	refMicroUMLSDActor instVarNamed: #width put: nil.
	expected := (RSLabel new text: newName) textWidth + (MicroUMLSDActor boxPadding * 2).
	self assert: refMicroUMLSDActor width equals: expected

]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testX [
	"Test the x accessor method of MicroUMLSDActor"

	"Test initial value is nil"
	self assert: (refMicroUMLSDActor x isNil).

	"Test setting and getting the x value"
	refMicroUMLSDActor x: 42.
	self assert: (refMicroUMLSDActor x = 42)
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testXArg [
	"Test that x: correctly sets the x-coordinate using the accessor"

	refMicroUMLSDActor x: 42.
	self assert: (refMicroUMLSDActor x) equals: 42.
	self assert: (refMicroUMLSDActor instVarNamed: #x) equals: 42
]
