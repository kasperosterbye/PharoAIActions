Class {
	#name : 'Exp3',
	#superclass : 'Object',
	#category : 'AIAExperiments-MicroURLMisc',
	#package : 'AIAExperiments',
	#tag : 'MicroURLMisc'
}

{ #category : 'as yet unclassified' }
Exp3 >> exp3Method1: a [
	^ 12345 + a.
]

{ #category : 'as yet unclassified' }
Exp3 >> exp3Method2 [
	^ Exp4 new exp4method1 + 25.
]
