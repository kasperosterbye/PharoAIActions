Class {
	#name : 'AIASourceCodeBuilderTest',
	#superclass : 'TestCase',
	#instVars : [
		'builder'
	],
	#category : 'AIActions-Tests-CommentBuilder-Tests',
	#package : 'AIActions-Tests',
	#tag : 'CommentBuilder-Tests'
}

{ #category : 'running' }
AIASourceCodeBuilderTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	builder := AIASourceCodeBuilder new
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testClassHeaderFor [
	| res |
	builder classHeaderFor: self class.
	res := builder response contents.
	self assert: (res  includesSubstring: 'slots: { #builder };').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testClassesInPackage [
	| res |
	builder classesInPackage: (PackageOrganizer default packageNamed: 'AIAgent-Tests'). 
	res := builder response contents.
	self assert: (res  includesSubstring: '## Class: AIAMethodCommentTest').
	self assert: (res  includesSubstring: 'foo := 88.').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testFor [
	| res |
	builder for: {'AIAgent-Tests'}.
	res := builder response contents.
	self assert: (res  includesSubstring: '## Class: AIAMethodCommentTest').
	self assert: (res  includesSubstring: 'foo := 88.').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testForClass [
	| res |
	builder forClass: self class.
	res := builder response contents.
	self assert: (res  includesSubstring: '#### Protocol: running').
	self assert: (res  includesSubstring: 'builder forClass: self class.').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testForClasses [
	"This test verifies the behaviour of the forClasses method in the AIASourceCodeBuilder class. It checks that the response is empty when an empty collection is passed and that the response contains specific substrings when a collection of classes is passed."
	| res |
	builder forClasses: {}.
	res := builder response contents.
	self assert: res isEmpty.
	
	builder forClasses: {self class. MistralApiTest }.
	res := builder response contents.
	self assert: (res  includesSubstring: '#### Protocol: running').
	self assert: (res  includesSubstring: 'Killroy was here').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testForMethod [
	| res |
	builder forMethod: (self class >> #setUp).
	res := builder response contents.
	self assert: (res  includesSubstring: '### Called in:').
	self assert: (res  includesSubstring: 'packageCommenter := AIAPackageComment new').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testInitialize [
	| res |
	res := builder response contents.
	self assert: res  equals: ''.
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testInstanceVariablesFor [
	| res |
	builder instanceVariablesFor: self class.
	res := builder response contents.
	self assert: (res  includesSubstring: '### Instance variables for').
	self assert: (res  includesSubstring: 'AIASourceCodeBuilderTest: ').
	self assert: (res  includesSubstring: 'builder').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testMethodsFor [
	| res |
	builder methodsFor: self class.
	res := builder response contents.
	self assert: (res  includesSubstring: '#### Protocol: running').
	self assert: (res  includesSubstring: 'AIASourceCodeBuilderTest >> #testMethodsFor ').
	self assert: (res  includesSubstring: 'includesSubstring:').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testResponse [
	| res |
	res := builder response.
	self assert: res contents isEmpty.
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testSystemForMethodUsedIn [
	| res |
	builder systemForMethod: (AIASourceCodeBuilder >> #forMethod:) 
			  usedIn: { AIAMethodComment >> #aiaComment:  }.
	res := builder response contents.
	self assert: res isNotEmpty.
	self assert: (res  includesSubstring: '## Calling methods:').
	self assert: (res  includesSubstring: 'This is a Pharo question.').
]
