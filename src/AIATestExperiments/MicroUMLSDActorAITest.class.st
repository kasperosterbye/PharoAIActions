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
	"Test that clickAction returns the value of the clickAction instance variable"
	| testAction |
	
	"Test with nil clickAction (default)"
	self assert: (refMicroUMLSDActor clickAction isNil).
	
	"Test with a specific clickAction value"
	testAction := 'testClickAction'.
	refMicroUMLSDActor instVarNamed: #clickAction put: testAction.
	self assert: (refMicroUMLSDActor clickAction = testAction).
	
	"Test with a block as clickAction"
	testAction := [ :actor | actor name ].
	refMicroUMLSDActor instVarNamed: #clickAction put: testAction.
	self assert: (refMicroUMLSDActor clickAction = testAction).
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testClickActionArg [
	"Test that clickAction: properly sets the click action instance variable"
	| testAction |
	
	"Create a test action block"
	testAction := [:actor | actor name].
	
	"Set the click action using the method under test"
	refMicroUMLSDActor clickAction: testAction.
	
	"Verify that the click action was properly stored"
	self assert: ((refMicroUMLSDActor instVarNamed: #clickAction) == testAction).
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testDraw [
	"Test that draw creates a proper RSComposite with box and label positioned correctly"
	| result box label |
	
	"Set up the actor with name and position"
	refMicroUMLSDActor name: 'TestActor'.
	refMicroUMLSDActor x: 100.
	
	"Execute the draw method"
	result := refMicroUMLSDActor draw.
	
	"Verify the result is an RSComposite"
	self assert: (result isKindOf: RSComposite).
	
	"Verify it contains exactly 2 shapes (box and label)"
	self assert: (result shapes size = 2).
	
	"Extract the box and label"
	box := result shapes first.
	label := result shapes second.
	
	"Verify the box is an RSBox with correct properties"
	self assert: (box isKindOf: RSBox).
	self assert: (box color = Color veryLightGray).
	self assert: (box borderColor = Color veryDarkGray).
	
	"Verify the label is an RSLabel with correct text and default style"
	self assert: (label isKindOf: RSLabel).
	self assert: (label text = 'TestActor').
	
	"Verify the composite is positioned correctly"
	self assert: (result position = (100 @ 0)).
	
	"Test with click action - label should be red and italic"
	refMicroUMLSDActor clickAction: [].
	result := refMicroUMLSDActor draw.
	label := result shapes second.
	self assert: (label color = Color red).
	self assert: (label isItalic).
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
	
	"Test that index can be set to different values"
	refMicroUMLSDActor index: 1.
	self assert: (refMicroUMLSDActor index = 1).
	
	refMicroUMLSDActor index: 0.
	self assert: (refMicroUMLSDActor index = 0).
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testIndexArg [
	"Test that index: method correctly sets the index instance variable"
	| testValue |
	
	testValue := 123.
	
	"Set the index using the index: method"
	refMicroUMLSDActor index: testValue.
	
	"Verify that the index instance variable was set correctly"
	self assert: (refMicroUMLSDActor instVarNamed: #index) equals: testValue.
	
	"Test with a different value to ensure it can be changed"
	testValue := 456.
	refMicroUMLSDActor index: testValue.
	self assert: (refMicroUMLSDActor instVarNamed: #index) equals: testValue
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testName [
	"Test that the name method returns the correct name value"
	| testName |
	
	"Test with nil name (default state)"
	self assert: (refMicroUMLSDActor name isNil).
	
	"Test setting and getting a string name"
	testName := 'TestActor'.
	refMicroUMLSDActor name: testName.
	self assert: (refMicroUMLSDActor name = testName).
	
	"Test setting and getting another name"
	testName := 'AnotherActor'.
	refMicroUMLSDActor name: testName.
	self assert: (refMicroUMLSDActor name = testName).
	
	"Test setting empty string name"
	testName := ''.
	refMicroUMLSDActor name: testName.
	self assert: (refMicroUMLSDActor name = testName).
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testNameArg [
	"Test that name: sets the name instance variable correctly"
	| testName testNumber |
	
	testName := 'TestActor'.
	testNumber := 42.
	
	"Test setting name with a string"
	refMicroUMLSDActor name: testName.
	self assert: (refMicroUMLSDActor instVarNamed: #name) equals: testName.
	
	"Test setting name with a number"
	refMicroUMLSDActor name: testNumber.
	self assert: (refMicroUMLSDActor instVarNamed: #name) equals: testNumber.
	
	"Test setting name with nil"
	refMicroUMLSDActor name: nil.
	self assert: (refMicroUMLSDActor instVarNamed: #name) equals: nil.
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testPrintOnArg [
	"Test that printOn: correctly formats the actor's name"
	| stream result |
	
	"Create a WriteStream to capture the output"
	stream := WriteStream on: String new.
	
	"Set the actor's name for testing"
	refMicroUMLSDActor instVarNamed: #name put: 'TestActor'.
	
	"Call printOn: method"
	refMicroUMLSDActor printOn: stream.
	
	"Get the result from the stream"
	result := stream contents.
	
	"Assert the expected format"
	self assert: (result = 'Actor: TestActor').
	
	"Test with nil name"
	refMicroUMLSDActor instVarNamed: #name put: nil.
	stream := WriteStream on: String new.
	refMicroUMLSDActor printOn: stream.
	result := stream contents.
	
	"Assert nil is converted to string"
	self assert: (result = 'Actor: nil')
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testWidth [
	"Test that width is calculated correctly based on label text and box padding"
	| expectedWidth labelWidth |
	
	"Set up actor with a name"
	refMicroUMLSDActor name: 'TestActor'.
	
	"Initially width should be nil"
	self assert: ((refMicroUMLSDActor instVarNamed: #width) isNil).
	
	"Calculate expected width"
	labelWidth := (RSLabel new text: 'TestActor') textWidth.
	expectedWidth := labelWidth + (MicroUMLSDActor boxPadding * 2).
	
	"Call width method and verify it returns correct value"
	self assert: (refMicroUMLSDActor width = expectedWidth).
	
	"Verify width instance variable is now set"
	self assert: ((refMicroUMLSDActor instVarNamed: #width) = expectedWidth).
	
	"Call width again to test caching - should return same value"
	self assert: (refMicroUMLSDActor width = expectedWidth).
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testX [
	"Test that x method returns the x-coordinate of the actor"
	
	| expectedX |
	
	"Set up test data - assign a specific x coordinate"
	expectedX := 150.
	refMicroUMLSDActor instVarNamed: #x put: expectedX.
	
	"Test that x method returns the correct x-coordinate"
	self assert: (refMicroUMLSDActor x = expectedX).
	
	"Test with a different value to ensure consistency"
	expectedX := 75.
	refMicroUMLSDActor instVarNamed: #x put: expectedX.
	self assert: (refMicroUMLSDActor x = expectedX)
]

{ #category : 'AI generated test' }
MicroUMLSDActorAITest >> testXArg [
	"Test that x: sets the x-coordinate of the actor correctly"
	
	| testValue |
	testValue := 150.
	
	"Set the x-coordinate using x: method"
	refMicroUMLSDActor x: testValue.
	
	"Verify that the x instance variable was set correctly"
	self assert: ((refMicroUMLSDActor instVarNamed: #x) = testValue).
	
	"Test with a different value to ensure it updates"
	testValue := 250.
	refMicroUMLSDActor x: testValue.
	self assert: ((refMicroUMLSDActor instVarNamed: #x) = testValue).
	
	"Test with a string value to verify it accepts any object"
	testValue := 'coordinate'.
	refMicroUMLSDActor x: testValue.
	self assert: ((refMicroUMLSDActor instVarNamed: #x) = testValue)
]
