Class {
	#name : 'MicroUMLSDAstBuilderAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDAstBuilder'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicroUMLSDAstBuilderAITest >> setUp [
	super setUp.
	refMicroUMLSDAstBuilder := MicroUMLSDAstBuilder new.
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testActors [
	"Test that actors method returns the collection of actors in the sequence diagram"
	| result |
	
	"Test with empty builder - should return empty collection"
	result := refMicroUMLSDAstBuilder actors.
	self assert: (result isKindOf: Array).
	self assert: (result isEmpty).
	
	"Test with actors added - should return collection of actors"
	refMicroUMLSDAstBuilder := MicroUMLSDAstBuilder , 'Actor1' , 'Actor2' , 'Actor3'.
	result := refMicroUMLSDAstBuilder actors.
	self assert: (result isKindOf: Array).
	self assert: (result size = 3).
	self assert: (result first isKindOf: MicroUMLSDActor).
	self assert: (result second isKindOf: MicroUMLSDActor).
	self assert: (result third isKindOf: MicroUMLSDActor).
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testInitialize [
	"Test that initialize properly sets up empty collections for actors and messages"
	
	| actors messages |
	
	"Initialize the builder"
	refMicroUMLSDAstBuilder initialize.
	
	"Get the instance variables after initialization"
	actors := refMicroUMLSDAstBuilder instVarNamed: #actors.
	messages := refMicroUMLSDAstBuilder instVarNamed: #messages.
	
	"Verify actors is initialized as an empty OrderedDictionary"
	self assert: (actors isKindOf: OrderedDictionary).
	self assert: (actors isEmpty).
	
	"Verify messages is initialized as an empty OrderedCollection"
	self assert: (messages isKindOf: OrderedCollection).
	self assert: (messages isEmpty).
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testLastMethod [
	"Test that lastMethod: correctly sets the lastMethod instance variable"
	| testMethod |
	
	"Initialize test data"
	testMethod := #testMethodName.
	
	"Execute the method under test"
	refMicroUMLSDAstBuilder lastMethod: testMethod.
	
	"Verify the lastMethod instance variable was set correctly"
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #lastMethod) = testMethod).
	
	"Test with a different value to ensure it updates correctly"
	testMethod := 'anotherMethod'.
	refMicroUMLSDAstBuilder lastMethod: testMethod.
	self assert: ((refMicroUMLSDAstBuilder instVarNamed: #lastMethod) = testMethod)
]

{ #category : 'AI generated test' }
MicroUMLSDAstBuilderAITest >> testMessages [
	"Test that messages returns the collection of messages exchanged between actors"
	| messages |
	
	"Test empty messages collection initially"
	messages := refMicroUMLSDAstBuilder messages.
	self assert: (messages isKindOf: OrderedCollection).
	self assert: (messages isEmpty).
	
	"Add some actors and messages"
	refMicroUMLSDAstBuilder , 'Actor1' , 'Actor2' & 'Actor1' -> 'Actor2' => 'message1' & 'Actor2' -> 'Actor1' => 'response'.
	
	"Test messages collection after adding messages"
	messages := refMicroUMLSDAstBuilder messages.
	self assert: (messages size = 2).
	self assert: (messages first isKindOf: MicroUMLSDMessages).
	self assert: (messages second isKindOf: MicroUMLSDMessages).
]
