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
	| testAction |
	testAction := [ 42 ].
	
	"Test initial value is nil"
	self assert: refMicroUMLSDMessages clickAction isNil.
	
	"Test setter and getter"
	refMicroUMLSDMessages clickAction: testAction.
	self assert: refMicroUMLSDMessages clickAction equals: testAction.
	self assert: (refMicroUMLSDMessages clickAction value) equals: 42
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testClickActionArg [
	| action |
	action := [ 42 ].
	"Assert that the click action is initially nil"
	self assert: (refMicroUMLSDMessages clickAction isNil).
	"Set the click action using the setter"
	refMicroUMLSDMessages clickAction: action.
	"Verify that the click action was set correctly"
	self assert: (refMicroUMLSDMessages clickAction == action)
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDescription [
	"Test that the description getter returns the expected value after being set via the setter."

	| testDescription |

	"Verify that description is nil by default on a new instance"
	self assert: (refMicroUMLSDMessages description isNil).

	"Set description using the setter"
	testDescription := 'Request Data'.
	refMicroUMLSDMessages description: testDescription.

	"Verify that the getter returns the value that was set"
	self assert: refMicroUMLSDMessages description equals: testDescription.
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDescriptionArg [
	| testDescription |
	testDescription := 'test message'.
	"Assert that the description is initially nil"
	self assert: (refMicroUMLSDMessages description isNil).
	"Set the description using the setter"
	refMicroUMLSDMessages description: testDescription.
	"Assert that the description was set correctly"
	self assert: (refMicroUMLSDMessages description = testDescription)
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDraw [
	"Test the draw method for different message types.
	Verifies the returned collection structure, shape types, line properties, 
	control points, and label text/position."
	| actor1 actor2 result line label |

	"Create two actors with known positions"
	actor1 := MicroUMLSDActor new x: 50; name: 'Actor1'.
	actor2 := MicroUMLSDActor new x: 150; name: 'Actor2'.

	"Configure the message for a call type"
	refMicroUMLSDMessages description: 'test message'.
	refMicroUMLSDMessages fromActor: actor1.
	refMicroUMLSDMessages toActor: actor2.
	refMicroUMLSDMessages y: 100.
	refMicroUMLSDMessages messageType: #call.

	"Invoke draw"
	result := refMicroUMLSDMessages draw.

	"Result should be an Array of size 2: one RSPolyline and one RSLabel"
	self assert: (result isKindOf: Array).
	self assert: result size equals: 2.

	line := result first.
	label := result second.

	"Verify shape types"
	self assert: (line isKindOf: RSPolyline).
	self assert: (label isKindOf: RSLabel).

	"Verify line color is black"
	self assert: line color equals: Color black.

	"Verify line has an arrow marker at the end"
	self assert: line markerEnd isNotNil.

	"Verify call control points: from actor1 x to (actor2 x - 5) at y"
	self assert: line controlPoints first equals: 50 @ 100.
	self assert: line controlPoints second equals: 145 @ 100.

	"Verify label text and position (Smalltalk left-to-right: (50+150)/2 = 100)"
	self assert: label text equals: 'test message'.
	self assert: label position equals: 100 @ 90.

	"--- Test return message type ---"
	refMicroUMLSDMessages messageType: #return.
	result := refMicroUMLSDMessages draw.
	line := result first.

	"Return line should have dashed style"
	self assert: line border dashArray equals: #(5 5).

	"Return control points same offsets as call"
	self assert: line controlPoints first equals: 50 @ 100.
	self assert: line controlPoints second equals: 145 @ 100.

	"--- Test internal message type ---"
	refMicroUMLSDMessages messageType: #internal.
	result := refMicroUMLSDMessages draw.
	line := result first.

	"Internal message should have 4 control points forming a loopback"
	self assert: line controlPoints size equals: 4.
	self assert: line controlPoints first equals: 50 @ 100.
	self assert: line controlPoints second equals: 75 @ 100.
	self assert: line controlPoints third equals: 75 @ 115.
	self assert: line controlPoints fourth equals: 55 @ 115.

	"--- Test with clickAction set ---"
	refMicroUMLSDMessages messageType: #call.
	refMicroUMLSDMessages clickAction: [ 42 ].
	result := refMicroUMLSDMessages draw.
	label := result second.

	"When clickAction is set, label should be red and italic"
	self assert: label color equals: Color red.
	self assert: label isItalic

]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDrawCallArg [
	"Test drawCall: method sets correct control points for line based on actor positions and direction"

	| leftActor rightActor line reversedLine expectedPoints expectedReversed |
	
	"Create actors with specific x positions"
	leftActor := MicroUMLSDActor new
		name: 'Left';
		x: 50;
		yourself.
	rightActor := MicroUMLSDActor new
		name: 'Right';
		x: 150;
		yourself.
	
	"Test left to right (from x < to x, offset = -5)"
	refMicroUMLSDMessages
		fromActor: leftActor;
		toActor: rightActor;
		y: 100.
	line := RSPolyline new.
	refMicroUMLSDMessages drawCall: line.
	expectedPoints := { 50 @ 100 . 145 @ 100 }.
	self assert: (line controlPoints = expectedPoints).
	
	"Test right to left (from x > to x, offset = 5)"
	refMicroUMLSDMessages
		fromActor: rightActor;
		toActor: leftActor.
	reversedLine := RSPolyline new.
	refMicroUMLSDMessages drawCall: reversedLine.
	expectedReversed := { 150 @ 100 . 55 @ 100 }.
	self assert: (reversedLine controlPoints = expectedReversed)
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDrawInternalArg [
	| fromActor line expectedControlPoints |
	"Create a fromActor positioned at x: 100"
	fromActor := MicroUMLSDActor new x: 100; yourself.
	
	"Set up the message instance variables required for drawInternal:"
	refMicroUMLSDMessages fromActor: fromActor.
	refMicroUMLSDMessages y: 50.
	
	"Create the polyline on which to draw the internal message"
	line := RSPolyline new.
	
	"Expected control points for the loopback shape:
	x@ y -> (x+25)@y -> (x+25)@(y+15) -> (x+5)@(y+15)
	which is 100@50 -> 125@50 -> 125@65 -> 105@65"
	expectedControlPoints := {
		100 @ 50.
		125 @ 50.
		125 @ 65.
		105 @ 65
	}.
	
	"Invoke the method under test"
	refMicroUMLSDMessages drawInternal: line.
	
	"Verify the control points were set correctly"
	self assert: (line controlPoints = expectedControlPoints)
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDrawLabelArgAtArg [
	| singleResult multiResult testPoint |
	testPoint := 100 @ 100.
	
	"Test single line label creation and positioning"
	singleResult := refMicroUMLSDMessages drawLabel: 'Hello' at: testPoint.
	self assert: singleResult size equals: 1.
	self assert: (singleResult first isKindOf: RSLabel).
	self assert: singleResult first text equals: 'Hello'.
	self assert: singleResult first position equals: testPoint.
	
	"Test multiline label creation, texts and vertical positioning"
	multiResult := refMicroUMLSDMessages 
		drawLabel: ('First', String cr, 'Second') at: testPoint.
	self assert: multiResult size equals: 2.
	self assert: (multiResult first isKindOf: RSLabel).
	self assert: multiResult first text equals: 'First'.
	self assert: multiResult first position equals: testPoint.
	self assert: (multiResult second isKindOf: RSLabel).
	self assert: multiResult second text equals: 'Second'.
	self assert: multiResult second position 
		equals: testPoint x @ (testPoint y + 18)
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testDrawReturnArg [
	"Test drawReturn: for both cases: fromActor to the right and to the left of toActor"
	| line fromActor toActor |

	"Create two actors and a polyline to draw on"
	fromActor := MicroUMLSDActor new name: 'From'; x: 200.
	toActor := MicroUMLSDActor new name: 'To'; x: 100.
	line := RSPolyline new.

	"Set up the message object with fromActor to the right of toActor (offset = 5)"
	refMicroUMLSDMessages instVarNamed: #fromActor put: fromActor.
	refMicroUMLSDMessages instVarNamed: #toActor put: toActor.
	refMicroUMLSDMessages instVarNamed: #y put: 50.

	"Invoke drawReturn: and verify control points and dash array"
	refMicroUMLSDMessages drawReturn: line.
	self assert: (line controlPoints) equals: { 200@50. 105@50 }.
	self assert: (line border dashArray) equals: #(5 5).

	"Now test the case where fromActor is to the left of toActor (offset = -5)"
	fromActor x: 50.
	toActor x: 200.
	line := RSPolyline new.

	"Invoke drawReturn: again and verify the adjusted control points"
	refMicroUMLSDMessages drawReturn: line.
	self assert: (line controlPoints) equals: { 50@50. 195@50 }.
	self assert: (line border dashArray) equals: #(5 5)

]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testFromActor [
	| actor |
	"Create a sample actor instance"
	actor := MicroUMLSDActor new.
	
	"Set the fromActor using the provided setter method"
	refMicroUMLSDMessages fromActor: actor.
	
	"Verify that the getter returns the exact same actor instance"
	self assert: (refMicroUMLSDMessages fromActor == actor)
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testFromActorArg [
	"Test that fromActor: correctly sets the fromActor instance variable"
	| actor |
	actor := Object new.
	refMicroUMLSDMessages fromActor: actor.
	self assert: refMicroUMLSDMessages fromActor equals: actor
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testLastMethodArg [
	"Test that lastMethod: correctly sets the lastMethod instance variable"
	| testValue |
	"Verify that lastMethod is initially nil"
	self assert: (refMicroUMLSDMessages instVarNamed: #lastMethod) equals: nil.
	"Set lastMethod using the setter"
	testValue := 'aTestMethodValue'.
	refMicroUMLSDMessages lastMethod: testValue.
	"Verify it was correctly stored"
	self assert: (refMicroUMLSDMessages instVarNamed: #lastMethod) equals: testValue

]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testMessageType [
	"Test the messageType accessor methods."

	| testType |
	testType := #call.
	self assert: (refMicroUMLSDMessages messageType isNil) description: 'A new MicroUMLSDMessages should have nil messageType'.
	refMicroUMLSDMessages messageType: testType.
	self assert: (refMicroUMLSDMessages messageType = testType) description: 'messageType should return the value previously set'.
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testMessageTypeArg [
	"Test that messageType: correctly sets the messageType slot"

	| testValue |
	testValue := #call.

	self assert: (refMicroUMLSDMessages instVarNamed: #messageType) isNil
		description: 'messageType slot should be nil initially after setUp'.

	refMicroUMLSDMessages messageType: testValue.

	self assert: ((refMicroUMLSDMessages instVarNamed: #messageType) = testValue)
		description: 'messageType: should correctly set the messageType slot'.
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testPrintOnArg [
	"Test that printOn: produces the expected string format for the message"

	| fromActor toActor stream expected |

	"Create sender and receiver actors"
	fromActor := MicroUMLSDActor new.
	fromActor name: 'Sender'.
	toActor := MicroUMLSDActor new.
	toActor name: 'Receiver'.

	"Set the necessary instance variables on the reference message"
	refMicroUMLSDMessages
		instVarNamed: #fromActor put: fromActor;
		instVarNamed: #toActor put: toActor;
		instVarNamed: #description put: 'test message';
		instVarNamed: #messageType put: #call.

	"Act: print the message on a stream"
	stream := WriteStream on: String new.
	refMicroUMLSDMessages printOn: stream.

	"Assert the output matches the expected format"
	expected := '[ Sender -> Receiver test message (call) ]'.
	self assert: stream contents equals: expected
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testToActor [
	"Test the toActor method of MicroUMLSDMessages"
	| testActor |
	"Verify that toActor is nil by default on a new instance"
	self assert: (refMicroUMLSDMessages toActor isNil).
	"Create an actor and assign it via toActor:"
	testActor := MicroUMLSDActor new.
	testActor name: 'TestActor'.
	refMicroUMLSDMessages toActor: testActor.
	"Verify that toActor returns the same actor object that was set"
	self assert: (refMicroUMLSDMessages toActor == testActor).
	"Verify the returned actor is a MicroUMLSDActor"
	self assert: (refMicroUMLSDMessages toActor isKindOf: MicroUMLSDActor).

]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testToActorArg [
	"Test that #toActor: correctly sets the toActor instance variable"

	| testActor |
	testActor := Object new.
	refMicroUMLSDMessages toActor: testActor.
	self assert: refMicroUMLSDMessages toActor equals: testActor
]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testY [
	"Test that the y method returns the y-coordinate of the message"

	"A new instance should have y as nil by default"
	self assert: (refMicroUMLSDMessages y) equals: nil.

	"Set y using the setter and verify the getter returns the correct value"
	refMicroUMLSDMessages y: 42.
	self assert: (refMicroUMLSDMessages y) equals: 42.

	"Set y to a different value and verify it updates correctly"
	refMicroUMLSDMessages y: 100.
	self assert: (refMicroUMLSDMessages y) equals: 100

]

{ #category : 'AI generated test' }
MicroUMLSDMessagesAITest >> testYArg [
	"Test that y: correctly sets the y-coordinate of the message"

	| testValue |
	testValue := 100.
	refMicroUMLSDMessages y: testValue.
	self assert: ((refMicroUMLSDMessages y) = testValue)
]
