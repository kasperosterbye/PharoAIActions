Class {
	#name : 'MicroUMLSDFoo1',
	#superclass : 'Object',
	#instVars : [
		'tally'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'experiments' }
MicroUMLSDFoo1 class >> fibbe: a [
	| bbb |
	bbb := MicroUMLSDFoo2 fabbe: a * 50.
	bbb := bbb + (MicroUMLSDFoo2 fabbe: 1000).
	^ bbb
]
