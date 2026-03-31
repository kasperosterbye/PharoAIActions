"
# Class Comment for MicroUMLSDActor

The `MicroUMLSDActor` class represents an actor in a sequence diagram within the MicroUML framework. It encapsulates the properties and behaviours necessary to draw and manage an actor element, including its name, width, position, and index.

## Responsibilities

- **Drawing**: The class is responsible for drawing an actor element with a box and label, positioned at the specified x-coordinate.
- **Accessing**: It provides methods to get and set the name, width, x-coordinate, and index of the actor.

## Usage Example

```st
""Create an instance of MicroUMLSDActor""
actor := MicroUMLSDActor new
    name: 'User';
    x: 100;
    index: 1.

""Draw the actor element""
canvas := RSCanvas new.
canvas add: actor draw.
canvas open
```

## Design Decisions

- **Fluid Syntax**: The class supports fluid syntax for setting properties, making it easy to configure instances in a concise manner.
- **Drawing**: The drawing method utilises the Roassal2 framework to create composite shapes, including a box and a label, for visual representation.
- **Configuration**: The class provides class-side methods to configure the gap between actors, the height of the box, and the padding for the box, ensuring consistent layout in sequence diagrams.

## Future Enhancements

- **API Refinement**: Future revisions may focus on refining the API to align better with class default values and reduce unnecessary conversions.
- **Builder Enhancement**: The class can be extended using different builder enhancers to support additional configurations and customisations.
"
Class {
	#name : 'MicroUMLSDActor',
	#superclass : 'Object',
	#instVars : [
		'name',
		'width',
		'x',
		'index'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'accessing' }
MicroUMLSDActor class >> actorGap [
	"Returns the gap between actors in a sequence diagram"
    ^ 20 
]

{ #category : 'accessing' }
MicroUMLSDActor class >> boxHeight [
	"Returns the height of the box in a sequence diagram"
    ^ 40
]

{ #category : 'accessing' }
MicroUMLSDActor class >> boxPadding [
	"Returns the padding for the box in a sequence diagram"
    ^ 10 
]

{ #category : 'drawing' }
MicroUMLSDActor >> draw [
	"Draws an actor element with a box and label, positioned at the specified x-coordinate."
    | actorElement |
    actorElement := RSComposite new.
    actorElement shapes: {
        (RSBox new
            width: self width;
            height: self class boxHeight;
            color: Color veryLightGray;
            borderColor: Color veryDarkGray).
        (RSLabel new text: name) }.
    actorElement translateTo: x @ 0.
    ^ actorElement
]

{ #category : 'accessing' }
MicroUMLSDActor >> index [
	"Returns the index of the actor"

	^ index
]

{ #category : 'accessing' }
MicroUMLSDActor >> index: anObject [
	"Sets the index of the actor"

	index := anObject
]

{ #category : 'accessing' }
MicroUMLSDActor >> name [
	"Returns the name of the actor"

	^ name
]

{ #category : 'accessing' }
MicroUMLSDActor >> name: anObject [
	"Sets the name of the actor and calculates its width based on the label text"

	name := anObject
]

{ #category : 'accessing' }
MicroUMLSDActor >> width [
	"Sets the width of the actor and calculates it based on the label text"
	width ifNil: [ width := (RSLabel new text: name) textWidth + (self class boxPadding * 2) ].
	^ width
]

{ #category : 'accessing' }
MicroUMLSDActor >> x [
	"Returns the x-coordinate of the actor"

	^ x
]

{ #category : 'accessing' }
MicroUMLSDActor >> x: anObject [
	"Sets the x-coordinate of the actor"

	x := anObject
]
