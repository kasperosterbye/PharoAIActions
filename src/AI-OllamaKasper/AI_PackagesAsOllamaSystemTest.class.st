Class {
	#name : 'AI_PackagesAsOllamaSystemTest',
	#superclass : 'TestCase',
	#instVars : [
		'killRoy'
	],
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'tests' }
AI_PackagesAsOllamaSystemTest >> testClassesInPackage [
	"Tests that classesInSamePackageAs: writes correct data for a known class"
	| result testee knownClass packageClasses classNames |
	result := WriteStream on: ''.
	testee := AI_PackagesAsOllamaSystem new.
	testee instVarNamed: #responce put: result.

	knownClass := self class.
	testee classesInSamePackageAs: knownClass.

	packageClasses := knownClass package classes.
	classNames := packageClasses asArray collect: #name .

	self assert: classNames isNotEmpty.
	classNames do: [ :name |
		self assert: (result contents includesSubstring: name) ].
]

{ #category : 'tests' }
AI_PackagesAsOllamaSystemTest >> testFor [
	"Test that the for: method includes expected class names"

	| generator result |
	generator := AI_PackagesAsOllamaSystem new.
	result := generator for: { 'AI-OllamaKasper' }.

	self assert: (result includesSubstring: '## Class: AI_PackagesAsOllamaSystem').
]

{ #category : 'tests' }
AI_PackagesAsOllamaSystemTest >> testInstanceVariablesFor [
	"Tests that instanceVariablesFor: writes instance variable names correctly"
	| result |
	result := WriteStream on: ''.
	"Create an instance with a redirected response stream, so instanceVariablesFor: appends its output to result."
	AI_PackagesAsOllamaSystem new
		instVarNamed: #responce put: result;
		instanceVariablesFor: self class.

	"Now test the output"
	self assert: (result contents includesSubstring: '### Instance variables for AI_PackagesAsOllamaSystemTest:').
	self assert: (result contents includesSubstring: 'killRoy').
]

{ #category : 'tests' }
AI_PackagesAsOllamaSystemTest >> testMethodsFor [
	"Tests that methodsFor: writes method selectors correctly"
	| result methodNames |
	result := WriteStream on: ''.
	methodNames := self class methodDictionary keys collect: #asString.

	AI_PackagesAsOllamaSystem new
		instVarNamed: #responce put: result;
		methodsFor: self class.

	self assert: (result contents includesSubstring: '### Methods for AI_PackagesAsOllamaSystemTest:').
	self assert: methodNames isNotEmpty.
	methodNames do: [ :name |
		self assert: (result contents includesSubstring: name) ].
]
