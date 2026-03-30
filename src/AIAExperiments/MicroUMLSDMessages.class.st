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
    | line label|
    line := RSPolyline new
        color: Color black;
        markerEnd: (RSShapeFactory arrow size: 10) asMarker;
        yourself.
	 messageType = #call ifTrue: [ self drawCall: line ].
    messageType = #return ifTrue: [ self drawReturn: line ].
	
    label := RSLabel new
        text: description;
        translateTo: (fromActor x + toActor x / 2) @ (y - 15).
    ^ Array with: line with: label
]

{ #category : 'drawing' }
MicroUMLSDMessages >> drawCall: line [
	"Draws a call message line from the sender to the receiver"
    line controlPoints: { fromActor x @ y. (toActor x - 5) @ y }
]

{ #category : 'drawing' }
MicroUMLSDMessages >> drawReturn: line [
	"Draws a return message line with dashed style from the receiver to the sender"
    line 
		controlPoints: { fromActor x @ y. (toActor x + 5) @ y };
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
