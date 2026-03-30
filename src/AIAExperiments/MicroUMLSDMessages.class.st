"
Kilroy forgot to comment
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
    ^ 40
]

{ #category : 'accessing' }
MicroUMLSDMessages class >> messageGap [
    ^ 40
]

{ #category : 'accessing' }
MicroUMLSDMessages class >> topMargin [
    ^ 60

]

{ #category : 'accessing' }
MicroUMLSDMessages >> description [

	^ description
]

{ #category : 'accessing' }
MicroUMLSDMessages >> description: anObject [

	description := anObject
]

{ #category : 'drawing' }
MicroUMLSDMessages >> draw [
    | line label cp|
    messageType = #call ifTrue: [ cp := { fromActor x @ y. (toActor x - 5) @ y } ].
    messageType = #return ifTrue: [ cp := { fromActor x @ y. (toActor x + 5) @ y } ].
    line := RSPolyline new
        controlPoints: cp;
        color: Color black;
        markerEnd: (RSShapeFactory arrow size: 10) asMarker;
        yourself.
    label := RSLabel new
        text: description;
        translateTo: (fromActor x + toActor x / 2) @ (y - 15).
    ^ Array with: line with: label
]

{ #category : 'accessing' }
MicroUMLSDMessages >> fromActor [

	^ fromActor
]

{ #category : 'accessing' }
MicroUMLSDMessages >> fromActor: anObject [

	fromActor := anObject
]

{ #category : 'accessing' }
MicroUMLSDMessages >> messageType [

	^ messageType
]

{ #category : 'accessing' }
MicroUMLSDMessages >> messageType: anObject [

	messageType := anObject
]

{ #category : 'accessing' }
MicroUMLSDMessages >> toActor [

	^ toActor
]

{ #category : 'accessing' }
MicroUMLSDMessages >> toActor: anObject [

	toActor := anObject
]

{ #category : 'accessing' }
MicroUMLSDMessages >> y [

	^ y
]

{ #category : 'accessing' }
MicroUMLSDMessages >> y: anObject [

	y := anObject
]
