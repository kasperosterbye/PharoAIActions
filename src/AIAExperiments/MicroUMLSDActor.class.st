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
    ^ 20 
]

{ #category : 'accessing' }
MicroUMLSDActor class >> boxHeight [
    ^ 40

]

{ #category : 'accessing' }
MicroUMLSDActor class >> boxPadding [
    ^ 10 
]

{ #category : 'drawing' }
MicroUMLSDActor >> draw [
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

	^ index
]

{ #category : 'accessing' }
MicroUMLSDActor >> index: anObject [

	index := anObject
]

{ #category : 'accessing' }
MicroUMLSDActor >> name [

	^ name
]

{ #category : 'accessing' }
MicroUMLSDActor >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
MicroUMLSDActor >> width [
	width ifNil: [ width := (RSLabel new text: name) textWidth + (self class boxPadding * 2) ].
	^ width
]

{ #category : 'accessing' }
MicroUMLSDActor >> width: anObject [

	width := anObject
]

{ #category : 'accessing' }
MicroUMLSDActor >> x [

	^ x
]

{ #category : 'accessing' }
MicroUMLSDActor >> x: anObject [

	x := anObject
]
