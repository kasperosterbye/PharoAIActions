Class {
	#name : 'AilienApiClassTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAilienApiClass'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'running' }
AilienApiClassTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	refAilienApiClass initialize.
	refAilienApiClass := AilienApi.
]

{ #category : 'tests' }
AilienApiClassTest >> testDefaultModel [
	self 
		assert: refAilienApiClass defaultModel  
		equals: ''
]

{ #category : 'tests' }
AilienApiClassTest >> testDefaultModelSet [
self 
		should: [refAilienApiClass defaultModel: 'billy'] 
		raise: SubclassResponsibility.
]

{ #category : 'tests' }
AilienApiClassTest >> testModelNames [
	self 
		should: [refAilienApiClass modelNames] 
		raise: SubclassResponsibility
]

{ #category : 'tests' }
AilienApiClassTest >> testNoOfModels [
	self 
		should: [refAilienApiClass noOfModels] 
		raise: SubclassResponsibility
]

{ #category : 'tests' }
AilienApiClassTest >> testNodelNames [
	"Verifies that the default string representation of the AilienApi instance matches the default string representation of the AileinProvider instance."
	self 
		assert: refAilienApiClass default asString 
		equals: AileinProvider provider default asString
]
