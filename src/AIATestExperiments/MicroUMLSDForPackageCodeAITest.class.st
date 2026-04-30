Class {
	#name : 'MicroUMLSDForPackageCodeAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDForPackageCode'
	],
	#category : 'AIATestExperiments-MicroUMLTests',
	#package : 'AIATestExperiments',
	#tag : 'MicroUMLTests'
}

{ #category : 'initialization' }
MicroUMLSDForPackageCodeAITest >> setUp [
	super setUp.
	refMicroUMLSDForPackageCode := MicroUMLSDForPackageCode new.
]

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> testAst41Title [
	"Test the ast41Title method behavior for empty and non-empty packageScope."

	| title |
	
	"Test when packageScope is empty (should return 'All packages')"
	refMicroUMLSDForPackageCode scope: ''.
	title := refMicroUMLSDForPackageCode ast41Title.
	self assert: (title = 'All packages').
	
	"Test when packageScope is not empty (should return 'Package: <scope>')"
	refMicroUMLSDForPackageCode scope: 'TestPackage'.
	title := refMicroUMLSDForPackageCode ast41Title.
	self assert: (title = 'Package: TestPackage')
]

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> testAst43BuildActors [
	| astBuilder actions actors |
	"Test 1: When packageScope is not empty, 'O' actor should be added first"
	refMicroUMLSDForPackageCode instVarNamed: #packageScope put: 'SomePackage'.
	actions := OrderedDictionary new.
	actions at: 'Object' put: Object.
	actions at: 'String' put: String.
	refMicroUMLSDForPackageCode instVarNamed: #actions put: actions.
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForPackageCode instVarNamed: #astBuilder put: astBuilder.
	refMicroUMLSDForPackageCode ast43BuildActors.
	actors := astBuilder instVarNamed: #actors.
	"Verify 'O' is the first actor, followed by the action class names"
	self assert: (actors keys asArray) equals: #('O' 'Object' 'String').
	self assert: (actors includesKey: 'O').
	self assert: (actors keys first) equals: 'O'.

	"Test 2: When packageScope is empty, 'O' actor should NOT be added"
	refMicroUMLSDForPackageCode instVarNamed: #packageScope put: ''.
	actions := OrderedDictionary new.
	actions at: 'Object' put: Object.
	actions at: 'String' put: String.
	refMicroUMLSDForPackageCode instVarNamed: #actions put: actions.
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForPackageCode instVarNamed: #astBuilder put: astBuilder.
	refMicroUMLSDForPackageCode ast43BuildActors.
	actors := astBuilder instVarNamed: #actors.
	"Verify 'O' is not present, only the action class names"
	self assert: (actors keys asArray) equals: #('Object' 'String').
	self deny: (actors includesKey: 'O')

]

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> testClassNameCheckArg [
	"Test classNameCheck: when packageScope is empty - should return true for any class"
	refMicroUMLSDForPackageCode instVarNamed: #packageScope put: ''.
	self assert: (refMicroUMLSDForPackageCode classNameCheck: Object).

	"Test classNameCheck: when packageScope is set to a matching package name - should return true"
	refMicroUMLSDForPackageCode instVarNamed: #packageScope put: #'Kernel'.
	self assert: (refMicroUMLSDForPackageCode classNameCheck: Object).
	self assert: (refMicroUMLSDForPackageCode classNameCheck: Point).

	"Test classNameCheck: when packageScope does not match the class package - should return false"
	self deny: (refMicroUMLSDForPackageCode classNameCheck: Color)
]

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> testOpenSubDiagramForArg [
	| cList message result expectedPackageName |
	"Set up the receiver with a known package scope"
	refMicroUMLSDForPackageCode scope: 'Kernel'.

	"Build a message array matching the format produced by ast10BuildMessageList:
	 { senderClass. receiverClass. selector. isReturn. { index. contextList } }
	 Using an empty context list so the sub-diagram renders trivially."
	cList := OrderedCollection new.
	message := { SmallInteger. SmallInteger. #+. false. { 1. cList } }.

	"Compute the expected package name from the receiver class (message second)"
	expectedPackageName := SmallInteger package name.

	"Execute the method under test"
	result := refMicroUMLSDForPackageCode openSubDiagramFor: message.

	"Close the diagram window that was opened as a side effect"
	(World submorphs
		select: [ :m | m isSystemWindow and: [ m label includesSubstring: 'Package:' ] ])
		do: [ :w | w delete ].

	"Verify the result is an instance of MicroUMLSDForPackageCode"
	self assert: (result isKindOf: MicroUMLSDForPackageCode).

	"Verify the sub-diagram's packageScope was set to the receiver class's package name"
	self assert: ((result instVarNamed: #packageScope) = expectedPackageName).

	"Verify the sub-diagram's contextList is the expected sublist (empty in this case)"
	self assert: ((result instVarNamed: #contextList) isEmpty).

]

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> testScopeArg [
	| testScope anotherScope result |
	"Verify the initial value of packageScope is nil after setUp"
	result := refMicroUMLSDForPackageCode instVarNamed: #packageScope.
	self assert: (result isNil).

	"Set the scope using scope: and verify it is stored in packageScope"
	testScope := 'TestPackage'.
	refMicroUMLSDForPackageCode scope: testScope.
	result := refMicroUMLSDForPackageCode instVarNamed: #packageScope.
	self assert: result equals: testScope.

	"Verify overwriting the scope with a different value works"
	anotherScope := 'OtherPackage'.
	refMicroUMLSDForPackageCode scope: anotherScope.
	result := refMicroUMLSDForPackageCode instVarNamed: #packageScope.
	self assert: result equals: anotherScope.
]
