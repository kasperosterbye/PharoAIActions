Class {
	#name : 'WideStringAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refWideString'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
WideStringAITest >> setUp [
	super setUp.
	refWideString := WideString new.
]

{ #category : 'Failed generated test' }
WideStringAITest >> testAsFourCode [
	self fail: 'Test code could not be generated' 

"cannot resolve 'generativelanguage.googleapis.com'"
]
