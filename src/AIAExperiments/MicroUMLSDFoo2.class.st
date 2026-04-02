Class {
	#name : 'MicroUMLSDFoo2',
	#superclass : 'Object',
	#instVars : [
		'tally'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'experiments' }
MicroUMLSDFoo2 class >> fabbe: a [
	| ccc |
	ccc := 12345 + a.
	^ ccc
]
