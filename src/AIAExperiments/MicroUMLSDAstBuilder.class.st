"
# Class Comment for MicroUMLSDAstBuilder

The `MicroUMLSDAstBuilder` class is a pivotal component within the MicroUML framework, designed to construct abstract syntax trees (ASTs) for sequence diagrams. It provides a fluid and intuitive syntax for defining actors and messages within these diagrams, facilitating a clear and concise representation of interactions between system components.

## Purpose and Role in the System

The primary role of `MicroUMLSDAstBuilder` is to simplify the creation of sequence diagrams by offering a fluid syntax that enhances readability and maintainability. It acts as an intermediary between the user's intent and the underlying diagram construction, ensuring that the resulting diagrams accurately reflect the specified interactions.

## Main Collaborators or Dependencies

- **MicroUMLSDActor**: Represents the actors within the sequence diagram. The builder collaborates closely with this class to manage and initialise actors.
- **MicroUMLSDMessages**: Handles the messages exchanged between actors. The builder uses this class to define and manage the messages within the diagram.
- **MicroUMLSequenceDiagram**: The final product of the builder's efforts. Once the AST is constructed, the builder delegates the actual building of the sequence diagram to this class.

## Important Invariants or Design Constraints

- **Fluid Syntax Constraints**: The builder enforces specific constraints to ensure the fluid syntax is used correctly. For instance, it prevents the misuse of the `,` operator after an `&` to maintain the integrity of the diagram construction process.
- **Message Handling**: The builder ensures that messages are correctly typed (call or return) and that each message has a defined sender and receiver. This is crucial for the accurate representation of interactions in the sequence diagram.

## Illustrative Usage Examples

### Example 1: Basic Sequence Diagram

```st
(MicroUMLSDAstBuilder
    , 'Playground'
    , 'Login System' @ [ Transcript << 'Was here' << String lf ]
    , 'Database'
    & 'Playground' -> 'Login System' => 'call'
    & 'Login System' -> 'Database' => ('verify', String lf, 'Now')
        @ [ Transcript << 'Kilroy' << String lf ]
    & 'Database' -> 'Playground' --> '')
    build
```

This example demonstrates the creation of a sequence diagram with three actors: `Playground`, `Login System`, and `Database`. Messages are defined between these actors, including a call from `Playground` to `Login System`, a verification call from `Login System` to `Database`, and a return message from `Database` to `Playground`. The `@` operator is used to attach actions to actors, which are executed when the actor is clicked in the diagram.

### Example 2: Sequence Diagram with Internal Call

```st
(MicroUMLSDAstBuilder
    , 'Playground'
    , 'Login System' @ [ Transcript << 'Was here' << String lf ]
    , 'Database'
    & 'Playground' -> 'Login System' => 'call'
    & 'Login System' => 'self call'
    & 'Login System' -> 'Database' => ('verify', String lf, 'Now')
        @ [ Transcript << 'Kilroy' << String lf ]
    & 'Database' -> 'Playground' --> '')
    build
```

This example extends the basic sequence diagram by including an internal call within the `Login System` actor. This demonstrates the builder's ability to handle more complex interactions, including self-calls, within the sequence diagram.

## Conclusion

The `MicroUMLSDAstBuilder` class is an essential tool for creating sequence diagrams within the MicroUML framework. Its fluid syntax and robust handling of actors and messages make it a versatile and user-friendly component for system designers and developers. By adhering to the constraints and leveraging the collaborative capabilities of its dependencies, users can create accurate and meaningful sequence diagrams to represent their system interactions.
"
Class {
	#name : 'MicroUMLSDAstBuilder',
	#superclass : 'Object',
	#instVars : [
		'actors',
		'messages',
		'actorOrMessage',
		'lastMethod'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder class >> , aString [
    ^ self new , aString
]

{ #category : 'examples' }
MicroUMLSDAstBuilder class >> example1 [
	"Example demonstrating the creation and linking of UML elements"

	(MicroUMLSDAstBuilder
    , 'Playground'
    , 'Login System' @ [ Transcript << 'Was here' << String lf ]
    , 'Database'
    & 'Playground' -> 'Login System' => 'call'
    & 'Login System' -> 'Database' => ('verify', String lf, 'Now') 
			@ [  Transcript << 'Kilroy' << String lf  ]
    & 'Database' -> 'Playground' --> '')
	build
]

{ #category : 'examples' }
MicroUMLSDAstBuilder class >> example2 [
	"Example demonstrating the creation and linking of UML elements"

	(MicroUMLSDAstBuilder
    , 'Playground'
    , 'Login System' @ [ Transcript << 'Was here' << String lf ]
    , 'Database'
    & 'Playground' -> 'Login System' => 'call'
	 & 'Login System' => 'self call'
    & 'Login System' -> 'Database' => ('verify', String lf, 'Now') 
			@ [  Transcript << 'Kilroy' << String lf  ]
    & 'Database' -> 'Playground' --> '')
	build
]

{ #category : 'logical operations' }
MicroUMLSDAstBuilder >> & from [
	"Adds a new message to the sequence diagram, specifying the sender and receiver."
	messages add: (MicroUMLSDMessages new
		fromActor: (actors at: from);
		toActor: nil).
	actorOrMessage := messages last.
	^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> , aString [
	"Adds a new actor to the sequence diagram if it doesn't already exist"

	messages ifNotEmpty: [ ^ self error: 'No new usage of `,` after an `&`' ].
	(actors includesKey: aString) ifTrue: [ ^ self ].
	actors add: aString -> (MicroUMLSDActor new
			 name: aString;
			 index: actors size + 1).
	actorOrMessage := actors values at: actors size.
	^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> --> aString [
	"Sets the message type to return and updates the message description"

	| message messageType |
	message := messages last.
	messageType := #return.
	message toActor ifNil: [ message toActor: message fromActor].

	message
			 description: aString;
			 messageType: messageType;
			 yourself.
	^ self
]

{ #category : 'logical operations' }
MicroUMLSDAstBuilder >> -> to [
	"Adds a new message to the sequence diagram, specifying the sender and receiver"

    messages last toActor: (actors at: to) .
    ^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> => aString [
	"Sets the message type to call and updates the message description"

	| message messageType |
	message := messages last.
	messageType := #call.
	message toActor ifNil: [ 
		message toActor: message fromActor.
		messageType := #internal ].
   message
			 description: aString;
			 messageType: messageType ;
			 lastMethod: lastMethod;
			 yourself.
    ^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> @ aBlock [
	"Attaches a block to the last actor or message, executed when clicked in the diagram"
	
	actorOrMessage clickAction: aBlock.
	
	^ self
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> actors [
	"Returns the collection of actors in the sequence diagram"

	^ actors values
]

{ #category : 'building' }
MicroUMLSDAstBuilder >> build [
	"Builds the sequence diagram from the constructed AST"
	(MicroUMLSequenceDiagram from: self) build
]

{ #category : 'initialization' }
MicroUMLSDAstBuilder >> initialize [ 
	"Initialises the builder with empty collections for actors and messages"

	actors := OrderedDictionary new.
	messages := OrderedCollection new
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> lastMethod: meth [
	"Sets the last method used in a message for the builder"
	lastMethod := meth
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> messages [
	"Returns the collection of messages exchanged between actors in the sequence diagram"

	^ messages 
]
