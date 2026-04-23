Class {
	#name : 'Exp5AITest',
	#superclass : 'TestCase',
	#instVars : [
		'refExp5'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
Exp5AITest >> setUp [
	super setUp.
	refExp5 := Exp5 new.
]
