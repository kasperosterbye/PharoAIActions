Class {
	#name : 'MicroUMLSDForCode5AITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDForCode5'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicroUMLSDForCode5AITest >> setUp [
	super setUp.
	refMicroUMLSDForCode5 := MicroUMLSDForCode5 new.
]

{ #category : 'AI generated test' }
MicroUMLSDForCode5AITest >> testAst10BuildMessageList [
	| cm ctx1 ctx2 |
	"Prepare a compiled method"
	cm := Object >> #yourself.
	
	"Create an outer context (sender)"
	ctx1 := Context
		sender: nil
		receiver: Object new
		method: cm
		arguments: #().
	
	"Create an inner context"
	ctx2 := Context
		sender: ctx1
		receiver: Object new
		method: cm
		arguments: #().
	
	"Setup the instance variables"
	refMicroUMLSDForCode5 instVarNamed: #contextList put: (OrderedCollection with: ctx2).
	refMicroUMLSDForCode5 instVarNamed: #messages put: OrderedCollection new.
	
	"Execute the method under test"
	refMicroUMLSDForCode5 ast10BuildMessageList.
	
	"Verify that messages collection has one entry"
	self assert: ((refMicroUMLSDForCode5 instVarNamed: #messages) size) equals: 1.
	
	"Verify the message candidate structure"
	self assert: (((refMicroUMLSDForCode5 instVarNamed: #messages) first at: 1) == Object).
	self assert: (((refMicroUMLSDForCode5 instVarNamed: #messages) first at: 2) == Object).
	self assert: (((refMicroUMLSDForCode5 instVarNamed: #messages) first at: 3) == #yourself).
	self assert: (((refMicroUMLSDForCode5 instVarNamed: #messages) first size) equals: 5)
]

{ #category : 'AI generated test' }
MicroUMLSDForCode5AITest >> testAst48BuildExternalMessage [
	"Test the ast48BuildExternalMessage: method covering all branches:
	- same sender/receiver, not return: internal call
	- different sender/receiver, not return: call from sender to receiver
	- different sender/receiver, return: return from receiver to sender"

	| astBuilder msg1 msg2 msg3 |

	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForCode5 instVarNamed: #astBuilder put: astBuilder.

	"Pre-add actors as done in ast43BuildActors"
	astBuilder , Object name.
	astBuilder , Point name.

	"Case 1: sender = receiver (Object), fourth=false -> internal call Object => #selfCall"
	msg1 := Array
		with: Object
		with: Object
		with: #selfCall
		with: false
		with: { 1. OrderedCollection new }.
	refMicroUMLSDForCode5 ast48BuildExternalMessage: msg1.
	self assert: (astBuilder messages size) equals: 1.
	self assert: (astBuilder messages first fromActor name) equals: 'Object'.
	self assert: (astBuilder messages first toActor name) equals: 'Object'.
	self assert: (astBuilder messages first description) equals: #selfCall.
	self assert: (astBuilder messages first messageType) equals: #internal.

	"Case 2: sender=Object receiver=Point, fourth=false -> call Object -> Point => #method"
	msg2 := Array
		with: Object
		with: Point
		with: #method
		with: false
		with: { 2. OrderedCollection new }.
	refMicroUMLSDForCode5 ast48BuildExternalMessage: msg2.
	self assert: (astBuilder messages size) equals: 2.
	self assert: (astBuilder messages last fromActor name) equals: 'Object'.
	self assert: (astBuilder messages last toActor name) equals: 'Point'.
	self assert: (astBuilder messages last description) equals: #method.
	self assert: (astBuilder messages last messageType) equals: #call.

	"Case 3: sender=Object receiver=Point, fourth=true -> return Point -> Object --> #returnMethod"
	msg3 := Array
		with: Object
		with: Point
		with: #returnMethod
		with: true
		with: { 3. OrderedCollection new }.
	refMicroUMLSDForCode5 ast48BuildExternalMessage: msg3.
	self assert: (astBuilder messages size) equals: 3.
	self assert: (astBuilder messages last fromActor name) equals: 'Point'.
	self assert: (astBuilder messages last toActor name) equals: 'Object'.
	self assert: (astBuilder messages last description) equals: #returnMethod.
	self assert: (astBuilder messages last messageType) equals: #return
]

{ #category : 'AI generated test' }
MicroUMLSDForCode5AITest >> testClassNameCheck [
	"Test the classNameCheck: method with different scenarios"
	| testClass1 testClass2 |
	
	testClass1 := Object.
	testClass2 := String.
	
	"Test with empty packageName - should return true for any class"
	refMicroUMLSDForCode5 instVarNamed: #packageName put: ''.
	self assert: (refMicroUMLSDForCode5 classNameCheck: testClass1).
	self assert: (refMicroUMLSDForCode5 classNameCheck: testClass2).
	
	"Test with matching package name - should return true"
	refMicroUMLSDForCode5 instVarNamed: #packageName put: 'Kernel'.
	self assert: (refMicroUMLSDForCode5 classNameCheck: testClass1).
	
	"Test with non-matching package name - should return false"
	refMicroUMLSDForCode5 instVarNamed: #packageName put: 'Kernel'.
	self assert: (refMicroUMLSDForCode5 classNameCheck: testClass2) not.
	
	"Test with matching package name for different class"
	refMicroUMLSDForCode5 instVarNamed: #packageName put: 'Collections-Strings'.
	self assert: (refMicroUMLSDForCode5 classNameCheck: testClass2).
	
	"Test with non-matching package name for different class"
	refMicroUMLSDForCode5 instVarNamed: #packageName put: 'Collections-Strings'.
	self assert: (refMicroUMLSDForCode5 classNameCheck: testClass1) not.
]

{ #category : 'AI generated test' }
MicroUMLSDForCode5AITest >> testForCode [
	"Test that forCode: method delegates to forCode:inPackage: with empty package"
	| result |
	
	"Execute forCode: with a simple block"
	result := refMicroUMLSDForCode5 forCode: [ 1 + 1 ].
	
	"Verify the result is a MicroUMLSDForCode5 instance"
	self assert: (result isKindOf: MicroUMLSDForCode5).
	
	"Verify the result is the same instance (self return)"
	self assert: (result == refMicroUMLSDForCode5)
]

{ #category : 'AI generated test' }
MicroUMLSDForCode5AITest >> testForContextInPackage [
	"Test the forContext:inPackage: method which sets packageName and contextList, then builds message list, actions, and final structure"
	| testContextList testPackageName |
	
	"Create test data - a list of contexts and a package name"
	testContextList := { thisContext }.
	testPackageName := 'TestPackage'.
	
	"Execute the method under test"
	refMicroUMLSDForCode5 forContext: testContextList inPackage: testPackageName.
	
	"Verify that packageName was set correctly"
	self assert: ((refMicroUMLSDForCode5 instVarNamed: #packageName) = testPackageName).
	
	"Verify that contextList was set correctly"
	self assert: ((refMicroUMLSDForCode5 instVarNamed: #contextList) = testContextList).
	
	"Verify that messages instance variable is not nil after ast10BuildMessageList"
	self assert: ((refMicroUMLSDForCode5 instVarNamed: #messages) isNotNil).
	
	"Verify that actions instance variable is not nil after ast20ActionsFromMessages"
	self assert: ((refMicroUMLSDForCode5 instVarNamed: #actions) isNotNil).
]
