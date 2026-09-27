Class {
	#name : 'MistralApiTest',
	#superclass : 'TestCase',
	#instVars : [
		'refMistralApi'
	],
	#category : 'AIAZipArchive-Obsolete-tests',
	#package : 'AIAZipArchive',
	#tag : 'Obsolete-tests'
}

{ #category : 'running' }
MistralApiTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	refMistralApi := MistralApi new.
]

{ #category : 'tests' }
MistralApiTest >> testFakeLoadResponse [
	refMistralApi history add: 'jojo' -> 'foo bar bad'.
	refMistralApi loadResponse.
	self assert: (refMistralApi history second value beginsWith: 'Error bla bla: ') 
]

{ #category : 'tests' }
MistralApiTest >> testLoadResponse [
	refMistralApi history add: 'user' -> 'Code is good'.
	refMistralApi loadResponse.
	self deny: (refMistralApi history second value beginsWith: 'Error bla bla: ')
]
