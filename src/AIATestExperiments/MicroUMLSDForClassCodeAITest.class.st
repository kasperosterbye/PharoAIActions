Class {
	#name : 'MicroUMLSDForClassCodeAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDForClassCode'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicroUMLSDForClassCodeAITest >> setUp [
	super setUp.
	refMicroUMLSDForClassCode := MicroUMLSDForClassCode new.
]

{ #category : 'AI generated test' }
MicroUMLSDForClassCodeAITest >> testAst41Title [
	"Test that ast41Title returns 'Class: ' concatenated with the name of classScope."
	
	| expected |
	
	"Set the classScope to Object, which has name 'Object'"
	refMicroUMLSDForClassCode scope: Object.
	
	"Expected result"
	expected := 'Class: Object'.
	
	"Assert the method produces the expected title"
	self assert: (refMicroUMLSDForClassCode ast41Title = expected) description: 'ast41Title should return Class: followed by classScope name'.
]

{ #category : 'AI generated test' }
MicroUMLSDForClassCodeAITest >> testAst43BuildActors [
	"Test that ast43BuildActors first adds 'O' as an actor, then delegates to super which adds actors from the actions dictionary."
	| builder actors |
	"Set up a fresh MicroUMLSDAstBuilder and assign it to the astBuilder instance variable"
	builder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForClassCode instVarNamed: #astBuilder put: builder.
	"Set up actions with two known classes so that super ast43BuildActors will add their names as actors"
	refMicroUMLSDForClassCode instVarNamed: #actions put: (OrderedDictionary new at: 'Point' put: Point; at: 'String' put: String; yourself).
	"Execute the method under test"
	refMicroUMLSDForClassCode ast43BuildActors.
	"Retrieve the actors dictionary from the builder"
	actors := builder instVarNamed: #actors.
	"Verify that three actors were created in total"
	self assert: (actors size = 3).
	"Verify that 'O' was added first (by MicroUMLSDForClassCode's override)"
	self assert: (actors keys first = 'O').
	"Verify that the actions' class names were added by the super call"
	self assert: (actors keys second = 'Point').
	self assert: (actors keys third = 'String').
]

{ #category : 'AI generated test' }
MicroUMLSDForClassCodeAITest >> testClassNameCheckArg [
	"Test classNameCheck: which checks whether a given class matches the current scope.
	 When classScope ~= ProtoObject, it simply returns aClass = classScope.
	 When classScope = ProtoObject, it delegates to emptyPackageTestFor: and
	 updates classScope on success."

	"Case 1: classScope is set to a non-ProtoObject class, and aClass matches => true"
	refMicroUMLSDForClassCode scope: Object.
	self assert: (refMicroUMLSDForClassCode classNameCheck: Object)
		description: 'Should return true when aClass equals classScope'.

	"Case 2: classScope is set to a non-ProtoObject class, and aClass does not match => false"
	refMicroUMLSDForClassCode scope: Object.
	self deny: (refMicroUMLSDForClassCode classNameCheck: Point)
		description: 'Should return false when aClass differs from classScope'.

	"Case 3: classScope is ProtoObject, emptyPackageTestFor: returns false => false, classScope unchanged"
	refMicroUMLSDForClassCode scope: ProtoObject.
	self deny: (refMicroUMLSDForClassCode classNameCheck: BlockClosure)
		description: 'Should return false when emptyPackageTestFor: is false'.
	self assert: ((refMicroUMLSDForClassCode instVarNamed: #classScope) = ProtoObject)
		description: 'classScope should remain ProtoObject when emptyPackageTestFor: returns false'.

	"Case 4: classScope is ProtoObject, emptyPackageTestFor: returns true => true, classScope updated"
	refMicroUMLSDForClassCode scope: ProtoObject.
	self assert: (refMicroUMLSDForClassCode classNameCheck: Object)
		description: 'Should return true when emptyPackageTestFor: is true'.
	self assert: ((refMicroUMLSDForClassCode instVarNamed: #classScope) = Object)
		description: 'classScope should be updated to aClass when emptyPackageTestFor: returns true'

]

{ #category : 'AI generated test' }
MicroUMLSDForClassCodeAITest >> testOpenSubDiagramForArg [
	| message cList nextPackage result expectedSubList |

	"Set the classScope on the receiver so it is properly initialized"
	refMicroUMLSDForClassCode scope: Object.

	"Build an empty context list so that forContext: / forCode does not
	 attempt to send #sender to non-Context objects"
	cList := OrderedCollection new.

	"nextPackage must be a Class because forScope: uses isClass to decide
	 which subclass of MicroUMLSDForCode to instantiate"
	nextPackage := Point.

	"Construct the message array matching the structure produced by
	 ast10BuildMessageList: { senderClass. methodClass. selector. isReturn. {index. contextList} }"
	message := Array
		with: Object          "first  - sender class (unused by openSubDiagramFor:)"
		with: nextPackage     "second - used as the scope for the sub-diagram"
		with: #x              "third  - selector (unused by openSubDiagramFor:)"
		with: false           "fourth - isReturn flag (unused by openSubDiagramFor:)"
		with: { 1. cList }.   "fifth  - { index. contextList } used to compute subList"

	"Compute the expected subList independently to verify the extraction logic"
	expectedSubList := cList copyFrom: 1 to: cList size.

	"Invoke the method under test"
	result := refMicroUMLSDForClassCode openSubDiagramFor: message.

	"openSubDiagramFor: has no explicit return (^), so it returns self"
	self assert: (result == refMicroUMLSDForClassCode)
		description: 'Method should return self (the receiver)'.

	"The receiver''s classScope must remain unchanged (Object), because
	 the sub-diagram is created on a separate instance inside forContext:inScope:"
	self assert: ((refMicroUMLSDForClassCode instVarNamed: #classScope) == Object)
		description: 'classScope of the receiver should not be modified'.

]

{ #category : 'AI generated test' }
MicroUMLSDForClassCodeAITest >> testScopeArg [
	"Test that scope: correctly sets the classScope instance variable"
	| testScope result |
	"Verify classScope is nil before calling scope:"
	result := refMicroUMLSDForClassCode instVarNamed: #classScope.
	self assert: result equals: nil.
	"Set scope to a known value"
	testScope := Object.
	refMicroUMLSDForClassCode scope: testScope.
	"Verify classScope was set correctly"
	result := refMicroUMLSDForClassCode instVarNamed: #classScope.
	self assert: result equals: testScope
]
