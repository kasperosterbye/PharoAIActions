Class {
	#name : 'EpLogAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refEpLog'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
EpLogAITest >> setUp [
	super setUp.
	refEpLog := EpLog new.
]

{ #category : 'AI generated test' }
EpLogAITest >> testAddEntryWithTags [
	"Test adding an entry with custom tags to the log"

	| anEvent tagsBlock newEntry oldHead |
	anEvent := EpSessionStart new.
	tagsBlock := [ :tags | tags at: #custom put: 'test' ].
	oldHead := refEpLog headReference.
	newEntry := refEpLog addEntryWith: anEvent tags: tagsBlock.
	self assert: newEntry content equals: anEvent.
	self assert: (newEntry tags at: #prior) equals: oldHead.
	self assert: (newEntry tags at: #custom) equals: 'test'.
	self assert: refEpLog entries size equals: 1.
	self assert: refEpLog entries first equals: newEntry
]

{ #category : 'AI generated test' }
EpLogAITest >> testAddEntryWithTags01 [
	"Test adding an entry with custom tags to the EpLog"

	| event customBlock result |
	event := EpSessionStart new.
	customBlock := [ :tags | tags at: #testTag put: 'testValue' ].
	result := refEpLog addEntryWith: event tags: customBlock.
	self assert: result content == event.
	self assert: (result tags at: #testTag) = 'testValue'.
	self assert: (result tags includesKey: EpLog priorReferenceKey).
	self assert: (result tags at: EpLog priorReferenceKey) == nil.
	self assert: refEpLog entries size = 1.
	self assert: refEpLog entries first content == event.
	self assert: refEpLog headReference notNil
]

{ #category : 'AI generated test' }
EpLogAITest >> testAnnounceAdded [
	| announcedEvent entry |
	announcedEvent := nil.
	refEpLog announcer
		when: EpEntryAdded
		do: [ :event | announcedEvent := event ]
		for: nil.
	entry := OmEntry new.
	refEpLog announceAdded: entry.
	self assert: announcedEvent notNil.
	self assert: announcedEvent entry equals: entry
]

{ #category : 'AI generated test' }
EpLogAITest >> testAnnounceAdded01 [
	| anEntry announcement receivedEntry |
	"Create a sample OmEntry with a simple EpExpressionEvaluation event"
	anEntry := OmEntry content: (EpExpressionEvaluation expression: '1 + 1').
	announcement := nil.
	receivedEntry := nil.
	"Subscribe to EpEntryAdded announcements on the log's announcer"
	refEpLog announcer
		when: EpEntryAdded
		do: [ :ann |
			announcement := ann.
			receivedEntry := ann entry ].
	"Call the method under test"
	refEpLog announceAdded: anEntry.
	"Verify that an announcement was sent"
	self assert: announcement notNil.
	self assert: (announcement isKindOf: EpEntryAdded).
	"Verify that the announced entry matches the input"
	self assert: receivedEntry equals: anEntry
]

{ #category : 'AI generated test' }
EpLogAITest >> testAnnouncer [
	| announcer |
	
	"Ensure the announcer instance variable is initially nil"
	self assert: (refEpLog instVarAt: 1) isNil.
	
	"Call the method to trigger lazy initialization"
	announcer := refEpLog announcer.
	
	"Verify that the returned object is an Announcer"
	self assert: announcer class equals: Announcer.
	
	"Check that the instance variable is now set to the announcer"
	self assert: (refEpLog instVarAt: 1) equals: announcer.
	
	"Verify that subsequent calls return the same instance"
	self assert: refEpLog announcer equals: announcer
]
