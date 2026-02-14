Class {
	#name : 'MicTocBuilderAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicTocBuilder'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicTocBuilderAITest >> setUp [
	super setUp.
	refMicTocBuilder := MicTocBuilder new.
]

{ #category : 'AI generated test' }
MicTocBuilderAITest >> testInitialize [
	"Test that MicTocBuilder is properly initialized."

	"Exercise initialize"
	refMicTocBuilder initialize.

	"Check that tocItems is created and is empty"
	self assert: refMicTocBuilder tocItems isEmpty.

	"Check that tocItems is an OrderedCollection"
	self assert: refMicTocBuilder tocItems class equals: OrderedCollection.

	"Check that headerStack is created and is empty"
	self assert: refMicTocBuilder headerStack isEmpty.

	"Check that headerStack is a Stack"
	self assert: refMicTocBuilder headerStack class equals: Stack.

	"Check that limit is initialized to 6"
	self assert: refMicTocBuilder limit equals: 6
]

{ #category : 'AI generated test' }
MicTocBuilderAITest >> testLimitUpTo [
	"MUST use refMicTocBuilder from setUp, do not redeclare it"

	"Valid limits between 1 and 5 should be accepted"
	refMicTocBuilder limitUpTo: 1.
	refMicTocBuilder limitUpTo: 5.

	"Invalid limits should raise an Error"
	self
		should: [ refMicTocBuilder limitUpTo: 0 ]
		raise: Error;
		should: [ refMicTocBuilder limitUpTo: 6 ]
		raise: Error;
		should: [ refMicTocBuilder limitUpTo: -1 ]
		raise: Error
]

{ #category : 'AI generated test' }
MicTocBuilderAITest >> testToc [
	"Test that toc returns a MicRootBlock containing a MicOrderedListBlock
	 with children built from refMicTocBuilder tocItems."

	| result rootChildren listBlock |
	"Exercise the toc method"
	result := refMicTocBuilder toc.

	"Result should be a MicRootBlock"
	self assert: result class equals: MicRootBlock.

	"Root block should have exactly one child"
	rootChildren := result children.
	self assert: rootChildren size equals: 1.

	"That single child should be a MicOrderedListBlock"
	listBlock := rootChildren first.
	self assert: listBlock class equals: MicOrderedListBlock.

	"Children of the list block should be the tocItems of the builder"
	self assert: listBlock children equals: refMicTocBuilder tocItems.
]

{ #category : 'AI generated test' }
MicTocBuilderAITest >> testTocItems [
	"Test that tocItems initially answers nil."
	
	"Assert initial value is nil"
	self assert: refMicTocBuilder tocItems isEmpty.

	"Assign a value to tocItems and check it is returned"
	refMicTocBuilder instVarNamed: 'tocItems' put: #('a' 'b').
	self assert: refMicTocBuilder tocItems equals: #('a' 'b').
]

{ #category : 'AI generated test' }
MicTocBuilderAITest >> testVisitHeader [
	| header1 header2 header3 |
	"Test adding a level 1 header when stack is empty"
	header1 := MicHeaderBlock new addLineAndReturnNextNode: '# Level 1 Header'.
	refMicTocBuilder visitHeader: header1.
	self assert: refMicTocBuilder tocItems size equals: 1.
	self assert: (refMicTocBuilder tocItems first level) equals: 1.
	self assert: refMicTocBuilder headerStack size equals: 1.

	"Test adding a child level 2 header"
	header2 := MicHeaderBlock new addLineAndReturnNextNode: '## Level 2 Header'.
	refMicTocBuilder visitHeader: header2.
	self assert: refMicTocBuilder tocItems size equals: 1.
	self assert: (refMicTocBuilder tocItems first children size) equals: 1.
	self assert: refMicTocBuilder headerStack size equals: 2.
	self assert: (refMicTocBuilder headerStack top level) equals: 2.

	"Test skipping a level 3 header when limit is set to 1"
	refMicTocBuilder limitUpTo: 1.
	header3 := MicHeaderBlock new addLineAndReturnNextNode: '### Level 3 Header'.
	refMicTocBuilder visitHeader: header3.
	self assert: refMicTocBuilder tocItems size equals: 1.
	self assert: (refMicTocBuilder tocItems first children size) equals: 1.
	self assert: refMicTocBuilder headerStack size equals: 2
]
