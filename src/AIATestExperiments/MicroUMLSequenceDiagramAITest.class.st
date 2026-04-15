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
MicroUMLSequenceDiagramAITest >> testActors [
	"Test that actors method returns the collection of actors in the sequence diagram"
	
	| actors |
	
	"Initially, actors collection should be empty"
	actors := refMicroUMLSequenceDiagram actors.
	self assert: (actors isKindOf: OrderedCollection).
	self assert: (actors isEmpty).
	
	"After adding one actor, collection should contain one actor"
	refMicroUMLSequenceDiagram addActor: 'TestActor1'.
	actors := refMicroUMLSequenceDiagram actors.
	self assert: (actors size = 1).
	
	"After adding another actor, collection should contain two actors"
	refMicroUMLSequenceDiagram addActor: 'TestActor2'.
	actors := refMicroUMLSequenceDiagram actors.
	self assert: (actors size = 2).
	
	"Verify that the actors method returns the same collection instance"
	self assert: (refMicroUMLSequenceDiagram actors == refMicroUMLSequenceDiagram actors).
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testAddActor [
	"Test that addActor: creates and adds an actor with correct name and index"
	| actor |
	
	"Initially actors collection should be empty"
	self assert: (refMicroUMLSequenceDiagram actors isEmpty).
	
	"Add first actor"
	actor := refMicroUMLSequenceDiagram addActor: 'LoginSystem'.
	
	"Verify the actor was created correctly"
	self assert: (actor name = 'LoginSystem').
	self assert: (actor index = 1).
	
	"Verify the actor was added to the collection"
	self assert: (refMicroUMLSequenceDiagram actors size = 1).
	self assert: (refMicroUMLSequenceDiagram actors first = actor).
	
	"Add second actor to test index increment"
	actor := refMicroUMLSequenceDiagram addActor: 'Database'.
	
	"Verify second actor has correct index"
	self assert: (actor name = 'Database').
	self assert: (actor index = 2).
	self assert: (refMicroUMLSequenceDiagram actors size = 2).
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testAddInternalFor [
	"Test that addInternal:for: correctly adds an internal message for a specified actor"
	| message fromActor toActor |
	
	"Add an actor to the sequence diagram"
	refMicroUMLSequenceDiagram addActor: 'TestActor'.
	
	"Add an internal message for the actor"
	refMicroUMLSequenceDiagram addInternal: 'internal operation' for: 'TestActor'.
	
	"Verify that one message was added"
	self assert: (refMicroUMLSequenceDiagram messages size = 1).
	
	"Get the added message"
	message := refMicroUMLSequenceDiagram messages first.
	
	"Verify the message type is internal"
	self assert: ((message instVarNamed: #messageType) = #internal).
	
	"Verify the message description"
	self assert: ((message instVarNamed: #description) = 'internal operation').
	
	"Verify the from and to actors are the same"
	fromActor := message instVarNamed: #fromActor.
	toActor := message instVarNamed: #toActor.
	self assert: (fromActor name = 'TestActor').
	self assert: (toActor name = 'TestActor').
	self assert: (fromActor = toActor).
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testAddMessageFromTo [
	"Test that addMessage:from:to: correctly adds a call message between two actors"
	| actor1 actor2 message |
	
	"Set up actors in the sequence diagram"
	actor1 := refMicroUMLSequenceDiagram addActor: 'Client'.
	actor2 := refMicroUMLSequenceDiagram addActor: 'Server'.
	
	"Add a message from Client to Server"
	message := refMicroUMLSequenceDiagram addMessage: 'authenticate' from: 'Client' to: 'Server'.
	
	"Verify the message was added to the messages collection"
	self assert: (refMicroUMLSequenceDiagram messages size = 1).
	
	"Verify the message has the correct properties"
	self assert: (message description = 'authenticate').
	self assert: (message messageType = #call).
	self assert: (message fromActor = actor1).
	self assert: (message toActor = actor2).
	
	"Verify the message is the same one in the collection"
	self assert: (refMicroUMLSequenceDiagram messages first = message)
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testAddNameFromTo [
	"Test the add:name:from:to: method to ensure it correctly creates and adds a message between actors"
	| result fromActor toActor |
	
	"Set up actors for the test"
	refMicroUMLSequenceDiagram addActor: 'Actor1'.
	refMicroUMLSequenceDiagram addActor: 'Actor2'.
	
	"Get references to the actors for verification"
	fromActor := refMicroUMLSequenceDiagram actors detect: [ :a | a name = 'Actor1' ].
	toActor := refMicroUMLSequenceDiagram actors detect: [ :a | a name = 'Actor2' ].
	
	"Test adding a message"
	result := refMicroUMLSequenceDiagram add: #call name: 'test message' from: 'Actor1' to: 'Actor2'.
	
	"Verify the result is a MicroUMLSDMessages instance"
	self assert: (result isKindOf: MicroUMLSDMessages).
	
	"Verify the message was added to the messages collection"
	self assert: (refMicroUMLSequenceDiagram messages size = 1).
	
	"Verify the message properties are set correctly"
	self assert: (result description = 'test message').
	self assert: (result messageType = #call).
	self assert: (result fromActor = fromActor).
	self assert: (result toActor = toActor).
	
	"Verify the message is in the messages collection"
	self assert: (refMicroUMLSequenceDiagram messages includes: result).
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testAddReturnFromTo [
	"Test that addReturn:from:to: correctly adds a return message to the sequence diagram"
	| message |
	
	"Setup actors for the return message"
	refMicroUMLSequenceDiagram addActor: 'Database'.
	refMicroUMLSequenceDiagram addActor: 'LoginSystem'.
	
	"Add a return message from Database to LoginSystem"
	refMicroUMLSequenceDiagram addReturn: 'authentication result' from: 'Database' to: 'LoginSystem'.
	
	"Verify that one message was added"
	self assert: (refMicroUMLSequenceDiagram messages size = 1).
	
	"Get the added message and verify its properties"
	message := refMicroUMLSequenceDiagram messages first.
	
	"Verify the message type is return"
	self assert: ((message instVarNamed: #messageType) = #return).
	
	"Verify the description is correct"
	self assert: ((message instVarNamed: #description) = 'authentication result').
	
	"Verify the from actor name is correct"
	self assert: ((message instVarNamed: #fromActor) printString includesSubstring: 'Database').
	
	"Verify the to actor name is correct"
	self assert: ((message instVarNamed: #toActor) printString includesSubstring: 'LoginSystem')
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testBuild [
	"Test that the build method creates a canvas, computes positions for actors and messages, draws elements, and adds the canvas controller"
	| canvas actors messages firstActor firstMessage |
	
	"Setup: Add actors and messages to the diagram"
	refMicroUMLSequenceDiagram addActor: 'Actor1'.
	refMicroUMLSequenceDiagram addActor: 'Actor2'.
	refMicroUMLSequenceDiagram addMessage: 'test message' from: 'Actor1' to: 'Actor2'.
	refMicroUMLSequenceDiagram addReturn: 'response' from: 'Actor2' to: 'Actor1'.
	
	actors := refMicroUMLSequenceDiagram instVarNamed: #actors.
	messages := refMicroUMLSequenceDiagram instVarNamed: #messages.
	firstActor := actors first.
	firstMessage := messages first.
	
	"Verify initial state before build"
	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #canvas) isNil).
	self assert: ((firstActor instVarNamed: #x) isNil).
	self assert: ((firstMessage instVarNamed: #y) isNil).
	
	"Execute the build method"
	refMicroUMLSequenceDiagram build.
	
	"Retrieve canvas after build"
	canvas := refMicroUMLSequenceDiagram instVarNamed: #canvas.
	
	"Verify canvas creation and population"
	self assert: (canvas isKindOf: RSCanvas).
	self assert: (canvas numberOfShapes > 0).
	self assert: (canvas propertyAt: RSCanvasController ifAbsent: [ nil ]) notNil.
	
	"Verify positions computed"
	self assert: ((firstActor instVarNamed: #x) isNumber).
	self assert: ((firstMessage instVarNamed: #y) isNumber)
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testComputeActorPositions [
	"Test that computeActorPositions correctly calculates horizontal positions of actors based on message distances"
	| actor1 actor2 actor3 message1 message2 expectedX1 expectedX2 expectedX3 |
	
	"Create test actors"
	actor1 := MicroUMLSDActor new name: 'Actor1'; yourself.
	actor2 := MicroUMLSDActor new name: 'Actor2'; yourself.
	actor3 := MicroUMLSDActor new name: 'LongActorName'; yourself.
	
	"Add actors to the diagram"
	refMicroUMLSequenceDiagram instVarNamed: #actors put: (OrderedCollection with: actor1 with: actor2 with: actor3).
	
	"Create test messages between actors"
	message1 := MicroUMLSDMessages new
		description: 'short';
		fromActor: actor1;
		toActor: actor2;
		messageType: #call;
		yourself.
	message2 := MicroUMLSDMessages new
		description: 'this is a very long message description that should affect spacing';
		fromActor: actor2;
		toActor: actor3;
		messageType: #call;
		yourself.
	
	"Add messages to the diagram"
	refMicroUMLSequenceDiagram instVarNamed: #messages put: (OrderedCollection with: message1 with: message2).
	
	"Execute the method under test"
	refMicroUMLSequenceDiagram computeActorPositions.
	
	"Verify first actor is positioned at actorGap"
	expectedX1 := (refMicroUMLSequenceDiagram instVarNamed: #actorGap).
	self assert: (actor1 x = expectedX1).
	
	"Verify second actor position is greater than first"
	self assert: (actor2 x > actor1 x).
	
	"Verify third actor position is greater than second"
	self assert: (actor3 x > actor2 x).
	
	"Verify actors have x positions set (not nil)"
	self assert: (actor1 x notNil).
	self assert: (actor2 x notNil).
	self assert: (actor3 x notNil).
	
	"Verify spacing between actors is reasonable (at least minimum gap)"
	self assert: ((actor2 x - actor1 x) >= (refMicroUMLSequenceDiagram instVarNamed: #actorGap)).
	self assert: ((actor3 x - actor2 x) >= (refMicroUMLSequenceDiagram instVarNamed: #actorGap))
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testComputeMessagePositions [
	"Test that computeMessagePositions correctly sets the y position of each message"
	| expectedY1 expectedY2 expectedY3 msg1 msg2 msg3 |
	
	"Add actors to the diagram"
	refMicroUMLSequenceDiagram addActor: 'Actor1'.
	refMicroUMLSequenceDiagram addActor: 'Actor2'.
	refMicroUMLSequenceDiagram addActor: 'Actor3'.
	
	"Add three messages to test positioning"
	refMicroUMLSequenceDiagram addMessage: 'message1' from: 'Actor1' to: 'Actor2'.
	refMicroUMLSequenceDiagram addMessage: 'message2' from: 'Actor2' to: 'Actor3'.
	refMicroUMLSequenceDiagram addMessage: 'message3' from: 'Actor3' to: 'Actor1'.
	
	"Get references to the messages for testing"
	msg1 := refMicroUMLSequenceDiagram messages at: 1.
	msg2 := refMicroUMLSequenceDiagram messages at: 2.
	msg3 := refMicroUMLSequenceDiagram messages at: 3.
	
	"Calculate expected y positions based on the algorithm"
	expectedY1 := MicroUMLSDMessages topMargin + (1 * MicroUMLSDMessages messageGap).
	expectedY2 := MicroUMLSDMessages topMargin + (2 * MicroUMLSDMessages messageGap).
	expectedY3 := MicroUMLSDMessages topMargin + (3 * MicroUMLSDMessages messageGap).
	
	"Execute the method under test"
	refMicroUMLSequenceDiagram computeMessagePositions.
	
	"Assert that each message has the correct y position"
	self assert: (msg1 y = expectedY1).
	self assert: (msg2 y = expectedY2).
	self assert: (msg3 y = expectedY3).
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testDrawActors [
	"Test that drawActors adds the correct number of actor drawings to the canvas and that the labels match actor names"
	| canvas initialSize finalSize actorsCollection actorNames shapeLabels |
	
	actorsCollection := refMicroUMLSequenceDiagram instVarNamed: #actors.
	
	"Setup: Add some actors to the sequence diagram"
	refMicroUMLSequenceDiagram addActor: 'Actor1'.
	refMicroUMLSequenceDiagram addActor: 'Actor2'.
	refMicroUMLSequenceDiagram addActor: 'Actor3'.
	
	"Set positions to avoid nil x error in actor draw"
	actorsCollection doWithIndex: [ :actor :idx |
		actor instVarNamed: #x put: (50 + ((idx - 1) * 200)) ].
	
	"Initialize canvas and get initial size"
	canvas := RSCanvas new.
	refMicroUMLSequenceDiagram instVarNamed: #canvas put: canvas.
	initialSize := canvas numberOfShapes.
	
	"Execute the method under test"
	refMicroUMLSequenceDiagram drawActors.
	
	"Verify canvas size increased by number of actors"
	finalSize := canvas numberOfShapes.
	self assert: (finalSize = (initialSize + actorsCollection size)).
	
	"Verify that the drawn shapes have correct actor names in labels"
	shapeLabels := ((canvas shapes collect: [ :shape | shape shapes second text ]) sorted asArray).
	actorNames := ((actorsCollection collect: [ :actor | actor instVarNamed: #name ]) sorted asArray).
	self assert: shapeLabels equals: actorNames
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testDrawLifelines [
	"Test that drawLifelines creates correct lifelines for each actor"
	| actor1 actor2 canvas lines line1 line2 expectedStartY expectedEndY |
	
	"Create test actors with specific positions"
	actor1 := MicroUMLSDActor new.
	actor1 name: 'Actor1'; x: 100.
	actor2 := MicroUMLSDActor new.
	actor2 name: 'Actor2'; x: 200.
	
	"Set up the diagram with actors, canvas, and empty messages for known lifelineHeight=30"
	refMicroUMLSequenceDiagram instVarNamed: #actors put: { actor1. actor2 }.
	refMicroUMLSequenceDiagram instVarNamed: #canvas put: RSCanvas new.
	refMicroUMLSequenceDiagram instVarNamed: #messages put: OrderedCollection new.
	
	"Execute the method under test"
	refMicroUMLSequenceDiagram drawLifelines.
	
	"Get the canvas and verify lifelines were added"
	canvas := refMicroUMLSequenceDiagram instVarNamed: #canvas.
	lines := canvas shapes.
	
	"Verify correct number of lifelines created"
	self assert: (lines size = 2).
	
	"Verify all elements are RSLine instances"
	self assert: (lines allSatisfy: [ :line | (line isKindOf: RSLine) ]).
	
	"Get individual lines for detailed testing"
	line1 := lines first.
	line2 := lines second.
	
	"Calculate expected Y coordinates"
	expectedStartY := MicroUMLSDActor boxHeight / 2.  "20.0"
	expectedEndY := expectedStartY + refMicroUMLSequenceDiagram lifelineHeight.  "50.0"
	
	"Verify first lifeline properties"
	self assert: (line1 startPoint = (100 @ expectedStartY)).
	self assert: (line1 endPoint = (100 @ expectedEndY)).
	self assert: (line1 border dashArray = #(5 5)).
	self assert: (line1 color = Color black).
	
	"Verify second lifeline properties"
	self assert: (line2 startPoint = (200 @ expectedStartY)).
	self assert: (line2 endPoint = (200 @ expectedEndY)).
	self assert: (line2 border dashArray = #(5 5)).
	self assert: (line2 color = Color black)
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testDrawMessages [
	"Test that #drawMessages adds the shapes returned by each message's #draw onto the diagram canvas."

	| canvas initialShapeCount msg1 msg2 expectedAddedShapeCount finalShapeCount |

	"Arrange: create a diagram with two actors and two messages"
	refMicroUMLSequenceDiagram addActor: 'Actor1'.
	refMicroUMLSequenceDiagram addActor: 'Actor2'.
	msg1 := refMicroUMLSequenceDiagram addMessage: 'call' from: 'Actor1' to: 'Actor2'.
	msg2 := refMicroUMLSequenceDiagram addReturn: 'return' from: 'Actor2' to: 'Actor1'.

	"Arrange: compute positions required by message drawing"
	refMicroUMLSequenceDiagram computeActorPositions.
	refMicroUMLSequenceDiagram computeMessagePositions.

	"Arrange: provide a canvas (drawMessages assumes canvas is set)"
	canvas := RSCanvas new.
	refMicroUMLSequenceDiagram instVarNamed: #canvas put: canvas.

	"Capture initial state"
	initialShapeCount := canvas numberOfShapes.

	"Compute how many shapes should be added by drawMessages"
	expectedAddedShapeCount := msg1 draw size + msg2 draw size.

	"Act"
	refMicroUMLSequenceDiagram drawMessages.

	"Assert: canvas gained exactly the shapes produced by the messages"
	finalShapeCount := canvas numberOfShapes.
	self assert: (finalShapeCount = (initialShapeCount + expectedAddedShapeCount)).
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testInitialize [
	"Test that initialize properly sets up the sequence diagram with empty collections and default actor gap"
	
	| expectedActorGap |
	expectedActorGap := MicroUMLSDActor actorGap.
	
	"Call initialize on the test instance"
	refMicroUMLSequenceDiagram initialize.
	
	"Verify actors collection is initialized as empty OrderedCollection"
	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #actors) isKindOf: OrderedCollection).
	self assert: (refMicroUMLSequenceDiagram instVarNamed: #actors) isEmpty.
	
	"Verify messages collection is initialized as empty OrderedCollection"
	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #messages) isKindOf: OrderedCollection).
	self assert: (refMicroUMLSequenceDiagram instVarNamed: #messages) isEmpty.
	
	"Verify actorGap is set to the default value from MicroUMLSDActor"
	self assert: (refMicroUMLSequenceDiagram instVarNamed: #actorGap) equals: expectedActorGap.
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testLifelineHeight [
	"Test that lifelineHeight returns the correct total height based on messages and margins"
	| expectedHeight actualHeight |
	
	"Test with empty messages collection - should return topMargin + bottomMargin"
	expectedHeight := MicroUMLSDMessages topMargin + MicroUMLSDMessages bottomMargin.
	actualHeight := refMicroUMLSequenceDiagram lifelineHeight.
	self assert: (actualHeight = expectedHeight).
	
	"Add actors and one message to test calculation with messages"
	refMicroUMLSequenceDiagram addActor: 'Actor1'.
	refMicroUMLSequenceDiagram addActor: 'Actor2'.
	refMicroUMLSequenceDiagram addMessage: 'testMessage' from: 'Actor1' to: 'Actor2'.
	
	"Test with one message - should return topMargin + (1 * messageGap) + bottomMargin"
	expectedHeight := MicroUMLSDMessages topMargin + (1 * MicroUMLSDMessages messageGap) + MicroUMLSDMessages bottomMargin.
	actualHeight := refMicroUMLSequenceDiagram lifelineHeight.
	self assert: (actualHeight = expectedHeight).
	
	"Add another message to test with multiple messages"
	refMicroUMLSequenceDiagram addReturn: 'returnMessage' from: 'Actor2' to: 'Actor1'.
	
	"Test with two messages - should return topMargin + (2 * messageGap) + bottomMargin"
	expectedHeight := MicroUMLSDMessages topMargin + (2 * MicroUMLSDMessages messageGap) + MicroUMLSDMessages bottomMargin.
	actualHeight := refMicroUMLSequenceDiagram lifelineHeight.
	self assert: (actualHeight = expectedHeight)
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testMessages [
	"Test that messages: correctly sets the messages instance variable"
	| testMessages |
	
	"Create a test collection of messages"
	testMessages := OrderedCollection new.
	
	"Set the messages using the setter method"
	refMicroUMLSequenceDiagram messages: testMessages.
	
	"Verify that the messages were set correctly"
	self assert: (refMicroUMLSequenceDiagram messages == testMessages).
	
	"Test with a different collection type"
	testMessages := Array new.
	refMicroUMLSequenceDiagram messages: testMessages.
	self assert: (refMicroUMLSequenceDiagram messages == testMessages).
	
	"Test with nil"
	refMicroUMLSequenceDiagram messages: nil.
	self assert: (refMicroUMLSequenceDiagram messages isNil)
]

{ #category : 'AI generated test' }
MicroUMLSequenceDiagramAITest >> testUiTitle [
	"Test that uiTitle: correctly sets the title and uiTitle returns the set value"
	
	| testTitle |
	testTitle := 'My Sequence Diagram Title'.
	
	"Test setting and getting the title"
	refMicroUMLSequenceDiagram uiTitle: testTitle.
	self assert: (refMicroUMLSequenceDiagram uiTitle = testTitle).
	
	"Test that the instance variable is correctly set"
	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #uiTitle) = testTitle).
	
	"Test setting a different title"
	refMicroUMLSequenceDiagram uiTitle: 'Another Title'.
	self assert: (refMicroUMLSequenceDiagram uiTitle = 'Another Title').
	
	"Test that the instance variable reflects the new value"
	self assert: ((refMicroUMLSequenceDiagram instVarNamed: #uiTitle) = 'Another Title').
]
