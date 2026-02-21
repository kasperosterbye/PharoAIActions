Class {
	#name : 'StringAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refString'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
StringAITest >> setUp [
	super setUp.
	refString := String new.
]
