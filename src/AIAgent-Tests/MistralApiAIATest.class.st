Class {
	#name : 'MistralApiAIATest',
	#superclass : 'TestCase',
	#instVars : [
		'mistralApi'
	],
	#category : 'AIAgent-Tests-AIAPI-Tests',
	#package : 'AIAgent-Tests',
	#tag : 'AIAPI-Tests'
}

{ #category : 'running' }
MistralApiAIATest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	mistralApi := MistralApi new.
]

{ #category : 'tests' }
MistralApiAIATest >> testGetResponse [
	
	mistralApi 
		system: 'Killroy was here';
		prompt:  'Who was here';
		getResponse.
	self assert: (mistralApi response includesSubstring: 'Killroy')
]
