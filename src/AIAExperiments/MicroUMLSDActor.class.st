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

{ #category : 'as yet unclassified' }
MicroUMLSDActor class >> actorGap [
    ^ 80 
]

{ #category : 'as yet unclassified' }
MicroUMLSDActor class >> boxHeight [
    ^ 40

]

{ #category : 'as yet unclassified' }
MicroUMLSDActor class >> boxPadding [
    ^ 20 
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
