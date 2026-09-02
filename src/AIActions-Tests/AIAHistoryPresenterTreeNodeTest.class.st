Class {
	#name : 'AIAHistoryPresenterTreeNodeTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAHistoryPresenterTreeNode',
		'originalHistories',
		'refAIAHistory'
	],
	#category : 'AIActions-Tests-UIPresenters-Tests',
	#package : 'AIActions-Tests',
	#tag : 'UIPresenters-Tests'
}

{ #category : 'running' }
AIAHistoryPresenterTreeNodeTest >> setUp [
	super setUp.
	originalHistories := AIAHistory histories copy.
	AIAHistory clearHistories.

	refAIAHistory := AIAHistory new.
	refAIAHistoryPresenterTreeNode :=
		AIAHistoryPresenterTreeNode rootFor: refAIAHistory
]

{ #category : 'running' }
AIAHistoryPresenterTreeNodeTest >> tearDown [
	AIAHistory clearHistories.
	AIAHistory histories addAll: originalHistories.
	super tearDown
]

{ #category : 'tests' }
AIAHistoryPresenterTreeNodeTest >> testNestedPreHistoriesRemainNestedReferences [
	"The tree projection must preserve every pre-history level. All nested
	occurrences are references, regardless of their depth."

	| firstPreHistory secondPreHistory firstNode secondNode memoryDirectory |
	memoryDirectory := FileSystem memory root / 'history'.

	firstPreHistory := AIAHistory new.
	firstPreHistory fileStore rootDirectory: memoryDirectory.

	secondPreHistory := AIAHistory new.
	secondPreHistory fileStore rootDirectory: memoryDirectory.
	secondPreHistory addPreHistory: firstPreHistory.

	refAIAHistory fileStore rootDirectory: memoryDirectory.
	refAIAHistory addPreHistory: secondPreHistory.

	secondNode := refAIAHistoryPresenterTreeNode children first.
	firstNode := secondNode children first.

	self assert: secondNode history identicalTo: secondPreHistory.
	self assert: secondNode isReference.
	self assert: firstNode history identicalTo: firstPreHistory.
	self assert: firstNode isReference
]

{ #category : 'tests' }
AIAHistoryPresenterTreeNodeTest >> testPreHistoryBecomesReferenceChild [
	"A pre-history must appear below its owning history as a read-only
	reference to the same history object."

	| preHistory children child memoryDirectory |
	memoryDirectory := FileSystem memory root / 'history'.

	preHistory := AIAHistory new.
	preHistory fileStore rootDirectory: memoryDirectory.
	refAIAHistory fileStore rootDirectory: memoryDirectory.
	refAIAHistory addPreHistory: preHistory.

	children := refAIAHistoryPresenterTreeNode children.

	self assert: children size equals: 1.
	child := children first.
	self assert: child history identicalTo: preHistory.
	self assert: child isReference
]

{ #category : 'tests' }
AIAHistoryPresenterTreeNodeTest >> testRootNodeRepresentsEditableHistory [
	"A root node represents the canonical occurrence of a stored history.
	It must therefore expose that history and not identify itself as a
	read-only reference."

	self
		assert: refAIAHistoryPresenterTreeNode history
		identicalTo: refAIAHistory.
	self deny: refAIAHistoryPresenterTreeNode isReference
]
