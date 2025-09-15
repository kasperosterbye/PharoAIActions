Class {
	#name : 'OllamaApiTest',
	#superclass : 'TestCase',
	#instVars : [
		'refOllamaApi'
	],
	#category : 'AIActions-Tests-AIApi-Tests ',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests '
}

{ #category : 'running' }
OllamaApiTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	refOllamaApi := OllamaApi new.
]

{ #category : 'tests' }
OllamaApiTest >> testFakeLoadResponse [
	refOllamaApi history add: 'jojo' -> 'foo bar bad'.
	refOllamaApi loadResponse.
	self assert: (refOllamaApi history second value beginsWith: 'Error bla bla: ') 
]

{ #category : 'tests' }
OllamaApiTest >> testLoadResponse [
	refOllamaApi history add: 'user' -> 'Code is good'.
	refOllamaApi loadResponse.
	self deny: (refOllamaApi history second value beginsWith: 'Error bla bla: ')
]
