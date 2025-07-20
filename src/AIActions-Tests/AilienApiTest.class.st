Class {
	#name : 'AilienApiTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIAPI-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIAPI-Tests'
}

{ #category : 'tests' }
AilienApiTest >> testInitilize [ 
	| ailien |
	ailien := AilienApi new.
	self assert: ailien model equals: ''.
	self assert: ailien system equals: ''.
	self assert: ailien prompt equals: ''.
	self assert: ailien response equals: ''.
]

{ #category : 'tests' }
AilienApiTest >> testModels [
	self should: [ AilienApi models ] raise: SubclassResponsibility
]
