Class {
	#name : 'AilienApiClassAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refAilienApi'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AilienApiClassAITest >> setUp [
	super setUp.
	refAilienApi := AilienApi class new.
]
