Class {
	#name : 'AilienApiTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAilienApi'
	],
	#category : 'AIActions-Tests-AIApi-Tests ',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests '
}

{ #category : 'running' }
AilienApiTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	refAilienApi := AilienApi new.
]

{ #category : 'running' }
AilienApiTest >> testAssistant [
	refAilienApi assistant: 'Killroy' .
	self 
		assert: refAilienApi history first 
		equals: 'assistant' -> 'Killroy'
]

{ #category : 'running' }
AilienApiTest >> testHistory [
	self 
		assert: refAilienApi history class
		equals: OrderedCollection 
]

{ #category : 'running' }
AilienApiTest >> testJsonHistory [
	| res |
	refAilienApi user: 'Jim'.
	res := refAilienApi jsonHistory first.
	self 
		assert: (res at: 'role')
		equals: 'user'. 
	self 
		assert: (res at: 'content')
		equals: 'Jim' 
]

{ #category : 'tests' }
AilienApiTest >> testLoadResonse [
	self 
		should: [refAilienApi loadResponse ] 
		raise: SubclassResponsibility.
]

{ #category : 'running' }
AilienApiTest >> testModel [
	refAilienApi model: 'Joe' .
	self 
		assert: refAilienApi model 
		equals: 'Joe'
]

{ #category : 'running' }
AilienApiTest >> testPrompt [
	
	refAilienApi prompt: 'Banana'.
	self 
		assert: refAilienApi history first 
		equals: 'user' -> 'Banana' 
]

{ #category : 'running' }
AilienApiTest >> testSystem [
	refAilienApi system: 'Joe' .
	self 
		assert: refAilienApi history first 
		equals: 'system' -> 'Joe'
]

{ #category : 'running' }
AilienApiTest >> testSystemError [
	
	self assert:  refAilienApi system equals: nil.
	
	refAilienApi user: 'Bill'.
	self 
		assert: refAilienApi system 
		equals: nil
]

{ #category : 'running' }
AilienApiTest >> testSystemSet [
	
	refAilienApi system: 'Bill'.
	self 
		assert: refAilienApi system 
		equals: 'Bill'
]

{ #category : 'running' }
AilienApiTest >> testUser [
	
	refAilienApi user: 'Bogus'.
	self 
		assert: refAilienApi history first 
		equals: 'user' -> 'Bogus'
]

{ #category : 'running' }
AilienApiTest >> testUserAndSystem [
	
	refAilienApi system: 'What'.
	refAilienApi user: 'Bogus'.
	self 
		assert: refAilienApi history first 
		equals: 'user' -> '[BACKGROUND] What. [QUESTION] Bogus' 
]
