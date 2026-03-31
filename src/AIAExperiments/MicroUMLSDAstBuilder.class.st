"
# Class Comment for MicroUMLSDAstBuilder

The `MicroUMLSDAstBuilder` class is designed to facilitate the creation and manipulation of sequence diagrams in a fluid and expressive manner. It provides a builder pattern for constructing sequence diagrams by allowing the addition of actors and messages in a concise syntax.

## Key Features

- **Fluid Syntax**: Allows the creation of sequence diagrams using a fluid syntax, making the code more readable and expressive.
- **Actor Management**: Supports the addition of actors to the sequence diagram and manages their relationships.
- **Message Handling**: Facilitates the addition of messages between actors, including call and return messages.
- **Initialization**: Provides methods to initialize the builder with empty collections for actors and messages.

## Usage Example

```st
MicroUMLSDAstBuilder new
    , 'Playground'
    , 'Login System'
    , 'Database'
    & 'Playground' -> 'Login System' => 'call'
    & 'Login System' -> 'Database' => 'verify'
    & 'Database' -> 'Playground' --> ''
```

This example demonstrates how to create a sequence diagram with three actors (`Playground`, `Login System`, and `Database`) and define the messages exchanged between them. The `&` operator is used to set the source actor, the `->` operator is used to set the target actor, and the `=>` and `-->` operators are used to add call and return messages, respectively.

## Design Decisions

- **Fluid Syntax**: The class is designed to support a fluid syntax for scripting, making it suitable for interactive use in the Playground.
- **Builder Pattern**: The class follows the builder pattern, providing methods to build and install the sequence diagram.
- **Extensibility**: The class can be extended by using different builder enhancers to customise the building process.

## Future Considerations

- **API Alignment**: There is a need to revisit and align the APIs with the class default values to reduce the number of conversions required.
- **Builder Revisit**: The necessity of fluid class builders should be revisited to ensure they meet the evolving requirements of the system.

"
Class {
	#name : 'MicroUMLSDAstBuilder',
	#superclass : 'Object',
	#instVars : [
		'actors',
		'messages',
		'messageFrom',
		'messageTo'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder class >> , aString [
	"Creates a new instance of MicroUMLSDAstBuilder and concatenates it with a string"
    ^ self new , aString
]

{ #category : 'examples' }
MicroUMLSDAstBuilder class >> example [
	"MicroUMLSDAstBuilder
    , 'Playground'
    , 'Login System'
    , 'Database'
    & 'Playground' -> 'Login System' => 'call'
    & 'Login System' -> 'Database' => 'verify'
    & 'Database' -> 'Playground' --> ''"
]

{ #category : 'logical operations' }
MicroUMLSDAstBuilder >> & from [
	"Sets the source actor for the next message in the sequence diagram."
    messageFrom := from.
    messageTo := nil.
    ^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> , aString [
	"Adds a new actor to the sequence diagram."
	 messages ifNotEmpty: [ ^ self error: 'No new usage of `,` after an `&`' ].
	 (actors includesKey: aString) ifTrue: [ ^ self ].
    actors 
        add: aString -> (MicroUMLSDActor new name: aString; index: actors size + 1 ).
   
    ^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> --> aString [
	"Adds a return message to the sequence diagram"
	messages add: (MicroUMLSDMessages new
			 description: aString;
			 fromActor: (actors at: messageFrom);
			 toActor: (actors at: messageTo );
			 messageType: #return;
			 yourself).
	^ self
]

{ #category : 'logical operations' }
MicroUMLSDAstBuilder >> -> to [
	"Sets the target actor for the next message in the sequence diagram"
    messageTo := to .
    ^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> => aString [
	"Adds a message to the sequence diagram"
	| messageType |
	messageType := #call.
	messageTo ifNil: [ messageType := #internal. messageTo := messageFrom ].
   messages add: (MicroUMLSDMessages new
			 description: aString;
			 fromActor: (actors at: messageFrom);
			 toActor: (actors at: messageTo );
			 messageType: messageType;
			 yourself).
    ^ self
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> actors [
	"Returns the collection of actors in the sequence diagram"
	^ actors values
]

{ #category : 'initialization' }
MicroUMLSDAstBuilder >> initialize [ 
	"Initialises the builder with empty collections for actors and messages"
	actors := OrderedDictionary new.
	messages := OrderedCollection new
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> messages [
	"Returns the collection of messages in the sequence diagram"
	^ messages 
]
