Class {
	#name : 'AilienApiTest',
	#superclass : 'TestCase',
	#category : 'AIAgent-Tests-AIAPI-Tests',
	#package : 'AIAgent-Tests',
	#tag : 'AIAPI-Tests'
}

{ #category : 'tests' }
AilienApiTest >> testInitilize [ 
	| ailien |
	ailien := AilienApi new.
	self assert: ailien model equals: ''.
	self assert: ailien system equals: ''.
	self assert: ailien promptPrefix equals: ''.
	self assert: ailien response equals: ''.
]

{ #category : 'tests' }
AilienApiTest >> testModels [
	self should: [ AilienApi models ] raise: SubclassResponsibility
]
