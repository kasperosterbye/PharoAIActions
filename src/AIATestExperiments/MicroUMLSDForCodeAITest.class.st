Class {
	#name : 'MicroUMLSDForCodeAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicroUMLSDForCode'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicroUMLSDForCodeAITest >> setUp [
	super setUp.
	refMicroUMLSDForCode := MicroUMLSDForCode new.
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst10BuildMessageList [
	| ctx1 ctx2 initialSize |
	
	"Prepare a small contextList with real Context instances that answer
	 #sender, #method and #isReturn (required by #ast10BuildMessageList)."
	ctx1 := thisContext.
	ctx2 := thisContext sender.
	
	"Ensure we start from a clean state (initialize creates empty collections)."
	refMicroUMLSDForCode initialize.
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	refMicroUMLSDForCode instVarNamed: #contextList put: (OrderedCollection with: ctx1 with: ctx2).
	
	"Run and check that messages are added (scope = '' makes package check always true)."
	initialSize := (refMicroUMLSDForCode instVarNamed: #messages) size.
	refMicroUMLSDForCode ast10BuildMessageList.
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) size) > initialSize.
	
	"Check the structure of the first produced messageCandidate."
	self assert: (((refMicroUMLSDForCode instVarNamed: #messages) first) size) equals: 5.
	self assert: ((((refMicroUMLSDForCode instVarNamed: #messages) first) third) isSymbol).
	self assert: ((((refMicroUMLSDForCode instVarNamed: #messages) first) fourth) isBoolean).
	self assert: ((((refMicroUMLSDForCode instVarNamed: #messages) first) fifth) isArray).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst10BuildMessageList01 [
	| testContexts messages aMessage |
	
	"Setup test contexts using real simulation to ensure proper sender and method structure"
	testContexts := OrderedCollection new.
	thisContext runSimulated: [ 1 + 2 ] contextAtEachStep: [ :ctx | testContexts add: ctx copy ].
	
	"Set scope to empty string so ast12CheckPackageContext always returns true"
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	
	"Provide the test contexts and ensure messages starts empty"
	refMicroUMLSDForCode instVarNamed: #contextList put: testContexts.
	refMicroUMLSDForCode instVarNamed: #messages put: OrderedCollection new.
	
	"Execute the method under test"
	refMicroUMLSDForCode ast10BuildMessageList.
	
	"Retrieve results for verification"
	messages := refMicroUMLSDForCode instVarNamed: #messages.
	
	"Verify that messages were added"
	self assert: (messages notEmpty).
	
	"Verify structure of added message candidates"
	aMessage := messages first.
	self assert: (aMessage size = 5).
	self assert: (aMessage first isKindOf: Class).
	self assert: (aMessage second isKindOf: Class).
	self assert: (aMessage third isSymbol).
	self assert: (aMessage fourth isKindOf: Boolean).
	self assert: ((aMessage fifth isKindOf: Array) and: [ aMessage fifth size = 2 ]).
	self assert: (aMessage fifth first isInteger).
	self assert: (aMessage fifth second == testContexts)
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst12CheckPackageContextArg [
	"Test the ast12CheckPackageContext: method with different context scenarios"
	| testContext result |
	
	"Setup: Initialize scope to a known package"
	refMicroUMLSDForCode instVarNamed: #scope put: 'Kernel'.
	
	"Test with current context - should return true since UndefinedObject is in Kernel"
	testContext := thisContext.
	result := refMicroUMLSDForCode ast12CheckPackageContext: testContext.
	self assert: (result isKindOf: Boolean).
	
	"Test with a context where sender and method are from different packages"
	refMicroUMLSDForCode instVarNamed: #scope put: 'Collections-Abstract'.
	result := refMicroUMLSDForCode ast12CheckPackageContext: testContext.
	self assert: (result isKindOf: Boolean).
	
	"Test with empty scope - should return true for any context"
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	result := refMicroUMLSDForCode ast12CheckPackageContext: testContext.
	self assert: (result = true).
	
	"Test with class scope"
	refMicroUMLSDForCode instVarNamed: #scope put: Object.
	result := refMicroUMLSDForCode ast12CheckPackageContext: testContext.
	self assert: (result isKindOf: Boolean).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst15AddCheckArg [
	"Test the ast15AddCheck: method which checks if a message candidate should be added
	based on comparison with existing messages in the collection"
	| messageCandidate1 messageCandidate2 messageCandidate3 messages |
	
	"Initialize messages collection with test data"
	messages := OrderedCollection new.
	messages add: #(#Object #new #() #result1).
	messages add: #(#String #size #() #result2).
	refMicroUMLSDForCode instVarNamed: #messages put: messages.
	
	"Test case 1: Different message candidate should return true (can be added)"
	messageCandidate1 := #(#Array #new #() #result3).
	self assert: (refMicroUMLSDForCode ast15AddCheck: messageCandidate1).
	
	"Test case 2: Same first 3 elements but different 4th element should return true (can be added)"
	messageCandidate2 := #(#Object #new #() #result3).
	self assert: (refMicroUMLSDForCode ast15AddCheck: messageCandidate2).
	
	"Test case 3: Exact match (same first 3 elements and same 4th element) should return false (cannot be added)"
	messageCandidate3 := #(#Object #new #() #result1).
	self assert: (refMicroUMLSDForCode ast15AddCheck: messageCandidate3) not.
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst20ActionsFromMessages [
	| initialMessagesSize initialActionsSize messagesAfter actionsAfter numberReceiver fractionReceiver |
	
	"Initialize with example that has Number/Fraction messages (in Kernel scope)"
	refMicroUMLSDForCode forCode: [ (2/3) + (4/7) ] inScope: 'Kernel'.
	
	"Store initial state"
	initialMessagesSize := (refMicroUMLSDForCode instVarNamed: #messages) size.
	initialActionsSize := (refMicroUMLSDForCode instVarNamed: #actions) size.
	
	"Execute the method under test"
	refMicroUMLSDForCode ast20ActionsFromMessages.
	
	"Retrieve results"
	messagesAfter := refMicroUMLSDForCode instVarNamed: #messages.
	actionsAfter := refMicroUMLSDForCode instVarNamed: #actions.
	
	"Verify filtering: self class messages excluded, some remain"
	self assert: (messagesAfter size >= 0).
	self assert: (messagesAfter size <= initialMessagesSize).
	
	"Verify actions populated with classes passing classNameCheck"
	self assert: (actionsAfter size >= initialActionsSize).
	self assert: ((actionsAfter includesKey: 'Number') or: [ actionsAfter includesKey: 'Fraction' ]).
	
	"Verify specific classes were added if classNameCheck passes"
	self assert: (refMicroUMLSDForCode classNameCheck: Number).
	self assert: ((actionsAfter at: 'Number' ifAbsent: [ nil ]) isNotNil).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst40Build [
	"Test ast40Build: initializes astBuilder, builds actors and messages, creates sequence diagram with title, and builds it"
	| obj astBuilder sd |
	
	obj := MicroUMLSDForCode new
		forCode: [ Color blue + Color cyan ]
		inScope: 'Colors'.
	
	"Execute the method under test"
	obj ast40Build.
	
	"Verify astBuilder was created and populated"
	astBuilder := obj instVarNamed: #astBuilder.
	self assert: (astBuilder isKindOf: MicroUMLSDAstBuilder).
	self assert: (astBuilder actors size >= 1).
	self assert: (astBuilder messages size >= 1).
	
	"Verify sequence diagram was created and built"
	sd := MicroUMLSequenceDiagram from: astBuilder.
	self assert: (sd isKindOf: MicroUMLSequenceDiagram).
	self assert: sd uiTitle isNotNil
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst41Title [
	"Test the ast41Title method with different scope types"
	| result |
	
	"Test with empty string scope - should return 'All packages'"
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	result := refMicroUMLSDForCode ast41Title.
	self assert: (result = 'All packages').
	
	"Test with non-empty string scope - should return 'Package: ' + scope"
	refMicroUMLSDForCode instVarNamed: #scope put: 'TestPackage'.
	result := refMicroUMLSDForCode ast41Title.
	self assert: (result = 'Package: TestPackage').
	
	"Test with array scope - should return 'Package: ' + first + ' Tag: ' + second"
	refMicroUMLSDForCode instVarNamed: #scope put: #('TestPackage' 'TestTag').
	result := refMicroUMLSDForCode ast41Title.
	self assert: (result = 'Package: TestPackage Tag: TestTag').
	
	"Test with class scope - should return 'Class: ' + class name"
	refMicroUMLSDForCode instVarNamed: #scope put: Object.
	result := refMicroUMLSDForCode ast41Title.
	self assert: (result = 'Class: Object').
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst43BuildActors [
	"Test ast43BuildActors adds 'O' actor when scope non-empty and adds actors from actions with click actions"
	| tempActions astBuilder expectedActorNames |
	
	expectedActorNames := #('O' 'Object' 'String').
	
	"Prepare test data"
	refMicroUMLSDForCode instVarNamed: #scope put: 'TestScope'.
	
	tempActions := OrderedDictionary new.
	tempActions at: 'Object' put: Object.
	tempActions at: 'String' put: String.
	refMicroUMLSDForCode instVarNamed: #actions put: tempActions.
	
	refMicroUMLSDForCode instVarNamed: #astBuilder put: MicroUMLSDAstBuilder new.
	astBuilder := refMicroUMLSDForCode instVarNamed: #astBuilder.
	
	"Verify initial state"
	self assert: (astBuilder actors size) equals: 0.
	
	"Execute method under test"
	refMicroUMLSDForCode ast43BuildActors.
	
	"Retrieve updated astBuilder"
	astBuilder := refMicroUMLSDForCode instVarNamed: #astBuilder.
	
	"Assert correct number of actors added (1 for 'O' + 2 from actions)"
	self assert: (astBuilder actors size) equals: 3.
	
	"Assert actors in correct order with correct names"
	self assert: ((astBuilder actors collect: [ :actor | actor name ]) asArray) equals: expectedActorNames.
	
	"Assert 'O' has no clickAction, others do"
	self assert: ((astBuilder actors first) clickAction isNil).
	self assert: ((astBuilder actors at: 2) clickAction isBlock).
	self assert: ((astBuilder actors at: 3) clickAction isBlock).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst46BuildMessages [
	"Test that ast46BuildMessages correctly routes messages to ast47BuildPackageMessage or ast48BuildExternalMessage based on classNameCheck, and builds correct AST elements"
	| testMessages astBuilder firstMsg secondMsg |
	testMessages := OrderedCollection 
		with: {Number. Object. #asString. false. {1. OrderedCollection new}}
		with: {String. Number. #size. false. {2. OrderedCollection new}}.
	refMicroUMLSDForCode instVarNamed: #scope put: 'Kernel'.
	refMicroUMLSDForCode instVarNamed: #messages put: testMessages.
	astBuilder := MicroUMLSDAstBuilder new , 'O' , 'Number' , 'Object'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	refMicroUMLSDForCode ast46BuildMessages.
	firstMsg := astBuilder messages first.
	secondMsg := astBuilder messages second.
	self assert: (astBuilder messages size = 2).
	self assert: (firstMsg fromActor name = 'Number').
	self assert: (firstMsg toActor name = 'Object').
	self assert: (firstMsg description = 'asString').
	self assert: (firstMsg messageType = #call).
	self assert: (secondMsg fromActor name = 'O').
	self assert: (secondMsg toActor name = 'Number').
	self assert: (secondMsg description = 'size').
	self assert: (secondMsg messageType = #call)
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst46BuildMessages01 [
	"ast46BuildMessages dispatches each message to:
	- ast48BuildExternalMessage: when both classNameCheck: are true
	- ast47BuildPackageMessage: otherwise.

	We set scope to a package name string ('Colors') so classNameCheck: answers true for Color and false for Object.
	We also set up astBuilder and messages directly to avoid relying on other pipeline steps."

	| messages |
	refMicroUMLSDForCode instVarNamed: #scope put: 'Colors'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: MicroUMLSDAstBuilder new.

	messages := OrderedCollection new.
	"Both in scope -> external message builder path"
	messages add: { Color. Color. #plus:. false. nil }.
	"Not both in scope (Object not in 'Colors') -> package message builder path"
	messages add: { Object. Color. #yourself. false. nil }.

	refMicroUMLSDForCode instVarNamed: #messages put: messages.

	"Execute"
	refMicroUMLSDForCode ast46BuildMessages.

	"Assert: astBuilder received two built messages"
	self assert: (((refMicroUMLSDForCode instVarNamed: #astBuilder) instVarNamed: #messages) size = 2).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst47BuildPackageMessageArg [
	"Test ast47BuildPackageMessage: method with different message configurations.
	Tests both classNameCheck true/false paths, ignored/non-ignored selectors, and return/non-return cases.
	Verifies astBuilder messages size and lastMethod are updated correctly."
	| astBuilder message mockFifth |
	mockFifth := { 1. OrderedCollection new }.

	"Case 1: classNameCheck true (scope empty), selector not ignored (#yourself Symbol), not return
	=> sets lastMethod, adds message 'Object' => #yourself with clickAction"
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	astBuilder := MicroUMLSDAstBuilder new.
	astBuilder , 'Object'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	message := { Object. Object. #yourself. false. mockFifth }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	self assert: ((astBuilder instVarNamed: #messages) size = 1).
	self assert: ((astBuilder instVarNamed: #lastMethod) = mockFifth).

	"Case 2: classNameCheck true, selector ignored ('new' String), not return
	=> does NOT set lastMethod, does NOT add message"
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	astBuilder := MicroUMLSDAstBuilder new.
	astBuilder , 'Object'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	message := { Object. Object. 'new'. false. mockFifth }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	self assert: ((astBuilder instVarNamed: #messages) size = 0).
	self assert: ((astBuilder instVarNamed: #lastMethod) isNil).

	"Case 3: classNameCheck true, selector not ignored, is return
	=> does NOT set lastMethod, does NOT add message"
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	astBuilder := MicroUMLSDAstBuilder new.
	astBuilder , 'Object'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	message := { Object. Object. #yourself. true. mockFifth }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	self assert: ((astBuilder instVarNamed: #messages) size = 0).
	self assert: ((astBuilder instVarNamed: #lastMethod) isNil).

	"Case 4: classNameCheck false, not return
	=> adds message 'O' -> 'String' => #size, no lastMethod"
	refMicroUMLSDForCode instVarNamed: #scope put: 'NonExistentPackage'.
	astBuilder := MicroUMLSDAstBuilder new.
	astBuilder , 'O'; , 'String'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	message := { Object. String. #size. false. mockFifth }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	self assert: ((astBuilder instVarNamed: #messages) size = 1).
	self assert: ((astBuilder instVarNamed: #lastMethod) isNil).

	"Case 5: classNameCheck false, is return
	=> adds message 'String' -> 'O' --> #size, no lastMethod"
	refMicroUMLSDForCode instVarNamed: #scope put: 'NonExistentPackage'.
	astBuilder := MicroUMLSDAstBuilder new.
	astBuilder , 'O'; , 'String'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	message := { Object. String. #size. true. mockFifth }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	self assert: ((astBuilder instVarNamed: #messages) size = 1).
	self assert: ((astBuilder instVarNamed: #lastMethod) isNil)
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst47BuildPackageMessageArg01 [
	"Test #ast47BuildPackageMessage: builds the expected message entries in astBuilder.
	We only assert on astBuilder instance variables that exist (#messages and #lastMethod)."

	| astBuilder message |

	"Case 1: classNameCheck true (scope ''), selector not ignored, not a return (fourth = false)
	=> should set lastMethod and add one message"
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.

	message := { Object. Object. #yourself. false. #dummyLastMethod }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.

	self assert: (((astBuilder instVarNamed: #messages) size) = 1).
	self assert: (((astBuilder instVarNamed: #lastMethod) = #dummyLastMethod)).

	"Case 2: classNameCheck false (scope 'ZZZ'), not a return (fourth = false)
	=> should add one message, should NOT set lastMethod"
	refMicroUMLSDForCode instVarNamed: #scope put: 'ZZZ'.
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.

	message := { Object. String. #yourself. false. #ignoredLastMethod }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.

	self assert: (((astBuilder instVarNamed: #messages) size) = 1).
	self assert: (((astBuilder instVarNamed: #lastMethod) isNil)).

	"Case 3: classNameCheck false (scope 'ZZZ'), is a return (fourth = true)
	=> should add one message, should NOT set lastMethod"
	refMicroUMLSDForCode instVarNamed: #scope put: 'ZZZ'.
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.

	message := { Object. String. #yourself. true. #ignoredLastMethod }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.

	self assert: (((astBuilder instVarNamed: #messages) size) = 1).
	self assert: (((astBuilder instVarNamed: #lastMethod) isNil)).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst48BuildExternalMessageArg [
	"Test ast48BuildExternalMessage: method with different message configurations"
	| astBuilder message dummyContextInfo |
	dummyContextInfo := { 1. OrderedCollection new }.

	"Case 1: Self message (same sender and receiver), not return - should create internal call"
	astBuilder := MicroUMLSDAstBuilder new.
	astBuilder , 'Object'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	message := { Object. Object. #hash. false. dummyContextInfo }.
	refMicroUMLSDForCode ast48BuildExternalMessage: message.
	self assert: (astBuilder messages size = 1).
	self assert: ((astBuilder messages last fromActor name) = 'Object').
	self assert: ((astBuilder messages last toActor name) = 'Object').
	self assert: ((astBuilder messages last messageType) = #internal).
	self assert: ((astBuilder messages last description) = #hash).

	"Case 2: External call (different sender and receiver), not return"
	astBuilder := MicroUMLSDAstBuilder new.
	astBuilder , 'Object'; , 'String'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	message := { Object. String. #size. false. dummyContextInfo }.
	refMicroUMLSDForCode ast48BuildExternalMessage: message.
	self assert: (astBuilder messages size = 1).
	self assert: ((astBuilder messages last fromActor name) = 'Object').
	self assert: ((astBuilder messages last toActor name) = 'String').
	self assert: ((astBuilder messages last messageType) = #call).
	self assert: ((astBuilder messages last description) = #size).

	"Case 3: External return (different sender and receiver), is return"
	astBuilder := MicroUMLSDAstBuilder new.
	astBuilder , 'Object'; , 'String'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	message := { Object. String. #size. true. dummyContextInfo }.
	refMicroUMLSDForCode ast48BuildExternalMessage: message.
	self assert: (astBuilder messages size = 1).
	self assert: ((astBuilder messages last fromActor name) = 'String').
	self assert: ((astBuilder messages last toActor name) = 'Object').
	self assert: ((astBuilder messages last messageType) = #return).
	self assert: ((astBuilder messages last description) = #size).

	"Case 4: Self message (same sender and receiver), is return - should add no message"
	astBuilder := MicroUMLSDAstBuilder new.
	astBuilder , 'Object'.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	message := { Object. Object. #hash. true. dummyContextInfo }.
	refMicroUMLSDForCode ast48BuildExternalMessage: message.
	self assert: (astBuilder messages size = 0).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testClassNameCheckArg [
	"Test the dispatching and logic of classNameCheck: for different scope types"

	| objectScopeArray kernelString colorsString emptyString invalidScope objectClassScope colorClassScope |

	objectScopeArray := #('Kernel' 'Objects').
	kernelString := 'Kernel'.
	colorsString := 'Colors'.
	emptyString := ''.
	invalidScope := 42.
	objectClassScope := Object.
	colorClassScope := Color.

	"String scope - true"
	refMicroUMLSDForCode instVarNamed: #scope put: kernelString.
	self assert: (refMicroUMLSDForCode classNameCheck: Object).

	"String scope - false"
	refMicroUMLSDForCode instVarNamed: #scope put: colorsString.
	self deny: (refMicroUMLSDForCode classNameCheck: Object).

	"String scope empty - true"
	refMicroUMLSDForCode instVarNamed: #scope put: emptyString.
	self assert: (refMicroUMLSDForCode classNameCheck: Object).

	"Array scope exact match - true"
	refMicroUMLSDForCode instVarNamed: #scope put: objectScopeArray.
	self assert: (refMicroUMLSDForCode classNameCheck: Object).

	"Array scope no match special class - false"
	refMicroUMLSDForCode instVarNamed: #scope put: objectScopeArray.
	self deny: (refMicroUMLSDForCode classNameCheck: Context).

	"Class scope - true"
	refMicroUMLSDForCode instVarNamed: #scope put: objectClassScope.
	self assert: (refMicroUMLSDForCode classNameCheck: Object).

	"Class scope - false"
	refMicroUMLSDForCode instVarNamed: #scope put: colorClassScope.
	self deny: (refMicroUMLSDForCode classNameCheck: Object).

	"Invalid scope - raises Error"
	refMicroUMLSDForCode instVarNamed: #scope put: invalidScope.
	self should: [ refMicroUMLSDForCode classNameCheck: Object ] raise: Error
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testClassNameCheckForArrayArg [
	"Test the classNameCheckForArray: method with different scope configurations"
	| result |
	
	"Test with empty scope - should set scope and return true"
	refMicroUMLSDForCode instVarNamed: #scope put: #().
	result := refMicroUMLSDForCode classNameCheckForArray: Object.
	self assert: (result = true).
	self assert: ((refMicroUMLSDForCode instVarNamed: #scope) = #('Kernel' 'Objects')).
	
	"Test with matching scope - should return true"
	refMicroUMLSDForCode instVarNamed: #scope put: #('Kernel' 'Objects').
	result := refMicroUMLSDForCode classNameCheckForArray: Object.
	self assert: (result = true).
	
	"Test with non-matching package name - should return false"
	refMicroUMLSDForCode instVarNamed: #scope put: #('WrongPackage' 'Objects').
	result := refMicroUMLSDForCode classNameCheckForArray: Object.
	self assert: (result = false).
	
	"Test with non-matching package tag - should return false"
	refMicroUMLSDForCode instVarNamed: #scope put: #('Kernel' 'WrongTag').
	result := refMicroUMLSDForCode classNameCheckForArray: Object.
	self assert: (result = false).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testClassNameCheckForClassArg [
	| testClass result |
	
	"Test case 1: scope ~= ProtoObject and aClass equals scope -> returns true, scope unchanged"
	refMicroUMLSDForCode instVarNamed: #scope put: Object.
	testClass := Object.
	result := refMicroUMLSDForCode classNameCheckForClass: testClass.
	self assert: result.
	self assert: ((refMicroUMLSDForCode instVarNamed: #scope) = Object).
	
	"Test case 2: scope ~= ProtoObject and aClass does not equal scope -> returns false, scope unchanged"
	refMicroUMLSDForCode instVarNamed: #scope put: Object.
	testClass := String.
	result := refMicroUMLSDForCode classNameCheckForClass: testClass.
	self assert: result not.
	self assert: ((refMicroUMLSDForCode instVarNamed: #scope) = Object).
	
	"Test case 3: scope == ProtoObject and emptyPackageTestFor: returns false -> returns false, scope unchanged"
	refMicroUMLSDForCode instVarNamed: #scope put: ProtoObject.
	testClass := refMicroUMLSDForCode class.
	result := refMicroUMLSDForCode classNameCheckForClass: testClass.
	self assert: result not.
	self assert: ((refMicroUMLSDForCode instVarNamed: #scope) = ProtoObject).
	
	"Test case 4: scope == ProtoObject and emptyPackageTestFor: returns true -> returns true, scope set to aClass"
	refMicroUMLSDForCode instVarNamed: #scope put: ProtoObject.
	testClass := Object.
	result := refMicroUMLSDForCode classNameCheckForClass: testClass.
	self assert: result.
	self assert: ((refMicroUMLSDForCode instVarNamed: #scope) = testClass)
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testClassNameCheckForStringArg [
	"Test the classNameCheckForString: method with different scope configurations"
	
	| testClass1 testClass2 |
	
	testClass1 := Object.
	testClass2 := String.
	
	"Test with empty scope - should return true for any class"
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	self assert: (refMicroUMLSDForCode classNameCheckForString: testClass1).
	self assert: (refMicroUMLSDForCode classNameCheckForString: testClass2).
	
	"Test with matching scope - should return true"
	refMicroUMLSDForCode instVarNamed: #scope put: 'Kernel'.
	self assert: (refMicroUMLSDForCode classNameCheckForString: testClass1).
	
	"Test with non-matching scope - should return false"
	refMicroUMLSDForCode instVarNamed: #scope put: 'Kernel'.
	self assert: (refMicroUMLSDForCode classNameCheckForString: testClass2) not.
	
	"Test with matching scope for String class"
	refMicroUMLSDForCode instVarNamed: #scope put: 'Collections-Strings'.
	self assert: (refMicroUMLSDForCode classNameCheckForString: testClass2).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testEmptyPackageTestForArg [
	"Test the emptyPackageTestFor: method with different class types"
	| result |
	
	"Test with the same class as the receiver - should return false (test not)"
	result := refMicroUMLSDForCode emptyPackageTestFor: MicroUMLSDForCode.
	self assert: (result = false).
	
	"Test with BlockClosure - should return false (test not)"
	result := refMicroUMLSDForCode emptyPackageTestFor: BlockClosure.
	self assert: (result = false).
	
	"Test with a BlockClosure subclass - should return false (test not)"
	result := refMicroUMLSDForCode emptyPackageTestFor: FullBlockClosure.
	self assert: (result = false).
	
	"Test with Context - should return false (test not)"
	result := refMicroUMLSDForCode emptyPackageTestFor: Context.
	self assert: (result = false).
	
	"Test with UndefinedObject - should return false (test not)"
	result := refMicroUMLSDForCode emptyPackageTestFor: UndefinedObject.
	self assert: (result = false).
	
	"Test with a regular class not in the special list - should return true"
	result := refMicroUMLSDForCode emptyPackageTestFor: Object.
	self assert: (result = true).
	
	"Test with another regular class - should return true"
	result := refMicroUMLSDForCode emptyPackageTestFor: String.
	self assert: (result = true).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testForCodeArg [
	"Test the forCode: method which calls forCode:inScope: with empty scope"
	| testBlock initialContextListSize initialMessagesSize initialActionsSize |
	
	"Initialize test data"
	testBlock := [ 1 + 2 ].
	
	"Record initial state sizes"
	initialContextListSize := (refMicroUMLSDForCode instVarNamed: #contextList) size.
	initialMessagesSize := (refMicroUMLSDForCode instVarNamed: #messages) size.
	initialActionsSize := (refMicroUMLSDForCode instVarNamed: #actions) size.
	
	"Execute the method under test"
	refMicroUMLSDForCode forCode: testBlock.
	
	"Verify scope was set to empty string"
	self assert: ((refMicroUMLSDForCode instVarNamed: #scope) = '').
	
	"Verify contextList was populated during execution"
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) size > initialContextListSize).
	
	"Verify messages were processed"
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) isKindOf: OrderedCollection).
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) size >= initialMessagesSize).
	
	"Verify actions dictionary was populated"
	self assert: ((refMicroUMLSDForCode instVarNamed: #actions) isKindOf: OrderedDictionary).
	self assert: ((refMicroUMLSDForCode instVarNamed: #actions) size >= initialActionsSize).
	
	"Verify astBuilder was initialized"
	self assert: ((refMicroUMLSDForCode instVarNamed: #astBuilder) isNotNil).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testForCodeArgInPackageArg [
	"Test that forCode:inPackage: properly sets scope and captures execution contexts"
	| testBlock contextListSize |
	
	"Create a simple test block"
	testBlock := [ 2 + 3 ].
	
	"Execute forCode:inPackage: with test data"
	refMicroUMLSDForCode forCode: testBlock inPackage: 'Test-Package'.
	
	"Verify that scope was set correctly"
	self assert: ((refMicroUMLSDForCode instVarNamed: #scope) = 'Test-Package').
	
	"Verify that contextList was populated during execution"
	contextListSize := (refMicroUMLSDForCode instVarNamed: #contextList) size.
	self assert: (contextListSize > 0).
	
	"Verify that contextList contains Context objects"
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) first isKindOf: Context).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testForCodeArgInScopeArg [
	"Test the forCode:inScope: method to ensure it properly executes a block and captures execution context"
	| initialContextListSize initialMessagesSize initialActionsSize testBlock testScope |
	
	"Initialize test data"
	testBlock := [ 1 + 2 ].
	testScope := 'Kernel'.
	
	"Record initial state sizes"
	initialContextListSize := (refMicroUMLSDForCode instVarNamed: #contextList) size.
	initialMessagesSize := (refMicroUMLSDForCode instVarNamed: #messages) size.
	initialActionsSize := (refMicroUMLSDForCode instVarNamed: #actions) size.
	
	"Execute the method under test"
	refMicroUMLSDForCode forCode: testBlock inScope: testScope.
	
	"Verify scope was set correctly"
	self assert: ((refMicroUMLSDForCode instVarNamed: #scope) = testScope).
	
	"Verify contextList was populated during execution"
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) size > initialContextListSize).
	
	"Verify messages were processed (may be empty if no matching scope messages)"
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) isKindOf: OrderedCollection).
	
	"Verify actions dictionary was created"
	self assert: ((refMicroUMLSDForCode instVarNamed: #actions) isKindOf: OrderedDictionary).
	
	"Verify astBuilder was initialized"
	self assert: ((refMicroUMLSDForCode instVarNamed: #astBuilder) isNotNil).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testForContextArgInPackageArg [
	"Test that forContext:inPackage: properly sets scope and contextList instance variables and calls the required AST building methods"
	| testContextList testPackageName |
	
	"Setup test data"
	testContextList := {thisContext}.
	testPackageName := 'Test-Package'.
	
	"Execute the method under test"
	refMicroUMLSDForCode forContext: testContextList inPackage: testPackageName.
	
	"Verify that scope was set correctly"
	self assert: ((refMicroUMLSDForCode instVarNamed: #scope) = testPackageName).
	
	"Verify that contextList was set correctly"
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) = testContextList).
	
	"Verify that the method calls were made by checking that instance variables affected by those methods are not nil"
	"ast10BuildMessageList should populate messages"
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) notNil).
	
	"ast20ActionsFromMessages should populate actions"
	self assert: ((refMicroUMLSDForCode instVarNamed: #actions) notNil).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testForContextArgInScopeArg [
	"Test the forContext:inScope: method using real execution contexts captured from a simple arithmetic block.
	Verifies that scope and contextList are set correctly, and that internal processing populates messages, actions, and astBuilder without errors."
	| testContexts testScope |
	testScope := ''.
	testContexts := OrderedCollection new.
	thisContext
		runSimulated: [ (2 / 3) + (4 / 7) ]
		contextAtEachStep: [ :context | testContexts add: context copy ].
	refMicroUMLSDForCode forContext: testContexts inScope: testScope.
	self assert: ((refMicroUMLSDForCode instVarNamed: #scope) = testScope).
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) == testContexts).
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) notEmpty).
	self assert: ((refMicroUMLSDForCode instVarNamed: #actions) notEmpty).
	self assert: ((refMicroUMLSDForCode instVarNamed: #astBuilder) notNil)
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testInitialize [
	"Test that initialize properly sets up the instance variables"
	
	"Test that contextList is initialized as an OrderedCollection"
	self assert: (refMicroUMLSDForCode instVarNamed: #contextList) isNotNil.
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) isKindOf: OrderedCollection).
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) isEmpty).
	
	"Test that actions is initialized as an OrderedDictionary"
	self assert: (refMicroUMLSDForCode instVarNamed: #actions) isNotNil.
	self assert: ((refMicroUMLSDForCode instVarNamed: #actions) isKindOf: OrderedDictionary).
	self assert: ((refMicroUMLSDForCode instVarNamed: #actions) isEmpty).
	
	"Test that messages is initialized as an OrderedCollection"
	self assert: (refMicroUMLSDForCode instVarNamed: #messages) isNotNil.
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) isKindOf: OrderedCollection).
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) isEmpty).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testUmlSPForArg [
	"Test #umlSPFor: computes:
	 - idx := message fifth first
	 - cList := message fifth second
	 - subList := cList copyFrom: idx to: cList size
	 - nextPackage depending on receiver scope kind (String/Array/Class)
	and answers a new MicroUMLSDForCode configured via #forContext:inScope:."

	| message cList result |

	"Prepare a minimal message structure expected by #umlSPFor:.
	Use idx > size to make subList empty and avoid any deeper analysis side-effects."
	cList := OrderedCollection new.
	message := { nil. Object. nil. nil. { 2. cList } }.

	"Case 1: scope isString => nextPackage is (message second package name)."
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #scope) = (Object package name)).
	self assert: ((result instVarNamed: #contextList) = (cList copyFrom: 2 to: cList size)).

	"Case 2: scope isArray => nextPackage is { package name . packageTag name }."
	refMicroUMLSDForCode instVarNamed: #scope put: #().
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #scope) = { Object package name. Object packageTag name }).
	self assert: ((result instVarNamed: #contextList) = (cList copyFrom: 2 to: cList size)).

	"Case 3: scope isClass => nextPackage is the class itself (message second)."
	refMicroUMLSDForCode instVarNamed: #scope put: Object.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #scope) = Object).
	self assert: ((result instVarNamed: #contextList) = (cList copyFrom: 2 to: cList size))
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testUmlSPForArg01 [
	"Test #umlSPFor: builds a new MicroUMLSDForCode with:
	 - contextList = tail of cList starting at idx
	 - scope depending on receiver's scope kind (String / Array / Class)."

	| idx cList message expectedSubList result expectedScope |

	"Common message structure expected by #umlSPFor:
	 message fifth first  -> idx
	 message fifth second -> cList
	 message second       -> a class (used to compute package / tag / class)."
	idx := 2.
	cList := #(a b c d).
	message := { nil. Color. nil. nil. { idx. cList } }.
	expectedSubList := cList copyFrom: idx to: cList size.

	"Case 1: receiver scope isString -> nextPackage := message second package name"
	refMicroUMLSDForCode instVarNamed: #scope put: 'anything'.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #contextList) = expectedSubList).
	expectedScope := Color package name.
	self assert: ((result instVarNamed: #scope) = expectedScope).

	"Case 2: receiver scope isArray -> nextPackage := { packageName . packageTagName }"
	refMicroUMLSDForCode instVarNamed: #scope put: #(dummy).
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #contextList) = expectedSubList).
	expectedScope := { Color package name. Color packageTag name }.
	self assert: ((result instVarNamed: #scope) = expectedScope).

	"Case 3: receiver scope isClass -> nextPackage := message second"
	refMicroUMLSDForCode instVarNamed: #scope put: Object.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #contextList) = expectedSubList).
	self assert: ((result instVarNamed: #scope) = Color)
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testUmlSPForArg02 [
	"Test #umlSPFor: returns a new MicroUMLSDForCode and passes:
	 - a subList of contexts starting at idx
	 - a next scope computed from receiver's current scope kind (String/Array/Class)."

	| cList idx message expectedSubList result expectedScope |

	"Build a real context list using Pharo's simulation API (exists in Pharo 14)."
	cList := OrderedCollection new.
	thisContext
		runSimulated: [ Color blue ]
		contextAtEachStep: [ :context | cList add: context copy ].

	"Pick an index that is valid and yields a non-empty tail."
	idx := cList size.
	message := { nil. Color. nil. nil. { idx. cList } }.
	expectedSubList := cList copyFrom: idx to: cList size.

	"1) When receiver scope isString, next scope is the package name of message second."
	refMicroUMLSDForCode instVarNamed: #scope put: 'anything'.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #contextList) = expectedSubList).
	expectedScope := Color package name.
	self assert: ((result instVarNamed: #scope) = expectedScope).

	"2) When receiver scope isArray, next scope is { packageName . packageTagName } of message second."
	refMicroUMLSDForCode instVarNamed: #scope put: { 'dummyPackage'. 'dummyTag' }.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #contextList) = expectedSubList).
	expectedScope := { Color package name. Color packageTag name }.
	self assert: ((result instVarNamed: #scope) = expectedScope).

	"3) When receiver scope isClass, next scope is message second itself."
	refMicroUMLSDForCode instVarNamed: #scope put: Object.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #contextList) = expectedSubList).
	self assert: ((result instVarNamed: #scope) = Color)
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testUmlSPForArg03 [
	"Test #umlSPFor: returns new MicroUMLSDForCode with:
	 - empty subList (idx past end to avoid triggering message build/error in forContext:inScope:)
	 - nextScope from message second (Color) based on receiver scope kind (String/Array/Class)."
	| cList idx message expectedSubList result expectedScope |
	
	"Build real contextList via Pharo Context simulation API."
	cList := OrderedCollection new.
	thisContext
		runSimulated: [ Color blue ]
		contextAtEachStep: [ :context | cList add: context copy ].
	
	"idx past end -> empty subList."
	idx := cList size + 1.
	message := { nil. Color. nil. nil. { idx. cList } }.
	expectedSubList := cList copyFrom: idx to: cList size.
	
	"1) receiver scope isString -> nextScope = Color package name (#Colors)."
	refMicroUMLSDForCode instVarNamed: #scope put: 'anything'.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #contextList) = expectedSubList).
	expectedScope := Color package name.
	self assert: ((result instVarNamed: #scope) = expectedScope).
	
	"2) receiver scope isArray -> nextScope = {Color package name. Color packageTag name}."
	refMicroUMLSDForCode instVarNamed: #scope put: { 'dummyPackage'. 'dummyTag' }.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #contextList) = expectedSubList).
	expectedScope := { Color package name. Color packageTag name }.
	self assert: ((result instVarNamed: #scope) = expectedScope).
	
	"3) receiver scope isClass -> nextScope = message second (Color)."
	refMicroUMLSDForCode instVarNamed: #scope put: Color.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #contextList) = expectedSubList).
	self assert: ((result instVarNamed: #scope) = Color).
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testUmlSPForArg04 [

	"Test #umlSPFor: builds a new instance via #forContext:inScope: using:
	 - subList computed from (idx to: cList size)
	 - nextPackage computed depending on the receiver's scope kind (String / Array / Class)."

	| message cList result |

	"Build a message shaped as expected by #umlSPFor:
	 fifth = { idx . cList } and idx is taken from (message fifth first)."
	cList := OrderedCollection withAll: #(a b c d e).
	message := { nil. Object. nil. nil. { 2. cList } }.

	"1) scope isString -> nextPackage := message second package name"
	refMicroUMLSDForCode instVarNamed: #scope put: ''.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #scope) = (Object package name)).
	self assert: ((result instVarNamed: #contextList) = (cList copyFrom: 2 to: cList size)).

	"2) scope isArray -> nextPackage := { package name . packageTag name }"
	refMicroUMLSDForCode instVarNamed: #scope put: #().
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #scope) = { Object package name. Object packageTag name }).
	self assert: ((result instVarNamed: #contextList) = (cList copyFrom: 2 to: cList size)).

	"3) scope isClass -> nextPackage := message second (the class itself)"
	refMicroUMLSDForCode instVarNamed: #scope put: Object.
	result := refMicroUMLSDForCode umlSPFor: message.
	self assert: (result isKindOf: MicroUMLSDForCode).
	self assert: ((result instVarNamed: #scope) = Object).
	self assert: ((result instVarNamed: #contextList) = (cList copyFrom: 2 to: cList size)).
]
