Class {
	#name : 'AIASourceCodeBuilderClassAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIASourceCodeBuilder'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIASourceCodeBuilderClassAITest >> setUp [
	super setUp.
	refAIASourceCodeBuilder := AIASourceCodeBuilder class new.
]
