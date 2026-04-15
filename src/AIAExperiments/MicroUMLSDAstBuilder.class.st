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
	messages add: (MicroUMLSDMessages new
		fromActor: (actors at: from);
		toActor: nil).
	actorOrMessage := messages last.
	^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> , aString [

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

    messages last toActor: (actors at: to) .
    ^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> => aString [

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
	
	actorOrMessage clickAction: aBlock.
	
	^ self
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> actors [

	^ actors values
]

{ #category : 'building' }
MicroUMLSDAstBuilder >> build [
	(MicroUMLSequenceDiagram from: self) build
]

{ #category : 'initialization' }
MicroUMLSDAstBuilder >> initialize [ 

	actors := OrderedDictionary new.
	messages := OrderedCollection new
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> lastMethod: meth [
	lastMethod := meth
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> messages [

	^ messages 
]
