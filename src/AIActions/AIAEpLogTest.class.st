Class {
	#name : 'AIAEpLogTest',
	#superclass : 'TestCase',
	#instVars : [
		'log',
		'logBuilder'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'running' }
AIAEpLogTest >> setUp [
	super setUp.

	logBuilder := EpTestLogBuilder new.
	log := logBuilder oneTriggerWithFourChildrenLog
]

{ #category : 'running' }
AIAEpLogTest >> tearDown [

	logBuilder cleanUp.
	super tearDown
]

{ #category : 'tests' }
AIAEpLogTest >> testEntriesForAll [
	| entries references |
	entries := log entries.
	references := log entryReferences.
	self assert: (log entriesForAll: references) equals: entries
]

{ #category : 'running' }
AIAEpLogTest >> testHead [
	| expectedHead |
	expectedHead := log entries last.
	self assert: log head equals: expectedHead
]

{ #category : 'running' }
AIAEpLogTest >> testIsEmpty [
	"Test that the log is correctly identified as empty when it has no entries.
	 The test ensures that the log is empty initially and that it is no longer empty after adding an entry."

	"Create a new log instance"
	log := EpLog newWithStore: (OmMemoryStore new).

	"Test that the log is empty initially"
	self assert: log isEmpty.

	"Add an entry to the log"
	log addEntryWith: (EpExpressionEvaluation expression: 'test') tags: [ :tags | ].

	"Test that the log is no longer empty after adding an entry"
	self deny: log isEmpty.
]
