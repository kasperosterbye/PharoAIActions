Class {
	#name : 'ClaudeApiTest',
	#superclass : 'TestCase',
	#instVars : [
		'refClaudeApi'
	],
	#category : 'AIAZipArchive-Obsolete-tests',
	#package : 'AIAZipArchive',
	#tag : 'Obsolete-tests'
}

{ #category : 'running' }
ClaudeApiTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	refClaudeApi := ClaudeApi new.
]

{ #category : 'tests' }
ClaudeApiTest >> testFakeLoadResponse [
	refClaudeApi history add: 'jojo' -> 'foo bar bad'.
	refClaudeApi loadResponse.
	self assert: (refClaudeApi history second value beginsWith: 'Error bla bla: ') 
]

{ #category : 'tests' }
ClaudeApiTest >> testLoadResponse [
	refClaudeApi history add: 'user' -> 'Code is good'.
	refClaudeApi loadResponse.
	self deny: (refClaudeApi  history second value beginsWith: 'Error bla bla: ')
]
