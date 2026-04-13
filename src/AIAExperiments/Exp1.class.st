Class {
	#name : 'Exp1',
	#superclass : 'Object',
	#instVars : [
		'aaa1'
	],
	#category : 'AIAExperiments-MicroURLMisc',
	#package : 'AIAExperiments',
	#tag : 'MicroURLMisc'
}

{ #category : 'experiments' }
Exp1 class >> exp1Method1: a [
	^ self new exp1Method1: a
]

{ #category : 'experiments' }
Exp1 >> exp1Method1: a [
	| bbb |
	aaa1 := Exp2 new.
	bbb := aaa1 exp2Method1: a * 50.
	bbb := self exp1Method2: bbb.
	bbb := bbb + (aaa1 exp2Method1: 1000).
	^ bbb
]

{ #category : 'as yet unclassified' }
Exp1 >> exp1Method2: bbb [
	^ bbb + 10 
]
