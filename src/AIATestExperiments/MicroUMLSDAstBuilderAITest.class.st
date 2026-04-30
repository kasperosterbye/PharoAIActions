Class {
	#name : 'MicroUMLSDAstBuilderAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDAstBuilder'
	],
	#category : 'AIATestExperiments-MicroUMLTests',
	#package : 'AIATestExperiments',
	#tag : 'MicroUMLTests'
}

{ #category : 'initialization' }
MicroUMLSDAstBuilderAITest >> setUp [
	super setUp.
	refMicroUMLSDAstBuilder := MicroUMLSDAstBuilder new.
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testActorsAndMessages [
	| result actorsArray messagesCollection actor1 actor2 msg1 msg2 |
	"Set up a simple sequence diagram with two actors and two messages"
	refMicroUMLSDAstBuilder , 'Actor1'.
	refMicroUMLSDAstBuilder , 'Actor2'.
	refMicroUMLSDAstBuilder & 'Actor1' -> 'Actor2' => 'hello'.
	refMicroUMLSDAstBuilder & 'Actor2' -> 'Actor1' => 'world'.

	"Call the method under test"
	result := refMicroUMLSDAstBuilder actorsAndMessages.

	"Result should be an Array of size 2: { actors values. messages }"
	self assert: (result isKindOf: Array).
	self assert: result size equals: 2.

	"First element is an Array of MicroUMLSDActor"
	actorsArray := result first.
	self assert: (actorsArray isKindOf: Array).
	self assert: actorsArray size equals: 2.

	"Verify first actor"
	actor1 := actorsArray first.
	self assert: (actor1 isKindOf: MicroUMLSDActor).
	self assert: actor1 name equals: 'Actor1'.
	self assert: actor1 index equals: 1.

	"Verify second actor"
	actor2 := actorsArray second.
	self assert: (actor2 isKindOf: MicroUMLSDActor).
	self assert: actor2 name equals: 'Actor2'.
	self assert: actor2 index equals: 2.

	"Second element is an OrderedCollection of MicroUMLSDMessages"
	messagesCollection := result second.
	self assert: (messagesCollection isKindOf: OrderedCollection).
	self assert: messagesCollection size equals: 2.

	"Verify first message"
	msg1 := messagesCollection first.
	self assert: (msg1 isKindOf: MicroUMLSDMessages).
	self assert: msg1 description equals: 'hello'.
	self assert: msg1 fromActor name equals: 'Actor1'.
	self assert: msg1 toActor name equals: 'Actor2'.
	self assert: msg1 messageType equals: #call.

	"Verify second message"
	msg2 := messagesCollection second.
	self assert: (msg2 isKindOf: MicroUMLSDMessages).
	self assert: msg2 description equals: 'world'.
	self assert: msg2 fromActor name equals: 'Actor2'.
	self assert: msg2 toActor name equals: 'Actor1'.
	self assert: msg2 messageType equals: #call

]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testAmpersandFrom [
	"Test that & from: adds a new message with the specified fromActor and toActor set to nil, and updates actorOrMessage accordingly."

	| actors messages actorOrMessage actor message |

	refMicroUMLSDAstBuilder , 'TestActor'; & 'TestActor'.

	actors := refMicroUMLSDAstBuilder instVarNamed: #actors.
	messages := refMicroUMLSDAstBuilder instVarNamed: #messages.
	actorOrMessage := refMicroUMLSDAstBuilder instVarNamed: #actorOrMessage.
	actor := actors at: 'TestActor'.
	message := messages first.

	self assert: (messages size) equals: 1.
	self assert: actorOrMessage equals: message.
	self assert: (message fromActor) equals: actor.
	self assert: (message toActor isNil).
	self assert: (message description isNil).
	self assert: (message messageType isNil).
	self assert: (actor name) equals: 'TestActor'.
	self assert: (actor index) equals: 1
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testArrowTo [
	| actors messages message toActor result |
	"Add the actors needed by the message sender and receiver."
	refMicroUMLSDAstBuilder , 'SourceActor'.
	refMicroUMLSDAstBuilder , 'TargetActor'.

	"Create a message whose receiver is not yet assigned."
	refMicroUMLSDAstBuilder & 'SourceActor'.

	"Read the builder state through reflective instance-variable access."
	actors := refMicroUMLSDAstBuilder instVarNamed: #actors.
	messages := refMicroUMLSDAstBuilder instVarNamed: #messages.
	message := messages last.
	toActor := actors at: 'TargetActor'.

	"Verify the message starts without a receiver."
	self assert: ((message instVarNamed: #toActor) isNil).

	"Assign the receiver using the method under test."
	result := refMicroUMLSDAstBuilder -> 'TargetActor'.

	"Verify the receiver was set on the existing last message."
	self assert: ((message instVarNamed: #toActor) == toActor).
	self assert: ((messages last) == message).
	self assert: (messages size = 1).

	"Verify the method returns the builder for chaining."
	self assert: (result == refMicroUMLSDAstBuilder)
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testAt [
	"Test that @ attaches the given block to the last actor or message."
	| actionBlock result actorOrMessage storedClickAction |

	"Create an actor so that the builder has a current actorOrMessage."
	refMicroUMLSDAstBuilder , 'ClickableActor'.

	"Attach a click action block using @."
	actionBlock := [ 42 ].
	result := refMicroUMLSDAstBuilder @ actionBlock.

	"Verify that @ answers the builder itself."
	self assert: (result == refMicroUMLSDAstBuilder).

	"Verify that the block was stored on the current actorOrMessage."
	actorOrMessage := refMicroUMLSDAstBuilder instVarNamed: #actorOrMessage.
	storedClickAction := actorOrMessage instVarNamed: #clickAction.
	self assert: (storedClickAction == actionBlock)
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testComma [
	"Tests the comma operator for adding actors to the sequence diagram AST builder."

	| actors actor result |

	"Add the first actor and verify the method answers the builder."
	result := refMicroUMLSDAstBuilder , 'Actor1'.
	self assert: (result == refMicroUMLSDAstBuilder).

	"Verify that the first actor is stored with the expected key and state."
	actors := refMicroUMLSDAstBuilder instVarNamed: #actors.
	self assert: (actors size) equals: 1.
	self assert: (actors includesKey: 'Actor1').

	actor := actors at: 'Actor1'.
	self assert: ((actor instVarNamed: #name) = 'Actor1').
	self assert: ((actor instVarNamed: #index) = 1).
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #actorOrMessage) == actor).

	"Adding the same actor again must not create a duplicate."
	result := refMicroUMLSDAstBuilder , 'Actor1'.
	self assert: (result == refMicroUMLSDAstBuilder).
	self assert: (actors size) equals: 1.
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #actorOrMessage) == actor).

	"Add a second actor and verify that its index follows the existing actor."
	refMicroUMLSDAstBuilder , 'Actor2'.
	self assert: (actors size) equals: 2.
	self assert: (actors includesKey: 'Actor2').

	actor := actors at: 'Actor2'.
	self assert: ((actor instVarNamed: #name) = 'Actor2').
	self assert: ((actor instVarNamed: #index) = 2).
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #actorOrMessage) == actor).

	"After a message has been started with &, comma must raise the expected error."
	refMicroUMLSDAstBuilder & 'Actor1'.
	self
		should: [ refMicroUMLSDAstBuilder , 'Actor3' ]
		raise: Error
		withExceptionDo: [ :exception |
			self assert: (exception messageText = 'No new usage of `,` after an `&`') ]
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testDashDashGreaterThan [
	"Test the --> method which sets message type to #return and updates description.
	 Also verifies that when toActor is nil, it defaults to fromActor."
	| messages lastMessage actors actorA actorB result |

	"Set up two actors using the , method"
	refMicroUMLSDAstBuilder , 'ActorA'.
	refMicroUMLSDAstBuilder , 'ActorB'.

	"Scenario 1: --> on a message where toActor is already set"
	refMicroUMLSDAstBuilder & 'ActorA' -> 'ActorB'.
	refMicroUMLSDAstBuilder --> 'returnDesc'.

	"Retrieve the messages collection from the builder"
	messages := refMicroUMLSDAstBuilder instVarNamed: #messages.
	self assert: (messages size = 1).

	lastMessage := messages last.
	actors := refMicroUMLSDAstBuilder instVarNamed: #actors.
	actorA := actors at: 'ActorA'.
	actorB := actors at: 'ActorB'.

	"Verify description is set to the provided string"
	self assert: (lastMessage description = 'returnDesc').
	"Verify messageType is set to #return"
	self assert: (lastMessage messageType = #return).
	"Verify toActor remains as ActorB (was already set)"
	self assert: (lastMessage toActor == actorB).
	"Verify fromActor is ActorA"
	self assert: (lastMessage fromActor == actorA).

	"Scenario 2: --> on a message where toActor is nil (should default to fromActor)"
	refMicroUMLSDAstBuilder & 'ActorB'.
	"At this point the new message has toActor nil and fromActor is ActorB"
	refMicroUMLSDAstBuilder --> 'selfReturn'.

	messages := refMicroUMLSDAstBuilder instVarNamed: #messages.
	self assert: (messages size = 2).

	lastMessage := messages last.
	"Verify description is set"
	self assert: (lastMessage description = 'selfReturn').
	"Verify messageType is #return"
	self assert: (lastMessage messageType = #return).
	"Verify toActor was set to fromActor since it was nil"
	self assert: (lastMessage toActor == actorB).
	self assert: (lastMessage fromActor == actorB).

	"Scenario 3: Verify --> returns self for chaining"
	refMicroUMLSDAstBuilder & 'ActorA' -> 'ActorB'.
	result := refMicroUMLSDAstBuilder --> 'chained'.
	self assert: (result == refMicroUMLSDAstBuilder).

]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testEqualsGreaterThan [
	| actors messages firstMessage secondMessage actorA actorB result |

	"Create the actors needed by the explicit and internal call messages."
	refMicroUMLSDAstBuilder , 'ActorA'.
	refMicroUMLSDAstBuilder , 'ActorB'.
	actors := refMicroUMLSDAstBuilder instVarNamed: #actors.
	actorA := actors at: 'ActorA'.
	actorB := actors at: 'ActorB'.

	"Create a message with an explicit receiver; => should mark it as a call."
	refMicroUMLSDAstBuilder lastMethod: #explicitCallMethod.
	refMicroUMLSDAstBuilder & 'ActorA' -> 'ActorB'.
	result := refMicroUMLSDAstBuilder => 'explicit call'.
	messages := refMicroUMLSDAstBuilder instVarNamed: #messages.
	firstMessage := messages first.

	"Verify that => returns the builder and updates the explicit call message."
	self assert: (result == refMicroUMLSDAstBuilder).
	self assert: ((firstMessage instVarNamed: #description) = 'explicit call').
	self assert: ((firstMessage instVarNamed: #messageType) = #call).
	self assert: ((firstMessage instVarNamed: #fromActor) == actorA).
	self assert: ((firstMessage instVarNamed: #toActor) == actorB).
	self assert: ((firstMessage instVarNamed: #lastMethod) = #explicitCallMethod).

	"Create a message without an explicit receiver; => should make it internal."
	refMicroUMLSDAstBuilder lastMethod: #internalCallMethod.
	refMicroUMLSDAstBuilder & 'ActorA'.
	result := refMicroUMLSDAstBuilder => 'internal call'.
	secondMessage := messages second.

	"Verify that => sets the receiver to the sender and records the internal call state."
	self assert: (result == refMicroUMLSDAstBuilder).
	self assert: (messages size = 2).
	self assert: ((secondMessage instVarNamed: #description) = 'internal call').
	self assert: ((secondMessage instVarNamed: #messageType) = #internal).
	self assert: ((secondMessage instVarNamed: #fromActor) == actorA).
	self assert: ((secondMessage instVarNamed: #toActor) == actorA).
	self assert: ((secondMessage instVarNamed: #lastMethod) = #internalCallMethod)
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testInitialize [
	"Test that initialize sets up empty collections for actors and messages"

	"Test that actors is an empty OrderedDictionary"
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #actors) isKindOf: OrderedDictionary).
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #actors) isEmpty).

	"Test that messages is an empty OrderedCollection"
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #messages) isKindOf: OrderedCollection).
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #messages) isEmpty)
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testLastMethodArg [
	"Test that lastMethod: correctly sets the lastMethod instance variable on the builder.
	 Verifies initial nil value and post-set value."

	| meth |
	meth := #testMethod.
	
	"Verify initial value is nil after setUp creates a new instance."
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #lastMethod) isNil).
	
	"Invoke the setter."
	refMicroUMLSDAstBuilder lastMethod: meth.
	
	"Verify the instance variable was set correctly."
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #lastMethod) = meth)
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testRenderDiagram [
	"Test that renderDiagram builds and renders a sequence diagram from the builder actors and messages."

	| actors messages actorA actorB message |

	"Create a minimal valid sequence diagram in the existing builder provided by setUp."
	refMicroUMLSDAstBuilder , 'ActorA'.
	refMicroUMLSDAstBuilder , 'ActorB'.
	refMicroUMLSDAstBuilder & 'ActorA' -> 'ActorB' => 'hello'.

	"Keep references to the builder state before rendering."
	actors := refMicroUMLSDAstBuilder instVarNamed: #actors.
	messages := refMicroUMLSDAstBuilder instVarNamed: #messages.
	actorA := actors at: 'ActorA'.
	actorB := actors at: 'ActorB'.
	message := messages first.

	"Rendering should complete without raising an error."
	self
		shouldnt: [ refMicroUMLSDAstBuilder renderDiagram ]
		raise: Error.

	"Rendering uses the same actor and message objects and assigns their diagram positions."
	self assert: ((actors size) = 2).
	self assert: ((messages size) = 1).
	self assert: ((actorA instVarNamed: #x) notNil).
	self assert: ((actorB instVarNamed: #x) notNil).
	self assert: ((message instVarNamed: #y) notNil).
	self assert: ((message instVarNamed: #description) = 'hello').
	self assert: ((message instVarNamed: #messageType) = #call)
]
