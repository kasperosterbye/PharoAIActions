Class {
	#name : 'ReAddSubclassDriverAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refReAddSubclassDriver'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
ReAddSubclassDriverAITest >> setUp [
	super setUp.
	refReAddSubclassDriver := ReAddSubclassDriver new.
]
