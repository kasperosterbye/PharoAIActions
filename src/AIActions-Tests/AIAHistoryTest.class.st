Class {
	#name : 'AIAHistoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAHistory'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'running' }
AIAHistoryTest >> setUp [
	super setUp.
	refAIAHistory := AIAHistory new.
]
