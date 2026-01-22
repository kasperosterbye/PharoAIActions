Class {
	#name : 'TextStyleAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]
