Class {
	#name : 'StringClassAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refString'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
StringClassAITest >> setUp [
	super setUp.
	refString := String class new.
]
