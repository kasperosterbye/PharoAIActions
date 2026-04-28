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
	| outerMethod innerMethod outerCtx innerCtx contextList messageCandidate innerCtxCopy |
	"Create a concrete subclass instance with empty package scope so classNameCheck: always returns true"
	refMicroUMLSDForCode := MicroUMLSDForPackageCode new.
	refMicroUMLSDForCode scope: ''.
	
	"Create sample execution contexts simulating a message send from outer to inner"
	outerMethod := Number >> #negated.
	innerMethod := Number >> #abs.
	outerCtx := Context sender: nil receiver: 5 method: outerMethod arguments: #().
	innerCtx := Context sender: outerCtx receiver: 5 method: innerMethod arguments: #().
	
	"Prepare contextList with one relevant context (sender not nil)"
	contextList := OrderedCollection with: innerCtx.
	refMicroUMLSDForCode instVarNamed: #contextList put: contextList.
	refMicroUMLSDForCode instVarNamed: #messages put: OrderedCollection new.
	
	"Expected messageCandidate for the single context"
	messageCandidate := { 
		innerCtx sender methodClass. 
		innerCtx method methodClass. 
		innerCtx method selector. 
		innerCtx isReturn. 
		{ 1. contextList } 
	}.
	
	refMicroUMLSDForCode ast10BuildMessageList.
	
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) size) equals: 1.
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) first) equals: messageCandidate.
	
	"Test that duplicates (same senderClass/receiverClass/selector/isReturn) are NOT added via ast15AddCheck:"
	innerCtxCopy := innerCtx copy.
	contextList add: innerCtxCopy.
	refMicroUMLSDForCode instVarNamed: #contextList put: contextList.
	refMicroUMLSDForCode instVarNamed: #messages put: OrderedCollection new.
	refMicroUMLSDForCode ast10BuildMessageList.
	
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) size) equals: 1
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst12CheckPackageContextArg [
	| packageSD kernelMethod colorMethod senderCtx1 ctx1 senderCtx2 ctx2 senderCtx3 ctx3 emptySD senderCtx4 ctx4 |

	"Create a MicroUMLSDForPackageCode with scope 'Kernel' since
	 ast12CheckPackageContext: relies on classNameCheck: which is
	 subclassResponsibility on MicroUMLSDForCode."
	packageSD := MicroUMLSDForPackageCode new scope: 'Kernel'; yourself.

	"Pick two methods from different packages: SmallInteger>>#+  is in 'Kernel',
	 Color>>#+ is in 'Colors'."
	kernelMethod := SmallInteger >> #+.
	colorMethod := Color >> #+.

	"Case 1: sender methodClass is in Kernel, method methodClass is in Colors.
	 classNameCheck: for sender returns true (Kernel = Kernel), so result is true."
	senderCtx1 := Context sender: nil receiver: 1 method: kernelMethod arguments: #(2).
	ctx1 := Context sender: senderCtx1 receiver: Color blue method: colorMethod arguments: { Color red }.
	self assert: (packageSD ast12CheckPackageContext: ctx1).

	"Case 2: sender methodClass is in Colors, method methodClass is in Kernel.
	 classNameCheck: for sender returns false, but for method returns true, so result is true."
	senderCtx2 := Context sender: nil receiver: Color blue method: colorMethod arguments: { Color red }.
	ctx2 := Context sender: senderCtx2 receiver: 1 method: kernelMethod arguments: #(2).
	self assert: (packageSD ast12CheckPackageContext: ctx2).

	"Case 3: Both sender and method methodClass are in Colors (not Kernel).
	 classNameCheck: returns false for both, so result is false."
	senderCtx3 := Context sender: nil receiver: Color blue method: colorMethod arguments: { Color red }.
	ctx3 := Context sender: senderCtx3 receiver: Color green method: (Color >> #blue) arguments: #().
	self deny: (packageSD ast12CheckPackageContext: ctx3).

	"Case 4: Empty scope returns true for any class (classNameCheck: returns true when empty)."
	emptySD := MicroUMLSDForPackageCode new scope: ''; yourself.
	senderCtx4 := Context sender: nil receiver: Color blue method: colorMethod arguments: { Color red }.
	ctx4 := Context sender: senderCtx4 receiver: Color green method: (Color >> #blue) arguments: #().
	self assert: (emptySD ast12CheckPackageContext: ctx4)

]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst15AddCheckArg [
	| trac sameCandidate diffReturnCandidate diffFirstThreeCandidate messagesCollection |
	
	refMicroUMLSDForCode instVarNamed: #messages put: OrderedCollection new.
	
	"Test with empty messages collection, should return true"
	sameCandidate := { Object. Number. #+. false. { 1. {} } }.
	self assert: ((refMicroUMLSDForCode ast15AddCheck: sameCandidate) == true).
	
	"Test with a trace that matches first three elements and same fourth element, should return false"
	trac := { Object. Number. #+. false. { 1. {} } }.
	messagesCollection := OrderedCollection with: trac.
	refMicroUMLSDForCode instVarNamed: #messages put: messagesCollection.
	self assert: ((refMicroUMLSDForCode ast15AddCheck: sameCandidate) == false).
	
	"Test with matching first three but different fourth (isReturn true vs false), should return true"
	diffReturnCandidate := { Object. Number. #+. true. { 1. {} } }.
	self assert: ((refMicroUMLSDForCode ast15AddCheck: diffReturnCandidate) == true).
	
	"Test with different first three (different receiver class), should return true"
	diffFirstThreeCandidate := { Object. String. #asUppercase. false. { 1. {} } }.
	self assert: ((refMicroUMLSDForCode ast15AddCheck: diffFirstThreeCandidate) == true)
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst20ActionsFromMessages [
	"Test that ast20ActionsFromMessages filters out messages involving self class
	 and populates the actions dictionary with remaining classes that pass classNameCheck:."
	| messagesInput filteredMessages actions |

	"Use a concrete subclass since classNameCheck: is subclassResponsibility in MicroUMLSDForCode.
	 Set scope to empty string so classNameCheck: always returns true."
	refMicroUMLSDForCode := MicroUMLSDForPackageCode new.
	refMicroUMLSDForCode scope: ''.

	"Build test messages: each is { senderClass. receiverClass. selector. isReturn. {index. contextList} }.
	 Messages 1 and 2 are between Number and Object (should be kept).
	 Message 3 has MicroUMLSDForPackageCode as sender (should be filtered out).
	 Message 4 has MicroUMLSDForPackageCode as receiver (should be filtered out)."
	messagesInput := OrderedCollection new.
	messagesInput add: { Number. Object. #+. false. {1. OrderedCollection new} }.
	messagesInput add: { Object. Number. #new. false. {2. OrderedCollection new} }.
	messagesInput add: { MicroUMLSDForPackageCode. Number. #foo. false. {3. OrderedCollection new} }.
	messagesInput add: { Number. MicroUMLSDForPackageCode. #bar. false. {4. OrderedCollection new} }.
	refMicroUMLSDForCode instVarNamed: #messages put: messagesInput.
	refMicroUMLSDForCode instVarNamed: #actions put: OrderedDictionary new.

	"Execute the method under test"
	refMicroUMLSDForCode ast20ActionsFromMessages.

	"Verify that messages involving self class (MicroUMLSDForPackageCode) were filtered out"
	filteredMessages := refMicroUMLSDForCode instVarNamed: #messages.
	self assert: (filteredMessages size) equals: 2.
	self assert: (filteredMessages first first) equals: Number.
	self assert: (filteredMessages first second) equals: Object.
	self assert: (filteredMessages second first) equals: Object.
	self assert: (filteredMessages second second) equals: Number.

	"Verify that the actions dictionary was populated with classes from the remaining messages"
	actions := refMicroUMLSDForCode instVarNamed: #actions.
	self assert: (actions size) equals: 2.
	self assert: (actions includesKey: 'Number').
	self assert: (actions includesKey: 'Object').
	self assert: ((actions at: 'Number') == Number).
	self assert: ((actions at: 'Object') == Object).

]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst40Build [
	| actionsDict fakeContexts fakeMessage1 fakeMessage2 astBuilder actorsAndMessages actors msgs |
	
	"ast40Build calls classNameCheck: which is subclassResponsibility in MicroUMLSDForCode,
	 so we must use a concrete subclass"
	refMicroUMLSDForCode := MicroUMLSDForPackageCode new.
	refMicroUMLSDForCode instVarNamed: #packageScope put: ''.
	
	"Prepare the actions dictionary with two classes (simulates ast20ActionsFromMessages)"
	actionsDict := OrderedDictionary new.
	actionsDict at: 'Color' put: Color.
	actionsDict at: 'Point' put: Point.
	refMicroUMLSDForCode instVarNamed: #actions put: actionsDict.
	
	"Prepare fake message arrays: {senderClass. receiverClass. selector. isReturn. {index. contextList}}"
	fakeContexts := OrderedCollection new.
	fakeMessage1 := { Color. Color. #+. false. {1. fakeContexts} }.
	fakeMessage2 := { Color. Point. #asPoint. false. {2. fakeContexts} }.
	refMicroUMLSDForCode instVarNamed: #messages put: (OrderedCollection with: fakeMessage1 with: fakeMessage2).
	
	"Execute the method under test"
	refMicroUMLSDForCode ast40Build.
	
	"Retrieve the astBuilder created by ast40Build"
	astBuilder := refMicroUMLSDForCode instVarNamed: #astBuilder.
	
	"Verify astBuilder was created as a MicroUMLSDAstBuilder"
	self assert: (astBuilder isKindOf: MicroUMLSDAstBuilder).
	
	"Retrieve actors and messages via actorsAndMessages"
	actorsAndMessages := astBuilder actorsAndMessages.
	actors := actorsAndMessages first.
	msgs := actorsAndMessages second.
	
	"Verify two actors were built from the two actions entries"
	self assert: actors size equals: 2.
	self assert: (actors first name) equals: 'Color'.
	self assert: (actors second name) equals: 'Point'.
	
	"Verify two messages were built"
	self assert: msgs size equals: 2.
	
	"First message: Color -> Color (same sender/receiver) should be internal"
	self assert: (msgs first fromActor name) equals: 'Color'.
	self assert: (msgs first toActor name) equals: 'Color'.
	self assert: (msgs first messageType) equals: #internal.
	self assert: (msgs first description) equals: #+.
	
	"Second message: Color -> Point (different sender/receiver) should be a call"
	self assert: (msgs second fromActor name) equals: 'Color'.
	self assert: (msgs second toActor name) equals: 'Point'.
	self assert: (msgs second messageType) equals: #call.
	self assert: (msgs second description) equals: #asPoint

]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst41Title [
	"Test that ast41Title signals SubclassResponsibility
	as this is an abstract method to be implemented by subclasses."

	self
		should: [ refMicroUMLSDForCode ast41Title ]
		raise: SubclassResponsibility
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst43BuildActors [
	| astBuilder actors colorActor fractionActor |

	"Create an AstBuilder and inject it into refMicroUMLSDForCode"
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.

	"Populate the actions OrderedDictionary with two known classes"
	(refMicroUMLSDForCode instVarNamed: #actions)
		at: 'Color' put: Color;
		at: 'Fraction' put: Fraction.

	"Execute the method under test"
	refMicroUMLSDForCode ast43BuildActors.

	"Retrieve the actors dictionary from the astBuilder"
	actors := astBuilder instVarNamed: #actors.

	"Assert two actors were created"
	self assert: (actors size = 2).

	"Assert actors exist with the correct keys"
	self assert: (actors includesKey: 'Color').
	self assert: (actors includesKey: 'Fraction').

	"Verify the Color actor properties"
	colorActor := actors at: 'Color'.
	self assert: (colorActor name = 'Color').
	self assert: (colorActor index = 1).
	self assert: (colorActor clickAction isBlock).

	"Verify the Fraction actor properties"
	fractionActor := actors at: 'Fraction'.
	self assert: (fractionActor name = 'Fraction').
	self assert: (fractionActor index = 2).
	self assert: (fractionActor clickAction isBlock).

]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst46BuildMessages [
	"Test that ast46BuildMessages dispatches messages correctly:
	 - ast48BuildExternalMessage when both sender and receiver pass classNameCheck:
	 - ast47BuildPackageMessage when either sender or receiver fails classNameCheck:"
	| astBuilder msg1 msg2 msg3 msg4 builtMessages |

	"Use a concrete subclass since classNameCheck: is subclassResponsibility in MicroUMLSDForCode"
	refMicroUMLSDForCode := MicroUMLSDForPackageCode new.
	refMicroUMLSDForCode scope: 'Colors'.

	"Set up the astBuilder with actors already registered"
	astBuilder := MicroUMLSDAstBuilder new.
	astBuilder , 'O'.
	astBuilder , Color name.
	astBuilder , ColorMap name.
	astBuilder , Point name.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.

	"Build messages: each is {senderClass. receiverClass. selector. isReturn. methodInfo}"
	"msg1: both in scope (Colors), same class => ast48BuildExternalMessage => internal"
	msg1 := { Color. Color. 'blue'. false. { 1. OrderedCollection new } }.
	"msg2: both in scope (Colors), different classes => ast48BuildExternalMessage => call"
	msg2 := { Color. ColorMap. 'colors'. false. { 2. OrderedCollection new } }.
	"msg3: first in scope, second NOT in scope => ast47BuildPackageMessage"
	msg3 := { Color. Point. 'x'. false. { 3. OrderedCollection new } }.
	"msg4: first NOT in scope, second in scope => ast47BuildPackageMessage (return path)"
	msg4 := { Point. Color. 'alpha'. true. { 4. OrderedCollection new } }.

	refMicroUMLSDForCode instVarNamed: #messages put: (OrderedCollection withAll: { msg1. msg2. msg3. msg4 }).

	"Execute the method under test"
	refMicroUMLSDForCode ast46BuildMessages.

	"Retrieve the built messages from the astBuilder"
	builtMessages := (refMicroUMLSDForCode instVarNamed: #astBuilder) instVarNamed: #messages.

	"Verify all 4 messages were processed"
	self assert: (builtMessages size = 4).

	"msg1: Color->Color, both in scope => ast48 => internal self-call"
	self assert: (builtMessages first fromActor name = 'Color').
	self assert: (builtMessages first toActor name = 'Color').
	self assert: (builtMessages first description = 'blue').
	self assert: (builtMessages first messageType = #internal).

	"msg2: Color->ColorMap, both in scope => ast48 => call between two actors"
	self assert: ((builtMessages at: 2) fromActor name = 'Color').
	self assert: ((builtMessages at: 2) toActor name = 'ColorMap').
	self assert: ((builtMessages at: 2) description = 'colors').
	self assert: ((builtMessages at: 2) messageType = #call).

	"msg3: Color->Point, second not in scope => ast47 => internal call on Color"
	self assert: ((builtMessages at: 3) fromActor name = 'Color').
	self assert: ((builtMessages at: 3) toActor name = 'Color').
	self assert: ((builtMessages at: 3) description = 'x').
	self assert: ((builtMessages at: 3) messageType = #internal).

	"msg4: Point->Color, first not in scope => ast47 => return from Color to O"
	self assert: ((builtMessages at: 4) fromActor name = 'Color').
	self assert: ((builtMessages at: 4) toActor name = 'O').
	self assert: ((builtMessages at: 4) description = 'alpha').
	self assert: ((builtMessages at: 4) messageType = #return).

]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst47BuildPackageMessageArg [
	| astBuilder messages message msg |
	
	"Override setUp's default instance with a package-scoped variant for testing"
	refMicroUMLSDForCode := MicroUMLSDForPackageCode new scope: 'Colors'.
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.

	"--- Case 1: sender OUT of scope (Object in Kernel), receiver IN scope (Color in Colors), synchronous call ---"
	"Expects: astBuilder & 'O' -> Color name => #alpha  (a call from O to Color)"
	astBuilder , 'O'.
	astBuilder , Color name.
	message := { Object. Color. #alpha. false. nil }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	messages := astBuilder instVarNamed: #messages.
	self assert: messages size equals: 1.
	msg := messages first.
	self assert: (msg fromActor name) equals: 'O'.
	self assert: (msg toActor name) equals: Color name.
	self assert: (msg description) equals: #alpha.
	self assert: (msg messageType) equals: #call.

	"--- Case 2: sender OUT of scope, receiver IN scope, return message ---"
	"Expects: astBuilder & Color name -> 'O' --> #alpha  (a return from Color to O)"
	messages removeAll.
	message := { Object. Color. #alpha. true. nil }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	self assert: messages size equals: 1.
	msg := messages first.
	self assert: (msg fromActor name) equals: Color name.
	self assert: (msg toActor name) equals: 'O'.
	self assert: (msg description) equals: #alpha.
	self assert: (msg messageType) equals: #return.

	"--- Case 3: sender IN scope (Color), receiver anything, synchronous (internal) call ---"
	"Expects: astBuilder & Color name => #copy  (internal call on Color)"
	messages removeAll.
	message := { Color. Object. #copy. false. #someMethod }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	self assert: messages size equals: 1.
	msg := messages first.
	self assert: (msg fromActor name) equals: Color name.
	self assert: (msg toActor name) equals: Color name.
	self assert: (msg description) equals: #copy.
	self assert: (msg messageType) equals: #internal.
	self assert: (msg instVarNamed: #lastMethod) equals: #someMethod.
	self assert: (msg clickAction isNotNil).

	"--- Case 4: sender IN scope, selector is 'new' => should be ignored ---"
	messages removeAll.
	message := { Color. Object. 'new'. false. nil }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	self assert: messages size equals: 0.

	"--- Case 5: sender IN scope, selector is 'new:' => should be ignored ---"
	messages removeAll.
	message := { Color. Object. 'new:'. false. nil }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	self assert: messages size equals: 0.

	"--- Case 6: sender IN scope, return=true => no message generated (ifTrue branch does nothing) ---"
	messages removeAll.
	message := { Color. Object. #copy. true. nil }.
	refMicroUMLSDForCode ast47BuildPackageMessage: message.
	self assert: messages size equals: 0.

]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testAst48BuildExternalMessageArg [
	| astBuilder message astBuilderMessages lastMsg dummyContextList |
	dummyContextList := OrderedCollection new.

	"Test self-call: adds internal call message"
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	astBuilder , Color name.
	message := { Color. Color. #+. false. { 1. dummyContextList } }.
	refMicroUMLSDForCode ast48BuildExternalMessage: message.
	astBuilderMessages := astBuilder instVarNamed: #messages.
	self assert: astBuilderMessages size equals: 1.
	lastMsg := astBuilderMessages last.
	self assert: ((lastMsg instVarNamed: #fromActor) name) equals: Color name.
	self assert: ((lastMsg instVarNamed: #toActor) name) equals: Color name.
	self assert: (lastMsg instVarNamed: #description) equals: #+.
	self assert: (lastMsg instVarNamed: #messageType) equals: #internal.

	"Test self-return: no message added"
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	astBuilder , Color name.
	message := { Color. Color. #+. true. { 1. dummyContextList } }.
	refMicroUMLSDForCode ast48BuildExternalMessage: message.
	astBuilderMessages := astBuilder instVarNamed: #messages.
	self assert: astBuilderMessages isEmpty.

	"Test external call: adds call from sender to receiver"
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	astBuilder , Color name.
	astBuilder , Point name.
	message := { Color. Point. #color. false. { 1. dummyContextList } }.
	refMicroUMLSDForCode ast48BuildExternalMessage: message.
	astBuilderMessages := astBuilder instVarNamed: #messages.
	self assert: astBuilderMessages size equals: 1.
	lastMsg := astBuilderMessages last.
	self assert: ((lastMsg instVarNamed: #fromActor) name) equals: Color name.
	self assert: ((lastMsg instVarNamed: #toActor) name) equals: Point name.
	self assert: (lastMsg instVarNamed: #description) equals: #color.
	self assert: (lastMsg instVarNamed: #messageType) equals: #call.

	"Test external return: adds return from receiver to sender"
	astBuilder := MicroUMLSDAstBuilder new.
	refMicroUMLSDForCode instVarNamed: #astBuilder put: astBuilder.
	astBuilder , Point name.
	astBuilder , Color name.
	message := { Color. Point. #color. true. { 1. dummyContextList } }.
	refMicroUMLSDForCode ast48BuildExternalMessage: message.
	astBuilderMessages := astBuilder instVarNamed: #messages.
	self assert: astBuilderMessages size equals: 1.
	lastMsg := astBuilderMessages last.
	self assert: ((lastMsg instVarNamed: #fromActor) name) equals: Point name.
	self assert: ((lastMsg instVarNamed: #toActor) name) equals: Color name.
	self assert: (lastMsg instVarNamed: #description) equals: #color.
	self assert: (lastMsg instVarNamed: #messageType) equals: #return
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testClassNameCheckArg [
	| wasRaised |
	"Test that classNameCheck: raises SubclassResponsibilityError since MicroUMLSDForCode is abstract and delegates to subclasses."
	wasRaised := false.
	[ refMicroUMLSDForCode classNameCheck: Object ]
		on: SubclassResponsibility
		do: [ :signal | wasRaised := true ].
	self assert: (wasRaised)
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testEmptyPackageTestForArg [
	"Test emptyPackageTestFor: returns true for normal classes like Object"
	self assert: (refMicroUMLSDForCode emptyPackageTestFor: Object) equals: true.
	
	"Test emptyPackageTestFor: returns false for self class (MicroUMLSDForCode)"
	self assert: (refMicroUMLSDForCode emptyPackageTestFor: refMicroUMLSDForCode class) equals: false.
	
	"Test emptyPackageTestFor: returns false for BlockClosure"
	self assert: (refMicroUMLSDForCode emptyPackageTestFor: BlockClosure) equals: false.
	
	"Test emptyPackageTestFor: returns false for a BlockClosure subclass like CleanBlockClosure"
	self assert: (refMicroUMLSDForCode emptyPackageTestFor: CleanBlockClosure) equals: false.
	
	"Test emptyPackageTestFor: returns false for Context"
	self assert: (refMicroUMLSDForCode emptyPackageTestFor: Context) equals: false.
	
	"Test emptyPackageTestFor: returns false for UndefinedObject"
	self assert: (refMicroUMLSDForCode emptyPackageTestFor: UndefinedObject) equals: false
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testForBlockArg [
	| contextList |
	"Verify that contextList is initially empty after setUp"
	contextList := refMicroUMLSDForCode instVarNamed: #contextList.
	self assert: (contextList size) equals: 0.

	"Call forBlock: with a simple block. forCode will raise SubclassResponsibility
	 because classNameCheck: is abstract in MicroUMLSDForCode. We catch it."
	[ refMicroUMLSDForCode forBlock: [ 1 + 2 ] ]
		on: SubclassResponsibility
		do: [ :ex | "Expected: base class cannot complete forCode" ].

	"Retrieve contextList after simulation"
	contextList := refMicroUMLSDForCode instVarNamed: #contextList.

	"Verify contextList is an OrderedCollection"
	self assert: (contextList isKindOf: OrderedCollection).

	"Verify contextList was populated with simulation contexts"
	self assert: (contextList isNotEmpty).

	"Verify every element in contextList is a Context"
	self assert: (contextList allSatisfy: [ :each | each isKindOf: Context ]).

]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testForCode [
	| packageSd contexts astBuilder |
	packageSd := MicroUMLSDForCode forScope: ''.
	"Create contexts from a simple arithmetic expression matching the class example"
	contexts := OrderedCollection new.
	thisContext
		runSimulated: [ (2 / 3) + (4 / 7) ]
		contextAtEachStep: [ :context | contexts add: context copy ].
	"Set the captured contexts into the instance"
	packageSd instVarNamed: #contextList put: contexts.
	"Verify messages collection is empty before forCode execution"
	self assert: ((packageSd instVarNamed: #messages) size) equals: 0.
	"Execute the method under test. Note: this opens a Roassal UI window due to renderDiagram"
	packageSd forCode.
	"Retrieve the built AST builder and verify it has actors and messages"
	astBuilder := packageSd instVarNamed: #astBuilder.
	self assert: astBuilder notNil.
	self assert: ((astBuilder actorsAndMessages first) size) >= 1.
	self assert: ((astBuilder actorsAndMessages second) size) >= 1
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testForContextArg [
	| contexts packageSd astBuilder |
	"Generate a context list by simulating a simple arithmetic block"
	contexts := OrderedCollection new.
	thisContext
		runSimulated: [ (2 / 3) + (4 / 7) ]
		contextAtEachStep: [ :context | contexts add: context copy ].

	"Test 1: On the base class (refMicroUMLSDForCode), forContext: sets contextList
	 but forCode raises SubclassResponsibility because classNameCheck: is abstract"
	[ refMicroUMLSDForCode forContext: contexts ]
		on: SubclassResponsibility
		do: [ :ex | "Expected: base class cannot complete forCode" ].

	"Verify contextList was assigned to the provided contexts collection"
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) == contexts).

	"Verify the contextList is an OrderedCollection and is not empty"
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) isKindOf: OrderedCollection).
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) isNotEmpty).

	"Test 2: On a concrete subclass (MicroUMLSDForPackageCode via forScope:),
	 forContext: completes the full forCode pipeline"
	packageSd := MicroUMLSDForCode forScope: ''.
	packageSd forContext: contexts.

	"Verify contextList was assigned"
	self assert: ((packageSd instVarNamed: #contextList) == contexts).

	"Verify astBuilder was created during forCode"
	astBuilder := packageSd instVarNamed: #astBuilder.
	self assert: (astBuilder notNil).
	self assert: (astBuilder isKindOf: MicroUMLSDAstBuilder).

	"Verify the pipeline produced actors and messages"
	self assert: ((astBuilder actorsAndMessages first) size >= 1).
	self assert: ((astBuilder actorsAndMessages second) size >= 1).

	"Verify messages and actions were populated"
	self assert: ((packageSd instVarNamed: #messages) isKindOf: OrderedCollection).
	self assert: ((packageSd instVarNamed: #actions) isKindOf: OrderedDictionary).
	self assert: ((packageSd instVarNamed: #actions) isNotEmpty).

]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testInitialize [
	"Test that initialize properly sets up contextList, actions, and messages instance variables."

	"Verify contextList is an OrderedCollection and is empty after initialization."
	self assert: ((refMicroUMLSDForCode instVarNamed: #contextList) isKindOf: OrderedCollection).
	self assert: (refMicroUMLSDForCode instVarNamed: #contextList) isEmpty.

	"Verify actions is an OrderedDictionary and is empty after initialization."
	self assert: ((refMicroUMLSDForCode instVarNamed: #actions) isKindOf: OrderedDictionary).
	self assert: (refMicroUMLSDForCode instVarNamed: #actions) isEmpty.

	"Verify messages is an OrderedCollection and is empty after initialization."
	self assert: ((refMicroUMLSDForCode instVarNamed: #messages) isKindOf: OrderedCollection).
	self assert: (refMicroUMLSDForCode instVarNamed: #messages) isEmpty.
]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testOpenSubDiagramForArg [
	"Test that openSubDiagramFor: on MicroUMLSDForCode raises SubclassResponsibility,
	 since it is an abstract method that subclasses must implement."

	self
		should: [ refMicroUMLSDForCode openSubDiagramFor: nil ]
		raise: SubclassResponsibility

]

{ #category : 'AI generated test' }
MicroUMLSDForCodeAITest >> testScopeArg [
	"Test that scope: on MicroUMLSDForCode raises SubclassResponsibility,
	 since it is an abstract method that subclasses must implement."
	| packageCodeObj classCodeObj |

	"Calling scope: on the abstract base class should raise SubclassResponsibility"
	self should: [ refMicroUMLSDForCode scope: 'SomeScope' ] raise: SubclassResponsibility.

	"Verify that the concrete subclass MicroUMLSDForPackageCode properly handles scope:"
	packageCodeObj := MicroUMLSDForPackageCode new.
	packageCodeObj scope: 'TestPackage'.
	self assert: (packageCodeObj instVarNamed: #packageScope) equals: 'TestPackage'.

	"Verify that the concrete subclass MicroUMLSDForClassCode properly handles scope:"
	classCodeObj := MicroUMLSDForClassCode new.
	classCodeObj scope: Color.
	self assert: (classCodeObj instVarNamed: #classScope) equals: Color.

]
