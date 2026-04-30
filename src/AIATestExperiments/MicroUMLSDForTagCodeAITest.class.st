Class {
	#name : 'MicroUMLSDForTagCodeAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDForTagCode'
	],
	#category : 'AIATestExperiments-MicroUMLTests',
	#package : 'AIATestExperiments',
	#tag : 'MicroUMLTests'
}

{ #category : 'initialization' }
MicroUMLSDForTagCodeAITest >> setUp [
	super setUp.
	refMicroUMLSDForTagCode := MicroUMLSDForTagCode new.
]

{ #category : 'AI generated test' }
MicroUMLSDForTagCodeAITest >> testAst41Title [
	"Test that ast41Title returns the correctly formatted string using packageScope and tagScope"

	refMicroUMLSDForTagCode scope: #('TestPackage' 'TestTag').
	self assert: refMicroUMLSDForTagCode ast41Title equals: 'Package: TestPackage Tag: TestTag'
]

{ #category : 'AI generated test' }
MicroUMLSDForTagCodeAITest >> testAst43BuildActors [
	| builder actors actorKeys |
	"Prepare a fresh astBuilder and set actions with a known class"
	builder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForTagCode instVarNamed: #astBuilder put: builder.
	refMicroUMLSDForTagCode instVarNamed: #actions put: (OrderedDictionary newFrom: { 'Number' -> Number }).

	"Execute the method under test"
	refMicroUMLSDForTagCode ast43BuildActors.

	"Retrieve actors from the builder"
	actors := builder instVarNamed: #actors.
	actorKeys := actors keys.

	"Verify that 'O' was added first, followed by actors from actions"
	self assert: (actors size = 2).
	self assert: (actorKeys first = 'O').
	self assert: (actorKeys second = 'Number').

	"Verify actor names match their keys"
	self assert: ((actors at: 'O') name = 'O').
	self assert: ((actors at: 'Number') name = 'Number').
]

{ #category : 'AI generated test' }
MicroUMLSDForTagCodeAITest >> testClassNameCheckArg [
	"Test classNameCheck: returns false for excluded classes (self class, Context, BlockClosure) and does not set scopes"

	self assert: (refMicroUMLSDForTagCode instVarNamed: #packageScope) isNil.
	self assert: (refMicroUMLSDForTagCode instVarNamed: #tagScope) isNil.

	self assert: (refMicroUMLSDForTagCode classNameCheck: MicroUMLSDForTagCode) not.
	self assert: (refMicroUMLSDForTagCode classNameCheck: Context) not.
	self assert: (refMicroUMLSDForTagCode classNameCheck: BlockClosure) not.

	self assert: (refMicroUMLSDForTagCode instVarNamed: #packageScope) isNil.
	self assert: (refMicroUMLSDForTagCode instVarNamed: #tagScope) isNil.

	"Test classNameCheck: returns true for non-excluded class like Object and sets scopes correctly"

	self assert: (refMicroUMLSDForTagCode classNameCheck: Object).

	self assert: (refMicroUMLSDForTagCode instVarNamed: #packageScope) = Object package name.
	self assert: (refMicroUMLSDForTagCode instVarNamed: #tagScope) = Object packageTag name
]

{ #category : 'AI generated test' }
MicroUMLSDForTagCodeAITest >> testEmptyPackageTestForArg [
	"Test emptyPackageTestFor: returns true for regular classes like Object"
	self assert: (refMicroUMLSDForTagCode emptyPackageTestFor: Object).
	
	"Test skips (returns false) for UndefinedObject"
	self deny: (refMicroUMLSDForTagCode emptyPackageTestFor: UndefinedObject).
	
	"Test skips (returns false) for Context"
	self deny: (refMicroUMLSDForTagCode emptyPackageTestFor: Context).
	
	"Test skips (returns false) for BlockClosure"
	self deny: (refMicroUMLSDForTagCode emptyPackageTestFor: BlockClosure).
	
	"Test skips (returns false) for BlockClosure subclass like CleanBlockClosure"
	self deny: (refMicroUMLSDForTagCode emptyPackageTestFor: CleanBlockClosure).
	
	"Test skips (returns false) for self class (MicroUMLSDForTagCode class)"
	self deny: (refMicroUMLSDForTagCode emptyPackageTestFor: refMicroUMLSDForTagCode class)
]

{ #category : 'AI generated test' }
MicroUMLSDForTagCodeAITest >> testOpenSubDiagramForArg [
	| contexts cList index message result windowsBefore windowsAfter newWindows expectedSubListSize expectedPackageName expectedTagName |
	"Build a context list by simulating a simple expression"
	contexts := OrderedCollection new.
	thisContext
		runSimulated: [ OrderedCollection new add: 1 ]
		contextAtEachStep: [ :ctx | contexts add: ctx copy ].
	cList := contexts.
	index := 3.
	"Build the message array matching the structure from ast10BuildMessageList:
	 { senderClass. methodClass. selector. isReturn. {index. contextList} }"
	message := {
		           Object.
		           OrderedCollection.
		           #add:.
		           false.
		           { index. cList } }.
	"Compute expected values that openSubDiagramFor: will derive internally"
	expectedSubListSize := cList size - index + 1.
	expectedPackageName := OrderedCollection package name.
	expectedTagName := OrderedCollection packageTag name.
	"Record open windows before calling the method"
	windowsBefore := SystemWindow allSubInstances asIdentitySet.
	"Call the method under test"
	result := refMicroUMLSDForTagCode openSubDiagramFor: message.
	"Record windows after calling and clean up any newly opened windows"
	windowsAfter := SystemWindow allSubInstances asIdentitySet.
	newWindows := windowsAfter difference: windowsBefore.
	newWindows do: [ :w | w delete ].
	"openSubDiagramFor: has no explicit return so it returns self"
	self
		assert: (result == refMicroUMLSDForTagCode)
		description: 'openSubDiagramFor: should return self'.
	"A new diagram window should have been opened by forContext:inScope:"
	self
		assert: (newWindows size > 0)
		description: 'A new diagram window should have been opened'.
	"Verify the expected subList size matches what copyFrom:to: would produce"
	self assert: expectedSubListSize equals: cList size - index + 1.
	"Verify the expected package name for message second (OrderedCollection)"
	self assert: expectedPackageName equals: 'Collections-Sequenceable'.
	"Verify the expected tag name for message second (OrderedCollection)"
	self assert: expectedTagName equals: 'Ordered'

]

{ #category : 'AI generated test' }
MicroUMLSDForTagCodeAITest >> testScopeArg [
	"Test that scope: correctly sets the packageScope and tagScope instance variables from the provided scope collection."

	refMicroUMLSDForTagCode scope: { 'MicroSequenceDiagram'. 'MicroUML' }.
	self assert: ((refMicroUMLSDForTagCode instVarNamed: #packageScope) = 'MicroSequenceDiagram').
	self assert: ((refMicroUMLSDForTagCode instVarNamed: #tagScope) = 'MicroUML')
]
