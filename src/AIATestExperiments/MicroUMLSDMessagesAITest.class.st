Class {
	#name : 'MicroUMLSDMessagesAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDMessages'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicroUMLSDMessagesAITest >> setUp [
	super setUp.
	refMicroUMLSDMessages := MicroUMLSDMessages new.
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testClickAction [
	"Test that clickAction returns the value stored in the clickAction instance variable"
	
	| testAction |
	
	"Test with a string value"
	testAction := 'testClickAction'.
	refMicroUMLSDMessages instVarNamed: #clickAction put: testAction.
	self assert: (refMicroUMLSDMessages clickAction = testAction).
	
	"Test with nil value"
	refMicroUMLSDMessages instVarNamed: #clickAction put: nil.
	self assert: (refMicroUMLSDMessages clickAction isNil).
	
	"Test with a block value"
	testAction := [ :x | x + 1 ].
	refMicroUMLSDMessages instVarNamed: #clickAction put: testAction.
	self assert: (refMicroUMLSDMessages clickAction = testAction)
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDescription [
	"Test that description returns the description instance variable"
	| testDescription |
	
	"Set up test data"
	testDescription := 'Test message description'.
	refMicroUMLSDMessages instVarNamed: #description put: testDescription.
	
	"Test that description method returns the correct value"
	self assert: (refMicroUMLSDMessages description = testDescription).
	
	"Test with nil description"
	refMicroUMLSDMessages instVarNamed: #description put: nil.
	self assert: (refMicroUMLSDMessages description isNil).
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDraw [
	"Test the draw method that creates message lines and labels based on message type"

	| result line label mockFromActor mockToActor |
	
	"Create mock actors with positions"
	mockFromActor := MicroUMLSDActor new.
	mockFromActor instVarNamed: #x put: 100.
	mockFromActor instVarNamed: #name put: 'Actor1'.
	
	mockToActor := MicroUMLSDActor new.
	mockToActor instVarNamed: #x put: 200.
	mockToActor instVarNamed: #name put: 'Actor2'.
	
	"Configure the message instance for a call message"
	refMicroUMLSDMessages
		instVarNamed: #description put: 'test message';
		instVarNamed: #fromActor put: mockFromActor;
		instVarNamed: #toActor put: mockToActor;
		instVarNamed: #y put: 100;
		instVarNamed: #messageType put: #call;
		instVarNamed: #clickAction put: nil.
	
	"Execute the draw method"
	result := refMicroUMLSDMessages draw.
	
	"Verify the result structure"
	self assert: result size equals: 2.
	
	"Verify the line properties"
	line := result first.
	self assert: (line isKindOf: RSPolyline).
	self assert: line color equals: Color black.
	self assert: line markerEnd notNil.
	self assert: line controlPoints size equals: 2.
	self assert: line controlPoints first equals: (100 @ 100).
	self assert: line controlPoints second equals: (195 @ 100).
	
	"Verify the label properties"
	label := result second.
	self assert: (label isKindOf: RSLabel).
	self assert: label text equals: 'test message'.
	self assert: label position equals: (150 @ 90)
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDrawCall [
	"Test the drawCall: method to ensure it correctly sets control points based on actor positions"
	| line fromActor toActor |
	
	"Create test actors with specific x positions"
	fromActor := MicroUMLSDActor new x: 100.
	toActor := MicroUMLSDActor new x: 200.
	
	"Set up the message with actors and y position"
	refMicroUMLSDMessages instVarNamed: #fromActor put: fromActor.
	refMicroUMLSDMessages instVarNamed: #toActor put: toActor.
	refMicroUMLSDMessages instVarNamed: #y put: 100.
	
	"Create a polyline as used in the draw method"
	line := RSPolyline new.
	
	"Call the method under test - fromActor x < toActor x case (offset -5)"
	refMicroUMLSDMessages drawCall: line.
	
	"Verify control points are set correctly"
	self assert: (line controlPoints size = 2).
	self assert: (line controlPoints first = (100 @ 100)).
	self assert: (line controlPoints second = (195 @ 100)).
	
	"Test the opposite case - fromActor x > toActor x (offset +5)"
	fromActor x: 300.
	toActor x: 150.
	
	"Call the method again"
	refMicroUMLSDMessages drawCall: line.
	
	"Verify control points are set correctly"
	self assert: (line controlPoints size = 2).
	self assert: (line controlPoints first = (300 @ 100)).
	self assert: (line controlPoints second = (155 @ 100))
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDrawInternal [
	"Test the drawInternal: method which draws an internal message line with a loopback shape"
	| line actor expectedControlPoints |
	
	"Create a MicroUMLSDActor with a known x position"
	actor := MicroUMLSDActor new.
	actor x: 100.
	
	"Set up the message instance variables using instVarNamed:"
	refMicroUMLSDMessages instVarNamed: #fromActor put: actor.
	refMicroUMLSDMessages instVarNamed: #y put: 200.
	
	"Create the polyline as used in the draw method"
	line := RSPolyline new.
	
	"Execute the method under test"
	refMicroUMLSDMessages drawInternal: line.
	
	"Expected control points from the method logic: x@ y, (x+25)@y, (x+25)@(y+15), (x+5)@(y+15)"
	expectedControlPoints := {
		100 @ 200.
		125 @ 200.
		125 @ 215.
		105 @ 215
	}.
	
	"Assert the control points are correctly set"
	self assert: (line controlPoints = expectedControlPoints)
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDrawLabelAt [
	"Test the drawLabel:at: method with single line and multiline text"
	| singleLineResult multiLineResult testPoint singleLineText multiLineText |
	
	testPoint := 100@200.
	singleLineText := 'Single line'.
	multiLineText := 'First line
Second line
Third line'.
	
	"Test single line text"
	singleLineResult := refMicroUMLSDMessages drawLabel: singleLineText at: testPoint.
	self assert: (singleLineResult isKindOf: Array).
	self assert: (singleLineResult size = 1).
	self assert: (singleLineResult first isKindOf: RSLabel).
	self assert: (singleLineResult first text = singleLineText).
	
	"Test multiline text"
	multiLineResult := refMicroUMLSDMessages drawLabel: multiLineText at: testPoint.
	self assert: (multiLineResult isKindOf: Array).
	self assert: (multiLineResult size = 3).
	
	"Check each line is positioned correctly with 18 pixel spacing"
	multiLineResult withIndexDo: [:label :index |
		self assert: (label isKindOf: RSLabel).
		self assert: (label position x = testPoint x).
		self assert: (label position y = (testPoint y + ((index - 1) * 18)))
	]
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDrawReturn [
	"Test the drawReturn: method to ensure it correctly sets control points for return messages"
	| line fromActor toActor testY |
	
	"Create test actors with positions"
	fromActor := MicroUMLSDActor new x: 100.
	toActor := MicroUMLSDActor new x: 200.
	testY := 100.
	
	"Set up the message instance"
	refMicroUMLSDMessages instVarNamed: #fromActor put: fromActor.
	refMicroUMLSDMessages instVarNamed: #toActor put: toActor.
	refMicroUMLSDMessages instVarNamed: #y put: testY.
	
	"Create a line to test with"
	line := RSLine new.
	
	"Call the method under test"
	refMicroUMLSDMessages drawReturn: line.
	
	"Verify the control points are set correctly (fromActor x < toActor x, so offset should be -5)"
	self assert: (line controlPoints size = 2).
	self assert: (line controlPoints first = (100 @ 100)).
	self assert: (line controlPoints second = (195 @ 100)).
	
	"Test the opposite case where fromActor x > toActor x"
	fromActor x: 300.
	toActor x: 150.
	line := RSLine new.
	
	"Call the method again"
	refMicroUMLSDMessages drawReturn: line.
	
	"Verify the control points with positive offset"
	self assert: (line controlPoints size = 2).
	self assert: (line controlPoints first = (300 @ 100)).
	self assert: (line controlPoints second = (155 @ 100))
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testLastMethod [
	"Test that lastMethod: correctly sets the lastMethod instance variable"
	| testMethod |
	
	"Create a test method symbol to use"
	testMethod := #exampleMethod.
	
	"Set the last method using the setter"
	refMicroUMLSDMessages lastMethod: testMethod.
	
	"Verify that the instance variable was set correctly"
	self assert: ((refMicroUMLSDMessages instVarNamed: #lastMethod) = testMethod).
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testMessageType [
	"Test the messageType: setter method"
	| testSymbol testString testNumber |
	
	testSymbol := #call.
	testString := 'return'.
	testNumber := 42.
	
	"Test setting messageType with a symbol"
	refMicroUMLSDMessages messageType: testSymbol.
	self assert: (refMicroUMLSDMessages messageType = testSymbol).
	
	"Test setting messageType with a string"
	refMicroUMLSDMessages messageType: testString.
	self assert: (refMicroUMLSDMessages messageType = testString).
	
	"Test setting messageType with a number"
	refMicroUMLSDMessages messageType: testNumber.
	self assert: (refMicroUMLSDMessages messageType = testNumber).
	
	"Test that the instance variable is properly set"
	refMicroUMLSDMessages messageType: #internal.
	self assert: ((refMicroUMLSDMessages instVarNamed: #messageType) = #internal)
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testToActor [
	"Test that toActor: correctly sets the toActor instance variable"
	| testActor |
	
	"Create a test actor object"
	testActor := 'TestActor'.
	
	"Set the toActor using the method under test"
	refMicroUMLSDMessages toActor: testActor.
	
	"Verify that the toActor instance variable was set correctly"
	self assert: (refMicroUMLSDMessages instVarNamed: #toActor) equals: testActor.
	
	"Test with a different actor to ensure the method works with different values"
	testActor := 'AnotherActor'.
	refMicroUMLSDMessages toActor: testActor.
	self assert: (refMicroUMLSDMessages instVarNamed: #toActor) equals: testActor
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testY [
	"Test the y: setter method to ensure it correctly sets the y-coordinate of the message"
	| testValue |
	
	"Test setting y with a numeric value"
	testValue := 150.
	refMicroUMLSDMessages y: testValue.
	self assert: (refMicroUMLSDMessages instVarNamed: #y) equals: testValue.
	
	"Test setting y with another numeric value"
	testValue := 250.
	refMicroUMLSDMessages y: testValue.
	self assert: (refMicroUMLSDMessages instVarNamed: #y) equals: testValue.
	
	"Test setting y with zero"
	testValue := 0.
	refMicroUMLSDMessages y: testValue.
	self assert: (refMicroUMLSDMessages instVarNamed: #y) equals: testValue.
	
	"Test setting y with negative value"
	testValue := -50.
	refMicroUMLSDMessages y: testValue.
	self assert: (refMicroUMLSDMessages instVarNamed: #y) equals: testValue.
]
