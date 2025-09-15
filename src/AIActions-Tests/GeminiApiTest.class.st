Class {
	#name : 'GeminiApiTest',
	#superclass : 'TestCase',
	#instVars : [
		'refGeminiApi'
	],
	#category : 'AIActions-Tests-AIApi-Tests ',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests '
}

{ #category : 'running' }
GeminiApiTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	refGeminiApi := GeminiApi new.
]

{ #category : 'tests' }
GeminiApiTest >> testFakeLoadResponse [
	refGeminiApi history add: 'jojo' -> 'foo bar bad'.
	refGeminiApi loadResponse.
	self assert: (refGeminiApi history second value beginsWith: 'Error bla bla: ') 
]

{ #category : 'tests' }
GeminiApiTest >> testLoadResponse [
	refGeminiApi history add: 'user' -> 'Code is good'.
	refGeminiApi loadResponse.
	self deny: (refGeminiApi history second value beginsWith: 'Error bla bla: ')
]
