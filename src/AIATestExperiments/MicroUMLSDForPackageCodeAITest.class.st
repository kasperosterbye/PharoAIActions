Class {
	#name : 'MicroUMLSDForPackageCodeAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDForPackageCode'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> API [ Error: tried more than the 50 allowed TOOLS calls
]

{ #category : 'initialization' }
MicroUMLSDForPackageCodeAITest >> setUp [
	super setUp.
	refMicroUMLSDForPackageCode := MicroUMLSDForPackageCode new.
]

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> testAst43BuildActors [
	"Test the ast43BuildActors method of MicroUMLSDForPackageCode.
	 This method builds actors in the astBuilder based on packageScope and actions.
	 When packageScope is non-empty, an 'O' actor is added first.
	 Then each class in actions is added as an actor with a click action."

	| builder actions actorNames |

	"--- Test 1: Non-empty packageScope with two action classes ---"
	"Set up a fresh astBuilder on the instance"
	builder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForPackageCode instVarNamed: #astBuilder put: builder.

	"Set packageScope to a non-empty string so the 'O' actor is added"
	refMicroUMLSDForPackageCode scope: 'SomePackage'.

	"Populate actions with two known classes"
	actions := OrderedDictionary new.
	actions at: 'Object' put: Object.
	actions at: 'Array' put: Array.
	refMicroUMLSDForPackageCode instVarNamed: #actions put: actions.

	"Execute the method under test"
	refMicroUMLSDForPackageCode ast43BuildActors.

	"Verify that 3 actors were created: 'O' + 'Object' + 'Array'"
	self assert: builder actors size equals: 3.

	"Collect actor names for verification"
	actorNames := builder actors collect: [ :a | a name ].
	self assert: (actorNames first) equals: 'O'.
	self assert: (actorNames second) equals: 'Object'.
	self assert: (actorNames third) equals: 'Array'.

	"The 'O' actor should have no click action"
	self assert: (builder actors first clickAction isNil).

	"Each action-based actor should have a click action (a block)"
	self assert: (builder actors second clickAction isNotNil).
	self assert: (builder actors third clickAction isNotNil).

	"--- Test 2: Empty packageScope — no 'O' actor should be added ---"
	builder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForPackageCode instVarNamed: #astBuilder put: builder.

	"Set packageScope to empty string"
	refMicroUMLSDForPackageCode scope: ''.

	"Reuse the same actions dictionary"
	refMicroUMLSDForPackageCode instVarNamed: #actions put: actions.

	"Execute the method under test"
	refMicroUMLSDForPackageCode ast43BuildActors.

	"Verify that only 2 actors were created (no 'O')"
	self assert: builder actors size equals: 2.

	actorNames := builder actors collect: [ :a | a name ].
	self assert: (actorNames first) equals: 'Object'.
	self assert: (actorNames second) equals: 'Array'.

	"Both actors should have click actions"
	self assert: (builder actors first clickAction isNotNil).
	self assert: (builder actors second clickAction isNotNil).

	"--- Test 3: Non-empty packageScope with empty actions — only 'O' actor ---"
	builder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForPackageCode instVarNamed: #astBuilder put: builder.
	refMicroUMLSDForPackageCode scope: 'AnotherPackage'.
	refMicroUMLSDForPackageCode instVarNamed: #actions put: OrderedDictionary new.

	refMicroUMLSDForPackageCode ast43BuildActors.

	"Only the 'O' actor should exist"
	self assert: builder actors size equals: 1.
	self assert: (builder actors first name) equals: 'O'.
	self assert: (builder actors first clickAction isNil)

]

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> testScopeArg [
	"Test that scope: sets the packageScope instance variable correctly."
	| testScope |
	"Set a non-empty scope string"
	testScope := 'Kernel-CodeModel'.
	refMicroUMLSDForPackageCode scope: testScope.
	"Verify that packageScope was set to the given value"
	self assert: (refMicroUMLSDForPackageCode instVarNamed: #packageScope) equals: testScope.

	"Set an empty scope string"
	refMicroUMLSDForPackageCode scope: ''.
	self assert: (refMicroUMLSDForPackageCode instVarNamed: #packageScope) equals: ''.

	"Set scope to nil"
	refMicroUMLSDForPackageCode scope: nil.
	self assert: (refMicroUMLSDForPackageCode instVarNamed: #packageScope) isNil

]

{ #category : 'AI generated test' }
MicroUMLSDForPackageCodeAITest >> testUmlSPForArg [
	"Test #umlSPFor: builds the correct subList from message fifth,
	and uses message second package name as the scope (a String),
	returning a MicroUMLSDForPackageCode configured by the class-side factory."

	| message idx cList result |

	"Arrange: message fifth first is itself a collection; its first element is the index."
	idx := 2.
	cList := #(a b c).

	message := Array new: 5.
	message at: 2 put: Object.
	message at: 5 put: (Array with: (Array with: idx) with: cList).

	"Act"
	result := refMicroUMLSDForPackageCode umlSPFor: message.

	"Assert: factory returns a package-code instance, with scope and contextList set."
	self assert: (result isKindOf: MicroUMLSDForPackageCode).
	self assert: ((result instVarNamed: #packageScope) = (Object package name)).
	self assert: ((result instVarNamed: #contextList) = (cList copyFrom: idx to: cList size)).
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
