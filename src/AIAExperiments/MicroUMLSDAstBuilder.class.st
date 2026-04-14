"
# Class Comment for MicroUMLSDAstBuilder

The `MicroUMLSDAstBuilder` class is responsible for constructing abstract syntax trees (ASTs) for sequence diagrams in the MicroUML framework. It provides a fluid syntax for defining actors and messages within a sequence diagram, allowing for a concise and readable representation of interactions between actors.

## Key Features

- **Fluid Syntax**: Allows for the creation of sequence diagrams using a fluid syntax, making the code more readable and maintainable.
- **Actor Management**: Supports the addition of actors to the sequence diagram and manages their interactions.
- **Message Handling**: Facilitates the addition of messages between actors, including call and return messages.
- **Building and Initialization**: Provides methods for building the sequence diagram from the constructed AST and initializing the builder with empty collections for actors and messages.

## Usage Example

```st
(MicroUMLSDAstBuilder
    , 'Playground'
    , 'Login System'
    , 'Database'
    & 'Playground' -> 'Login System' => 'call'
    & 'Login System' -> 'Database' => 'verify'
    & 'Database' -> 'Playground' --> '')
    build
```

This example demonstrates how to create a sequence diagram with three actors: `Playground`, `Login System`, and `Database`. Messages are defined between these actors, including a call from `Playground` to `Login System`, a verification call from `Login System` to `Database`, and a return message from `Database` to `Playground`.

The `build` method is used to construct the sequence diagram from the defined actors and messages, returning the constructed diagram for further inspection or use.
"
Class {
	#name : 'MicroUMLSDAstBuilder',
	#superclass : 'Object',
	#instVars : [
		'actors',
		'messages',
		'messageFrom',
		'messageTo',
		'lastMethod'
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
	"Example demonstrating the creation and linking of UML elements"

	(MicroUMLSDAstBuilder
    , 'Playground'
    , 'Login System'
    , 'Database'
    & 'Playground' -> 'Login System' => 'call'
    & 'Login System' -> 'Database' => ('verify', String lf, 'Now')
    & 'Database' -> 'Playground' --> '')
	build
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
	| messageType from to |
	messageType := #return.
	from := actors at: messageFrom.
	to := actors at: messageTo ifAbsent: [ from ].
	from = to ifTrue: [ ^ self ].
	messages add: (MicroUMLSDMessages new
			 description: aString;
			 fromActor: from;
			 toActor: to;
			 messageType: messageType;
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
	| messageType from to|
	messageType := #call.
	from := actors at: messageFrom.
	to := actors at: messageTo ifAbsent: [ from ].
	from = to ifTrue: [ 
		aString first = $Ø
			ifTrue: [ messageType := #clickAction ]
			ifFalse: [ messageType := #internal] ].
   messages add: (MicroUMLSDMessages new
			 description: aString;
			 fromActor: from;
			 toActor: to;
			 messageType: messageType ;
			 lastMethod: lastMethod;
			 yourself).
    ^ self
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> actors [
	"Returns the collection of actors in the sequence diagram"
	^ actors values
]

{ #category : 'building' }
MicroUMLSDAstBuilder >> build [
	MicroUMLSequenceDiagram from: self
]

{ #category : 'initialization' }
MicroUMLSDAstBuilder >> initialize [ 
	"Initialises the builder with empty collections for actors and messages"
	actors := OrderedDictionary new.
	messages := OrderedCollection new
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> lastMethod: meth [
	lastMethod := meth
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> messages [
	"Returns the collection of messages in the sequence diagram"
	^ messages 
]
