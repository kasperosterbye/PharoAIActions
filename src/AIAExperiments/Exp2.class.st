Class {
	#name : 'Exp2',
	#superclass : 'Object',
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'experiments' }
Exp2 >> exp2Method1: a [
	| ccc |
	ccc := 12345 + a.
	^ ccc
]
