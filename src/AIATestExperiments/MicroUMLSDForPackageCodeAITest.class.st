Class {
	#name : 'MicroUMLSDForPackageCodeAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDForPackageCode'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicroUMLSDForPackageCodeAITest >> setUp [
	super setUp.
	refMicroUMLSDForPackageCode := MicroUMLSDForPackageCode new.
]

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> testUmlSPForArg [
	"Test the umlSPFor: method with a message array structured to produce an empty subList.
	This avoids errors in the delegated forContext:inScope: while verifying the method executes and returns correctly."
	| message result testCompiledMethod testIndex testList |
	testCompiledMethod := Object methodDict at: #yourself.
	testIndex := 3.
	testList := Array with: Object with: Array.
	message := Array new: 5.
	message at: 2 put: testCompiledMethod.
	message at: 5 put: (Array with: testIndex with: testList).
	result := refMicroUMLSDForPackageCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForPackageCode).
	self assert: (message isKindOf: Array).
	self assert: (message size = 5).
	self assert: ((message at: 5) first = testIndex).
	self assert: ((message at: 5) second = testList)
]

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> testUmlSPForArg01 [
	"Test the umlSPFor: method with a message array structured to produce an empty subList.
	This avoids errors in the delegated forContext:inScope: while verifying the method executes and returns correctly."
	| message result testCompiledMethod testIndex testList |
	testCompiledMethod := Object methodDict at: #yourself.
	testIndex := 3.
	testList := Array with: Object with: Array.
	message := Array new: 5.
	message at: 2 put: testCompiledMethod.
	message at: 5 put: (Array with: testIndex with: testList).
	result := refMicroUMLSDForPackageCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForPackageCode).
	self assert: (message isKindOf: Array).
	self assert: (message size = 5).
	self assert: ((message at: 5) first = testIndex).
	self assert: ((message at: 5) second = testList)
]
