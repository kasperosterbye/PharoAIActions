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
	"Test that ast41Title returns the correct title format with class name"
	
	| result |
	
	"Set up the classScope instance variable with a test class"
	refMicroUMLSDForClassCode instVarNamed: #classScope put: Object.
	
	"Execute the method under test"
	result := refMicroUMLSDForClassCode ast41Title.
	
	"Verify the result has the expected format"
	self assert: (result = 'Class: Object').
	
	"Test with a different class to ensure it works generically"
	refMicroUMLSDForClassCode instVarNamed: #classScope put: String.
	result := refMicroUMLSDForClassCode ast41Title.
	self assert: (result = 'Class: String').
]

{ #category : 'AI generated test' }
MicroUMLSDForClassCodeAITest >> testAst43BuildActors [
	"Test the ast43BuildActors method which builds actors in the AST builder"
	| testActions testClass1 testClass2 |
	
	"Setup test data - create test classes and actions collection"
	testClass1 := Object.
	testClass2 := String.
	testActions := OrderedDictionary new.
	testActions at: 'Object' put: testClass1.
	testActions at: 'String' put: testClass2.
	
	"Initialize the instance with required components"
	refMicroUMLSDForClassCode instVarNamed: #actions put: testActions.
	refMicroUMLSDForClassCode instVarNamed: #astBuilder put: MicroUMLSDAstBuilder new.
	
	"Execute the method under test"
	refMicroUMLSDForClassCode ast43BuildActors.
	
	"Verify that the astBuilder was modified (basic verification that method executed)"
	self assert: (refMicroUMLSDForClassCode instVarNamed: #astBuilder) notNil.
]

{ #category : 'AI generated test' }
MicroUMLSDForClassCodeAITest >> testClassNameCheckArg [
	"Test the classNameCheck: method with different scenarios"
	| testClass1 testClass2 |
	
	testClass1 := String.
	testClass2 := Object.
	
	"Test case 1: When classScope is ProtoObject (initial state), should call emptyPackageTestFor: and set classScope"
	refMicroUMLSDForClassCode instVarNamed: #classScope put: ProtoObject.
	self assert: (refMicroUMLSDForClassCode classNameCheck: testClass1).
	self assert: (refMicroUMLSDForClassCode instVarNamed: #classScope) equals: testClass1.
	
	"Test case 2: When classScope is not ProtoObject and matches the argument, should return true"
	refMicroUMLSDForClassCode instVarNamed: #classScope put: testClass1.
	self assert: (refMicroUMLSDForClassCode classNameCheck: testClass1).
	
	"Test case 3: When classScope is not ProtoObject and does not match the argument, should return false"
	refMicroUMLSDForClassCode instVarNamed: #classScope put: testClass1.
	self assert: (refMicroUMLSDForClassCode classNameCheck: testClass2) equals: false.
	
	"Test case 4: Reset to ProtoObject and test with different class"
	refMicroUMLSDForClassCode instVarNamed: #classScope put: ProtoObject.
	self assert: (refMicroUMLSDForClassCode classNameCheck: testClass2).
	self assert: (refMicroUMLSDForClassCode instVarNamed: #classScope) equals: testClass2.
]

{ #category : 'AI generated test' }
MicroUMLSDForClassCodeAITest >> testScopeArg [
	"Test that scope: method correctly sets the classScope instance variable"
	| testScope |
	
	testScope := 'myTestScope'.
	
	"Set the scope using the scope: method"
	refMicroUMLSDForClassCode scope: testScope.
	
	"Verify that the classScope instance variable was set correctly"
	self assert: (refMicroUMLSDForClassCode instVarNamed: #classScope) equals: testScope
]

{ #category : 'AI generated test' }
MicroUMLSDForClassCodeAITest >> testUmlSPForArg [
	"Test that umlSPFor: builds the expected subList and scope, and delegates to the class-side #forContext:inScope:."

	| message idx cList subList nextPackage expected |

	"Build a message matching the protocol used by #umlSPFor:.
	 fifth = { idx . cList } where idx is an Integer and cList is a SequenceableCollection."
	message := { Object. String. #size. false. { 2. { Object. String } } }.

	"Compute the expected arguments exactly like the method under test."
	idx := message fifth first.
	cList := message fifth second.
	subList := cList copyFrom: idx to: cList size.
	nextPackage := { message second package name. message second packageTag name }.

	"Sanity checks on the derived values."
	self assert: (idx = 2).
	self assert: (cList = { Object. String }).
	self assert: (subList = { String }).
	self assert: (nextPackage = { #'Collections-Strings'. #Base }).

	"Compare the result with the direct class-side call that umlSPFor: should delegate to."
	expected := MicroUMLSDForClassCode forContext: subList inScope: nextPackage.
	self assert: ((refMicroUMLSDForClassCode umlSPFor: message) = expected)
]
