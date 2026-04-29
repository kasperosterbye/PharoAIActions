Class {
	#name : 'MicroUMLSequenceDiagramAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSequenceDiagram'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicroUMLSequenceDiagramAITest >> setUp [
	super setUp.
	refMicroUMLSequenceDiagram := MicroUMLSequenceDiagram new.
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testActorsAndMessagesArg [
	"Test that actorsAndMessages: correctly sets the actors slot to the first element
	and the messages slot to the second element of the input array."
	| testActors testMessages aAndM |
	"Prepare test data"
	testActors := OrderedCollection with: 'Client' with: 'Server'.
	testMessages := OrderedCollection with: 'request'.
	aAndM := { testActors. testMessages }.
	"Execute the method under test"
	refMicroUMLSequenceDiagram actorsAndMessages: aAndM.
	"Verify that actors is set to the first element of the input"
	self assert: (refMicroUMLSequenceDiagram instVarNamed: #actors) identicalTo: testActors.
	"Verify that messages is set to the second element of the input"
	self assert: (refMicroUMLSequenceDiagram instVarNamed: #messages) identicalTo: testMessages

]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testComputeActorPositions [
	| actor1 actor2 msg actorGap labelWidth expectedFirstX expectedSecondX |

	"Get the standard gap between actors"
	actorGap := MicroUMLSDActor actorGap.

	"Create two actors with names so their widths can be computed"
	actor1 := MicroUMLSDActor new name: 'Alice'.
	actor1 width.
	actor2 := MicroUMLSDActor new name: 'Bob'.
	actor2 width.

	"--- Test 1: No messages between actors ---"
	"When there are no messages, the distance defaults to actorGap"
	refMicroUMLSequenceDiagram actorsAndMessages: {
		{ actor1. actor2 } asOrderedCollection.
		OrderedCollection new }.
	refMicroUMLSequenceDiagram computeActorPositions.

	"First actor should be placed at actorGap"
	expectedFirstX := actorGap.
	self assert: (actor1 x = expectedFirstX).

	"Second actor position: actorGap + max(actorGap, halfWidths + 2*actorGap)"
	expectedSecondX := actorGap + (actorGap max: (actor1 width / 2) + (actor2 width / 2) + (2 * actorGap)).
	self assert: (actor2 x = expectedSecondX).

	"--- Test 2: With a message between the two actors ---"
	"A message label adds width that may push the second actor further right"
	msg := MicroUMLSDMessages new
		description: 'doSomething';
		fromActor: actor1;
		toActor: actor2;
		yourself.
	refMicroUMLSequenceDiagram actorsAndMessages: {
		{ actor1. actor2 } asOrderedCollection.
		{ msg } asOrderedCollection }.
	refMicroUMLSequenceDiagram computeActorPositions.

	"First actor should still be at actorGap"
	self assert: (actor1 x = actorGap).

	"Second actor considers label width + actorGap + 10 vs half-widths + 2*actorGap"
	labelWidth := (RSLabel new text: msg description) textWidth.
	expectedSecondX := actorGap + ((labelWidth + actorGap + 10) max: (actor1 width / 2) + (actor2 width / 2) + (2 * actorGap)).
	self assert: (actor2 x = expectedSecondX)

]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testComputeMessagePositions [
	"Test that computeMessagePositions assigns correct vertical positions to messages"
	| messages msg1 msg2 expectedY1 expectedY2 |
	"Create two message objects"
	msg1 := MicroUMLSDMessages new.
	msg2 := MicroUMLSDMessages new.
	"Retrieve the messages collection from the diagram and add the messages"
	messages := refMicroUMLSequenceDiagram instVarNamed: #messages.
	messages add: msg1.
	messages add: msg2.
	"Verify y positions are nil before computation"
	self assert: (msg1 y isNil).
	self assert: (msg2 y isNil).
	"Compute the message positions"
	refMicroUMLSequenceDiagram computeMessagePositions.
	"Expected positions: topMargin + (index * messageGap)"
	"For index 1: 15 + (1 * 40) = 55"
	"For index 2: 15 + (2 * 40) = 95"
	expectedY1 := MicroUMLSDMessages topMargin + (1 * MicroUMLSDMessages messageGap).
	expectedY2 := MicroUMLSDMessages topMargin + (2 * MicroUMLSDMessages messageGap).
	"Assert the computed y positions match expected values"
	self assert: (msg1 y) equals: expectedY1.
	self assert: (msg2 y) equals: expectedY2.

]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testDrawActors [
	| actor1 actor2 actors canvas beforeSize |
	
	"Create sample actors"
	actor1 := MicroUMLSDActor new
		name: 'Actor1';
		x: 50;
		yourself.
	actor2 := MicroUMLSDActor new
		name: 'Actor2';
		x: 150;
		yourself.
	actors := OrderedCollection with: actor1 with: actor2.
	
	"Set up canvas and actors on the diagram"
	canvas := RSCanvas new.
	refMicroUMLSequenceDiagram instVarNamed: #actors put: actors.
	refMicroUMLSequenceDiagram instVarNamed: #canvas put: canvas.
	
	"Record size before drawing"
	beforeSize := canvas shapes size.
	
	"Perform the method under test"
	refMicroUMLSequenceDiagram drawActors.
	
	"Verify that the number of shapes increased by the number of actors"
	self assert: ((canvas shapes size) = (beforeSize + actors size)).
	
	"Verify that added shapes are RSComposite instances"
	self assert: (canvas shapes allSatisfy: [ :shape | shape isKindOf: RSComposite ]).
	
	"Verify each composite has at least a box and label"
	self assert: ((canvas shapes allSatisfy: [ :composite | (composite shapes size) >= 2 ]))
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testDrawLifelines [
	"Test that drawLifelines adds dashed vertical RSLine shapes to the canvas for each actor"
	| actor1 actor2 canvas lines line1 line2 expectedStartY expectedEndY |

	"Set up two actors with known x positions"
	actor1 := MicroUMLSDActor new name: 'ActorA'; x: 100.
	actor2 := MicroUMLSDActor new name: 'ActorB'; x: 250.
	refMicroUMLSequenceDiagram instVarNamed: #actors put: (OrderedCollection with: actor1 with: actor2).

	"Set up a fresh canvas on the diagram"
	canvas := RSCanvas new.
	refMicroUMLSequenceDiagram instVarNamed: #canvas put: canvas.

	"Invoke the method under test"
	refMicroUMLSequenceDiagram drawLifelines.

	"Retrieve the shapes added to the canvas"
	lines := canvas shapes.

	"Assert that exactly two lifelines were added (one per actor)"
	self assert: lines size equals: 2.

	"Assert all added shapes are RSLine instances"
	self assert: (lines allSatisfy: [ :each | each isKindOf: RSLine ]).

	"Compute expected Y coordinates: boxHeight/2 for start, boxHeight/2 + lifelineHeight for end"
	expectedStartY := MicroUMLSDActor boxHeight / 2.
	expectedEndY := expectedStartY + MicroUMLSDMessages topMargin + (0 * MicroUMLSDMessages messageGap) + MicroUMLSDMessages bottomMargin.

	"Verify properties of the first lifeline (actor at x=100)"
	line1 := lines first.
	self assert: line1 startPoint equals: 100 @ expectedStartY.
	self assert: line1 endPoint equals: 100 @ expectedEndY.
	self assert: (line1 color) equals: Color black.
	self assert: (line1 border dashArray) equals: #(5 5).

	"Verify properties of the second lifeline (actor at x=250)"
	line2 := lines second.
	self assert: line2 startPoint equals: 250 @ expectedStartY.
	self assert: line2 endPoint equals: 250 @ expectedEndY.
	self assert: (line2 color) equals: Color black.
	self assert: (line2 border dashArray) equals: #(5 5)

]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testDrawMessages [
	"Test that drawMessages adds the expected shapes to the canvas for a single call message."

	| canvas actor1 actor2 msg originalSize canvasShapes |
	canvas := RSCanvas new.
	refMicroUMLSequenceDiagram instVarNamed: #canvas put: canvas.

	"Create two actors with positions"
	actor1 := MicroUMLSDActor new
		name: 'A';
		x: 100;
		yourself.
	actor2 := MicroUMLSDActor new
		name: 'B';
		x: 200;
		yourself.

	"Add actors to the diagram"
	(refMicroUMLSequenceDiagram instVarNamed: #actors)
		add: actor1;
		add: actor2.

	"Create a call message between actors"
	msg := MicroUMLSDMessages new
		description: 'test';
		fromActor: actor1;
		toActor: actor2;
		y: 50;
		messageType: #call;
		yourself.
	(refMicroUMLSequenceDiagram instVarNamed: #messages) add: msg.

	"Record initial canvas state"
	originalSize := canvas shapes size.

	"Execute the method under test"
	refMicroUMLSequenceDiagram drawMessages.

	"Verify shapes were added"
	canvasShapes := canvas shapes.
	self assert: originalSize equals: 0.
	self assert: canvasShapes size equals: 2.
	self assert: (canvasShapes anySatisfy: [ :s | s isKindOf: RSPolyline ]).
	self assert: (canvasShapes anySatisfy: [ :s | s isKindOf: RSLabel ])
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testInitialize [
	"Test that #initialize sets empty OrderedCollections for #actors and #messages,
	default #uiTitle to 'Sequence Diagram', and leaves #canvas as nil."
	
	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #actors) isKindOf: OrderedCollection).
	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #actors) isEmpty).
	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #messages) isKindOf: OrderedCollection).
	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #messages) isEmpty).
	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #uiTitle) = 'Sequence Diagram').
	self assert: (refMicroUMLSequenceDiagram instVarNamed: #canvas) isNil
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testLifelineHeight [
	"Test the lifelineHeight method which computes total height based on number of messages and margins"
	
	| emptyMessages oneMessage twoMessages |
	emptyMessages := OrderedCollection new.
	oneMessage := OrderedCollection with: Object new.
	twoMessages := OrderedCollection with: Object new with: Object new.
	
	"Test with 0 messages - default state after setUp"
	refMicroUMLSequenceDiagram instVarNamed: #messages put: emptyMessages.
	self assert: (refMicroUMLSequenceDiagram lifelineHeight = (MicroUMLSDMessages topMargin + MicroUMLSDMessages bottomMargin)) description: 'lifelineHeight should be topMargin + bottomMargin with 0 messages'.
	
	"Test with 1 message"
	refMicroUMLSequenceDiagram instVarNamed: #messages put: oneMessage.
	self assert: (refMicroUMLSequenceDiagram lifelineHeight = (MicroUMLSDMessages topMargin + (1 * MicroUMLSDMessages messageGap) + MicroUMLSDMessages bottomMargin)) description: 'lifelineHeight should account for 1 message'.
	
	"Test with 2 messages"
	refMicroUMLSequenceDiagram instVarNamed: #messages put: twoMessages.
	self assert: (refMicroUMLSequenceDiagram lifelineHeight = (MicroUMLSDMessages topMargin + (2 * MicroUMLSDMessages messageGap) + MicroUMLSDMessages bottomMargin)) description: 'lifelineHeight should account for 2 messages'.
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testRenderDiagram [
	"Test that renderDiagram creates a canvas, computes positions, draws actors, lifelines and messages, and adds the correct number of shapes"

	| actor1 actor2 msg1 actors messages canvas |
	
	"Create actors"
	actor1 := MicroUMLSDActor new name: 'A'.
	actor2 := MicroUMLSDActor new name: 'B'.
	
	"Create a call message from actor1 to actor2"
	msg1 := MicroUMLSDMessages new
		description: 'hello';
		fromActor: actor1;
		toActor: actor2;
		messageType: #call;
		yourself.
	
	"Add actors and message to the diagram"
	actors := refMicroUMLSequenceDiagram instVarNamed: #actors.
	actors
		add: actor1;
		add: actor2.
	messages := refMicroUMLSequenceDiagram instVarNamed: #messages.
	messages add: msg1.
	
	"Assert canvas is nil before rendering"
	self assert: (refMicroUMLSequenceDiagram instVarNamed: #canvas) isNil.
	
	"Render the diagram"
	refMicroUMLSequenceDiagram renderDiagram.
	
	"Retrieve canvas and perform assertions"
	canvas := refMicroUMLSequenceDiagram instVarNamed: #canvas.
	self assert: canvas notNil.
	self assert: (canvas isKindOf: RSCanvas).
	
	"Assert positions are computed"
	self assert: (actor1 x notNil).
	self assert: (actor2 x notNil).
	self assert: (actor2 x > actor1 x).
	self assert: (msg1 y notNil).
	
	"Assert correct number of top-level shapes: 2 RSComposite (actors) + 2 RSLine (lifelines) + 2 (RSPolyline + RSLabel for message)"
	self assert: (canvas shapes size) equals: 6
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testUiTitleArg [
	"Test that uiTitle: correctly sets the uiTitle instance variable"

	| expectedTitle |
	expectedTitle := 'Custom Sequence Diagram Title'.

	refMicroUMLSequenceDiagram uiTitle: expectedTitle.

	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #uiTitle) = expectedTitle)
		description: 'The uiTitle instance variable should be set to the given title'
]
