"
# Class Comment for MicroUMLSDMessages

The `MicroUMLSDMessages` class is designed to represent messages in a sequence diagram within the MicroUML framework. It encapsulates the properties and behaviors necessary to draw and manage messages between actors in a sequence diagram.

## Responsibilities

- **Message Properties**: Manages the description, sender, receiver, y-coordinate, and type of the message.
- **Drawing**: Provides methods to draw the message line and label based on the message type and description.

## Usage Example

```st
""Create a new message""
message := MicroUMLSDMessages new
    description: 'Request Data';
    fromActor: (MicroUMLSDActor new x: 50);
    toActor: (MicroUMLSDActor new x: 150);
    y: 100;
    messageType: #call;
    yourself.

""Draw the message""
canvas := RSCanvas new.
canvas addAll: message draw.
canvas open
```

This example demonstrates how to create a new message and draw it on a canvas. The `MicroUMLSDMessages` class is used to set the properties of the message and then the `draw` method is called to render the message on the canvas.
"
Class {
	#name : 'MicroUMLSDMessages',
	#superclass : 'Object',
	#instVars : [
		'description',
		'fromActor',
		'toActor',
		'y',
		'messageType'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'accessing' }
MicroUMLSDMessages class >> bottomMargin [
	"Returns the bottom margin for the sequence diagram"
    ^ 15
]

{ #category : 'accessing' }
MicroUMLSDMessages class >> messageGap [
	"Returns the gap between messages in the sequence diagram"
    ^ 40
]

{ #category : 'accessing' }
MicroUMLSDMessages class >> topMargin [
	"Returns the top margin for the sequence diagram"
    ^ 15
]

{ #category : 'accessing' }
MicroUMLSDMessages >> description [
	"Returns the description of the message"

	^ description
]

{ #category : 'accessing' }
MicroUMLSDMessages >> description: anObject [
	"Sets the description of the message"

	description := anObject
]

{ #category : 'drawing' }
MicroUMLSDMessages >> draw [
	"Draws a message line and label based on the message type and description"
    | line labels|
    line := RSPolyline new
        color: Color black;
        markerEnd: (RSShapeFactory arrow size: 10; color: Color black) asMarker;
        yourself.
	 messageType = #call ifTrue: [ self drawCall: line ].
    messageType = #return ifTrue: [ self drawReturn: line ].
    messageType = #internal ifTrue: [ self drawInternal: line ].
	
    labels := self 
				drawLabel: description 
				at: (fromActor x + toActor x / 2) @ (y - 10).
    ^ { line } , labels
]

{ #category : 'drawing' }
MicroUMLSDMessages >> drawCall: line [
    | offset |
    offset := (fromActor x > toActor x) ifTrue: [ 5 ] ifFalse: [ -5 ].
    line controlPoints: { fromActor x @ y. (toActor x + offset) @ y }
]

{ #category : 'drawing' }
MicroUMLSDMessages >> drawInternal: line [
    | x |
    x := fromActor x.
    line controlPoints: { 
        x @ y. 
        (x + 25) @ y. 
        (x + 25) @ (y + 15). 
        (x + 5) @ (y + 15) 
    }
]

{ #category : 'as yet unclassified' }
MicroUMLSDMessages >> drawLabel: aString at: aPoint [
	"Draws a label at the given point splitting multiline text into separate positioned labels"
    | lines lineHeight lineAll|
    lines := aString lines.
    lines size <= 1 ifTrue: [
        ^ {RSLabel new text: aString; translateTo: aPoint; yourself}  ].
    
    lineHeight := 18.
    lineAll := lines collectWithIndex: [ :line :i |
        RSLabel new
            text: line;
            translateTo: aPoint x @ (aPoint y + ((i - 1) * lineHeight));
            yourself ].
	^ lineAll 
]

{ #category : 'drawing' }
MicroUMLSDMessages >> drawReturn: line [
    | offset |
    offset := (fromActor x > toActor x) ifTrue: [ 5 ] ifFalse: [ -5 ].
    line 
        controlPoints: { fromActor x @ y. (toActor x + offset) @ y };
        dashArray: #(5 5)
]

{ #category : 'accessing' }
MicroUMLSDMessages >> fromActor [
	"Returns the actor from which the message is sent"

	^ fromActor
]

{ #category : 'accessing' }
MicroUMLSDMessages >> fromActor: anObject [
	"Sets the actor from which the message is sent"

	fromActor := anObject
]

{ #category : 'accessing' }
MicroUMLSDMessages >> messageType [
	"Returns the type of the message"

	^ messageType
]

{ #category : 'accessing' }
MicroUMLSDMessages >> messageType: anObject [
	"Sets the type of the message"

	messageType := anObject
]

{ #category : 'printing' }
MicroUMLSDMessages >> printOn: stream [
	stream << '[ ' << fromActor printString << ' -> ' << toActor printString << ' ' << description 
		<< ' (' << messageType << ') ]'
]

{ #category : 'accessing' }
MicroUMLSDMessages >> toActor [
	"Returns the actor to which the message is sent"

	^ toActor
]

{ #category : 'accessing' }
MicroUMLSDMessages >> toActor: anObject [
	"Sets the actor to which the message is sent"

	toActor := anObject
]

{ #category : 'accessing' }
MicroUMLSDMessages >> y [
	"Returns the y-coordinate of the message"

	^ y
]

{ #category : 'accessing' }
MicroUMLSDMessages >> y: anObject [
	"Sets the y-coordinate of the message in the sequence diagram"

	y := anObject
]
