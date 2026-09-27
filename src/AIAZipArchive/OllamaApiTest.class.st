Class {
	#name : 'OllamaApiTest',
	#superclass : 'TestCase',
	#instVars : [
		'refOllamaApi'
	],
	#category : 'AIAZipArchive-Obsolete-tests',
	#package : 'AIAZipArchive',
	#tag : 'Obsolete-tests'
}

{ #category : 'running' }
OllamaApiTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	refOllamaApi := OllamaApi new.
]

{ #category : 'nil' }
OllamaApiTest >> testFakeLoadResponse [
	refOllamaApi history add: 'jojo' -> 'foo bar bad'.
	refOllamaApi loadResponse.
	self deny: (refOllamaApi history second value beginsWith: 'Error bla bla: ') 
]

{ #category : 'tests' }
OllamaApiTest >> testLoadResponse [
	refOllamaApi history add: 'user' -> 'Code is good'.
	refOllamaApi loadResponse.
	self deny: (refOllamaApi history second value beginsWith: 'Error bla bla: ')
]
