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
AIASourceCodeBuilderTest >> testClassHeaderForSuperOn [
	|  class1 class2  stream string |
	class1 := AIAPackageComment.
	class2 := class1 superclass.
	stream := WriteStream on: ''.
	builder classHeaderFor: class1 super: class2 on: stream.
	string := stream contents.
	self assert: (string  includesSubstring: 'AIABuilder << #AIACommentBuilding').
	self assert: (string  includesSubstring: 
		'AIABuilder class << #AIACommentBuilding class').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testClassesInPackage [
	| res |
	builder classesInPackage: (PackageOrganizer default packageNamed: 'AIActions-Tests'). 
	res := builder response contents.
	self assert: (res  includesSubstring: '## Class: AIAMethodCommentTest').
	self assert: (res  includesSubstring: 'foo := 88.').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testFor [
	| res |
	builder for: {'AIActions-Tests'}.
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
	builder forMethod: (builder class >> #initialize).
	res := builder response contents.
	self assert: (res  includesSubstring: '## Calling methods:').
	self assert: (res  includesSubstring: 'AIACommentBuilding >> #initialize').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testForSuperClassesOf [
	| stream  |
	stream := builder forSuperClassesOf: AIAPackageComment.
	self assert: (stream  includesSubstring: '## Superclass: AIACommentBuilding f').
	self assert: (stream  includesSubstring: '### AIACommentBuilding has meta class: ').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testForTagIn [
	"Tests the retrieval of classes within a specific tag in a given package, verifying correct class extraction and content inclusion"
	| res |
	builder forTag: 'AIApi' in: 'AIActions'.
	res := builder response contents.
	self assert: (res  includesSubstring: '## Class: AilienApi').
	self assert: (res  includesSubstring: '## Class: AIAHistory').
	self assert: (res  includesSubstring: '## Class: MistralApiWithTools').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testForWildcard [
	| res |
	builder forWildcard: '*AIAc'.
	res := builder response contents.
	self assert: (res  includesSubstring: '## Class: AIAMethodCommentTest').
	self assert: (res  includesSubstring: 'foo := 88.').
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
	self assert: (res  includesSubstring: 'AIASourceCodeBuilder >> #forMethod:').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testclassHeaderForSuperOn [
	|method stream  string |
	method := AIASourceCodeBuilder >> #methodNameAndCommentFor:in:.
	stream := WriteStream on: ''.
	builder methodNameAndCommentFor: method in: stream.
	string := stream contents.
	self assert: (string  includesSubstring: 
			'Method: AIASourceCodeBuilder>>#methodNameAndCommentFor:in:').
	self assert: (string  includesSubstring: 
		'comment:').
]

{ #category : 'tests' }
AIASourceCodeBuilderTest >> testmethodNameAndCommentForIn [
	|method stream  string |
	method := AIASourceCodeBuilder >> #methodNameAndCommentFor:in:.
	stream := WriteStream on: ''.
	builder methodNameAndCommentFor: method in: stream.
	string := stream contents.
	self assert: (string  includesSubstring: 
			'Method: AIASourceCodeBuilder>>#methodNameAndCommentFor:in:').
	self assert: (string  includesSubstring: 
		'comment:').
]
