Class {
	#name : 'AilienApiClassTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAilienApiClass'
	],
	#category : 'AIAZipArchive-Obsolete-tests',
	#package : 'AIAZipArchive',
	#tag : 'Obsolete-tests'
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
	"Verifies that the default model of the AilienApi instance is an empty string"
	self 
		assert: refAilienApiClass defaultModel  
		equals: ''
]

{ #category : 'tests' }
AilienApiClassTest >> testDefaultModelSet [
	"Verifies that setting a default model raises a SubclassResponsibility error, ensuring the method is properly overridden in subclasses."
self 
		should: [refAilienApiClass defaultModel: 'billy'] 
		raise: SubclassResponsibility.
]

{ #category : 'tests' }
AilienApiClassTest >> testModelNames [
	"Verifies that the modelNames method raises a SubclassResponsibility error, ensuring it is properly overridden in subclasses."
	self 
		should: [refAilienApiClass modelNames] 
		raise: SubclassResponsibility
]

{ #category : 'tests' }
AilienApiClassTest >> testNoOfModels [
	"Verifies that the noOfModels method raises a SubclassResponsibility error ensuring it is properly overridden in subclasses"
	self 
		should: [refAilienApiClass noOfModels] 
		raise: SubclassResponsibility
]

{ #category : 'tests' }
AilienApiClassTest >> testNodelNames [
	"Verifies that the default string representation of the AilienApi instance matches the default string representation of the AileinProvider instance."
	self 
		assert: refAilienApiClass provider asString 
		equals: AilienApi provider asString
]
