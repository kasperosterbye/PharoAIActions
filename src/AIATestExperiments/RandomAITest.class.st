Class {
	#name : 'RandomAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refRandom'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
RandomAITest >> setUp [
	super setUp.
	refRandom := Random new.
]
