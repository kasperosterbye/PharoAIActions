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
	"Test that clickAction returns the click action associated with the actor"
	| expectedAction |
	
	"Test with nil clickAction (default state)"
	self assert: (refMicroUMLSDActor clickAction isNil).
	
	"Test with a specific click action"
	expectedAction := 'testClickAction'.
	refMicroUMLSDActor instVarNamed: #clickAction put: expectedAction.
	self assert: (refMicroUMLSDActor clickAction = expectedAction).
	
	"Test with a different click action"
	expectedAction := [:actor | actor name].
	refMicroUMLSDActor instVarNamed: #clickAction put: expectedAction.
	self assert: (refMicroUMLSDActor clickAction = expectedAction)
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testClickActionArg [
	"Test that clickAction: sets the click action associated with the actor"
	| testAction |
	
	"Initialize test data"
	testAction := 'test click action'.
	
	"Verify initial state - clickAction should be nil"
	self assert: (refMicroUMLSDActor instVarNamed: #clickAction) isNil.
	
	"Execute the method under test"
	refMicroUMLSDActor clickAction: testAction.
	
	"Verify the clickAction was set correctly"
	self assert: (refMicroUMLSDActor instVarNamed: #clickAction) equals: testAction
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testDraw [
	"draw should answer an RSComposite containing a box and a label.
	The composite should contain exactly two shapes."

	| result shapes box label |
	
	"Arrange: set required slots (do not use direct ivar access)"
	refMicroUMLSDActor instVarNamed: #name put: 'TestActor'.
	refMicroUMLSDActor instVarNamed: #x put: 100.
	refMicroUMLSDActor instVarNamed: #width put: 80.

	"Act"
	result := refMicroUMLSDActor draw.

	"Assert: result type"
	self assert: (result isKindOf: RSComposite).

	"Assert: composite shapes"
	shapes := result shapes.
	self assert: (shapes size = 2).

	"Assert: first is a box, second is a label"
	box := shapes first.
	label := shapes second.
	self assert: (box class name = #RSBox).
	self assert: (label isKindOf: RSLabel).

	"Assert: label text is set from actor name"
	self assert: (label text = 'TestActor')
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testIndex [
	"Test that the index method returns the correct index value"
	| expectedIndex |
	
	expectedIndex := 42.
	
	"Test that index returns nil when not set"
	self assert: (refMicroUMLSDActor index isNil).
	
	"Test that index returns the correct value after being set"
	refMicroUMLSDActor index: expectedIndex.
	self assert: (refMicroUMLSDActor index = expectedIndex).
	
	"Test with different index value"
	refMicroUMLSDActor index: 1.
	self assert: (refMicroUMLSDActor index = 1).
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testName [
	"Test that the name method returns the correct name value"
	| expectedName |
	
	"Test with nil name (default state)"
	self assert: (refMicroUMLSDActor name isNil).
	
	"Test setting and getting a name"
	expectedName := 'TestActor'.
	refMicroUMLSDActor name: expectedName.
	self assert: (refMicroUMLSDActor name = expectedName).
	
	"Test with empty string name"
	refMicroUMLSDActor name: ''.
	self assert: (refMicroUMLSDActor name = '').
	
	"Test with another name"
	refMicroUMLSDActor name: 'AnotherActor'.
	self assert: (refMicroUMLSDActor name = 'AnotherActor').
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testPrintOn [
	"Test that printOn: correctly formats the actor's name"
	| stream |
	
	"Create a stream to capture the output"
	stream := WriteStream on: String new.
	
	"Test with nil name (default state)"
	refMicroUMLSDActor printOn: stream.
	self assert: (stream contents = 'Actor: nil').
	
	"Reset stream and test with a specific name"
	stream := WriteStream on: String new.
	refMicroUMLSDActor instVarNamed: #name put: 'TestActor'.
	refMicroUMLSDActor printOn: stream.
	self assert: (stream contents = 'Actor: TestActor').
	
	"Reset stream and test with empty string name"
	stream := WriteStream on: String new.
	refMicroUMLSDActor instVarNamed: #name put: ''.
	refMicroUMLSDActor printOn: stream.
	self assert: (stream contents = 'Actor: ').
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testWidth [
	"Test that width is calculated correctly based on label text and padding when nil, and returns cached value when already set"
	| expectedWidth labelWidth |
	
	"Test width calculation when width is nil"
	refMicroUMLSDActor name: 'TestActor'.
	refMicroUMLSDActor instVarNamed: #width put: nil.
	labelWidth := (RSLabel new text: 'TestActor') textWidth.
	expectedWidth := labelWidth + (MicroUMLSDActor boxPadding * 2).
	
	self assert: (refMicroUMLSDActor width = expectedWidth).
	
	"Test that width is cached - calling width again should return same value"
	self assert: (refMicroUMLSDActor width = expectedWidth).
	
	"Test that width returns cached value when already set"
	refMicroUMLSDActor instVarNamed: #width put: 150.
	self assert: (refMicroUMLSDActor width = 150).
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testX [
	"Test that x: method correctly sets the x-coordinate of the actor"
	
	| testValue |
	testValue := 150.
	
	"Set the x-coordinate using the x: method"
	refMicroUMLSDActor x: testValue.
	
	"Verify that the x instance variable was set correctly"
	self assert: (refMicroUMLSDActor instVarNamed: #x) equals: testValue.
	
	"Test with a different value to ensure it can be changed"
	testValue := 250.
	refMicroUMLSDActor x: testValue.
	self assert: (refMicroUMLSDActor instVarNamed: #x) equals: testValue
]
