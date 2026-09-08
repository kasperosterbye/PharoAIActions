Class {
	#name : 'AIAHistoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAHistory',
		'rootDirectory',
		'originalHistories'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'running' }
AIAHistoryTest >> setUp [
	super setUp.
	originalHistories := AIAHistory histories copy.
	AIAHistory clearHistories.
	refAIAHistory := AIAHistory new.
	refAIAHistory class clearHistories.
	rootDirectory := FileSystem memory root / 'history'
]

{ #category : 'running' }
AIAHistoryTest >> tearDown [
	refAIAHistory class clearHistories.
	refAIAHistory class histories addAll: originalHistories.
	super tearDown
]

{ #category : 'tests' }
AIAHistoryTest >> testAddingPreHistoryAnnouncesHistoriesChanged [
	"Adding a pre-history changes the structure displayed by the history
	tree. Open presenters must therefore be notified immediately."

	| preHistory wasAnnounced |
	refAIAHistory fileStore rootDirectory: rootDirectory.

	preHistory := AIAHistory new.
	preHistory fileStore rootDirectory: rootDirectory.
	preHistory user: 'Stored pre-history'.

	wasAnnounced := false.
	[
		SystemAnnouncer uniqueInstance
			when: AIAHistoriesChanged
			do: [ wasAnnounced := true ]
			for: self.

		refAIAHistory addPreHistory: preHistory.

		self assert: wasAnnounced
	] ensure: [
		SystemAnnouncer uniqueInstance unsubscribe: self ]
]

{ #category : 'tests' }
AIAHistoryTest >> testAddingUserMessageAnnouncesReplyChanged [
	"Adding a message outside the presenter must announce the change so an
	open presenter can refresh the displayed conversation."

	| wasAnnounced |
	wasAnnounced := false.
	refAIAHistory fileStore rootDirectory: rootDirectory.

	[
		SystemAnnouncer uniqueInstance
			when: AIAReplyChanged
			do: [ wasAnnounced := true ]
			for: self.

		refAIAHistory user: 'Message added outside the UI'.

		self assert: wasAnnounced
	] ensure: [
		SystemAnnouncer uniqueInstance unsubscribe: self ]
]

{ #category : 'tests' }
AIAHistoryTest >> testApiMessageListPreservesPreHistoryOrder [
	"Pre-histories must reach the API in the order in which they were added.
	The current history follows all its pre-histories."

	| history expected |
	history := refAIAHistory.
	history fileStore rootDirectory: rootDirectory.

	1 to: 8 do: [ :index |
		| preHistory |
		preHistory := AIAHistory new.
		preHistory fileStore rootDirectory: rootDirectory.
		preHistory user: 'Context ', index asString.
		history addPreHistory: preHistory ].

	history user: 'Current prompt'.

	expected :=
		((1 to: 8) collect: [ :index |
			'Context ', index asString ])
		, #( 'Current prompt' ).

	self
		assert: (history apiMessageList collect: #value) asArray
		equals: expected
]

{ #category : 'tests' }
AIAHistoryTest >> testDefaultApiFollowsCurrentProvider [
	"A history without an explicitly assigned API must use the currently
	selected global provider. It must therefore follow provider changes."

	| originalProvider |
	originalProvider := AilienApi provider.

	[
		AilienApi provider: ClaudeApi.
		self assert: refAIAHistory api class equals: ClaudeApi.

		AilienApi provider: MistralApi.
		self assert: refAIAHistory api class equals: MistralApi
	] ensure: [
		AilienApi provider: originalProvider ]
]

{ #category : 'tests' }
AIAHistoryTest >> testExplicitApiRemainsStable [
	"Once an API instance is explicitly assigned, global provider changes
	must not alter the API used by that history."

	| originalProvider explicitApi |
	originalProvider := AilienApi provider.
	explicitApi := ClaudeApi new.
	refAIAHistory api: explicitApi.

	[
		AilienApi provider: MistralApi.
		self assert: refAIAHistory api identicalTo: explicitApi
	] ensure: [
		AilienApi provider: originalProvider ]
]

{ #category : 'tests' }
AIAHistoryTest >> testFirstMessageIsStoredWithoutAssigningFileStore [
	"A newly created history must persist its first message without the
	caller explicitly creating or assigning a file store."

	refAIAHistory fileStore rootDirectory: rootDirectory.
	refAIAHistory user: 'Automatically stored message'.

	self assert: rootDirectory files size equals: 1
]

{ #category : 'tests' }
AIAHistoryTest >> testHistoryWithOneMessagePrintsItsPrompt [
	"A history containing one user message is a valid history created by
	du. Its tree label must show that prompt rather than '> No prompt'."

	refAIAHistory fileStore rootDirectory: rootDirectory.
	refAIAHistory user: 'Single user prompt'.

	self
		assert: refAIAHistory printString
		equals: 'Single user prompt'
]

{ #category : 'tests' }
AIAHistoryTest >> testPreHistoryCycleIsRejected [
	"A history graph must remain acyclic. Adding an ancestor as a
	pre-history would create files that cannot be loaded recursively."

	| firstHistory secondHistory |
	firstHistory := refAIAHistory.
	firstHistory fileStore rootDirectory: rootDirectory.

	secondHistory := AIAHistory new.
	secondHistory fileStore rootDirectory: rootDirectory.

	firstHistory addPreHistory: secondHistory.

	self
		should: [ secondHistory addPreHistory: firstHistory ]
		raise: Error.

	self assert: secondHistory preHistories isEmpty
]

{ #category : 'tests' }
AIAHistoryTest >> testPreHistoryFromDifferentDirectoryIsRejected [
	"A pre-history reference stores only a filename. Both histories must
	therefore belong to the same history directory."

	| preHistory otherDirectory |
	refAIAHistory fileStore rootDirectory: rootDirectory.
	otherDirectory := rootDirectory parent / 'other-history'.

	preHistory := AIAHistory new.
	preHistory fileStore rootDirectory: otherDirectory.

	self
		should: [ refAIAHistory addPreHistory: preHistory ]
		raise: Error.

	self assert: refAIAHistory preHistories isEmpty
]

{ #category : 'tests' }
AIAHistoryTest >> testQPrefixIsUniqueInHistories [
	"qPrefix is a single shared history. Requesting it with another storage
	directory must not create a second qPrefix in the active histories."

	| firstPrefix secondPrefix anotherDirectory matchingPrefixes |
	anotherDirectory := rootDirectory parent / 'other-history'.

	firstPrefix := AIAHistory qPrefixIn: rootDirectory.
	secondPrefix := AIAHistory qPrefixIn: anotherDirectory.

	matchingPrefixes := AIAHistory histories select: [ :history |
		history title = 'qPrefix' ].

	self assert: firstPrefix identicalTo: secondPrefix.
	self assert: matchingPrefixes size equals: 1
]

{ #category : 'tests' }
AIAHistoryTest >> testQPrefixRecreatesMissingFile [
	"Deleting the qPrefix file externally must not leave later histories
	referring to a nonexistent file. Requesting qPrefix recreates its file."

	| qPrefix file returnedPrefix |
	qPrefix := AIAHistory qPrefixIn: rootDirectory.
	file := qPrefix fileStore fileReference.
	file delete.

	self deny: file exists.

	returnedPrefix := AIAHistory qPrefixIn: rootDirectory.

	self assert: returnedPrefix identicalTo: qPrefix.
	self assert: file exists
]

{ #category : 'tests' }
AIAHistoryTest >> testQPrefixWithoutMessagesCanBeReloadedAsPreHistory [
	"qPrefix contains context roles but no messages. It must nevertheless be
	persisted, because another stored history may reference it."

	| qPrefix current histories loadedPrefix loadedCurrent |
	qPrefix := AIAHistory qPrefixIn: rootDirectory. 

	current := refAIAHistory.
	current fileStore rootDirectory: rootDirectory.
	current addPreHistory: qPrefix.
	current user: 'A question using qPrefix'.

	self assert: qPrefix fileStore fileReference exists.

	AIAHistory clearHistories.
	AIAHistory reloadHistoriesFrom: rootDirectory.
	histories := AIAHistory histories.

	loadedPrefix := histories detect: [ :history |
		history title = 'qPrefix' ].
	loadedCurrent := histories detect: [ :history |
		history messages = current messages ].

	self assert: loadedPrefix messages isEmpty.
	self assert:
		loadedCurrent preHistories first
			identicalTo: loadedPrefix
]

{ #category : 'tests' }
AIAHistoryTest >> testReloadAnnouncesCompletedHistoryGraph [
	"Reload listeners must receive a final announcement after every history
	and pre-history relationship has been completely reconstructed."

	| preHistory currentHistory currentMessages announcementWasComplete |
	preHistory := refAIAHistory.
	preHistory fileStore rootDirectory: rootDirectory.
	preHistory user: 'Stored pre-history'.

	currentHistory := AIAHistory new.
	currentHistory fileStore rootDirectory: rootDirectory.
	currentHistory user: 'History using pre-history'.
	currentHistory addPreHistory: preHistory.
	currentMessages := currentHistory messages copy.

	announcementWasComplete := false.
	[
		SystemAnnouncer uniqueInstance
			when: AIAHistoriesChanged
			do: [
				| loadedCurrent |
				loadedCurrent := AIAHistory histories
					detect: [ :history |
						history messages = currentMessages ]
					ifNone: [ nil ].
				announcementWasComplete :=
					loadedCurrent notNil and: [
						loadedCurrent preHistories size = 1 ] ]
			for: self.

		AIAHistory clearHistories.
		AIAHistory reloadHistoriesFrom: rootDirectory.

		self assert: announcementWasComplete
	] ensure: [
		SystemAnnouncer uniqueInstance unsubscribe: self ]
]

{ #category : 'tests' }
AIAHistoryTest >> testReloadHistoriesDoesNotDuplicatePreHistories [
	"A history referenced as a pre-history also has its own file. Reloading
	must create exactly one object per file and reuse that same object in
	the reconstructed pre-history graph."

	| currentHistory preHistory currentStore preStore
	  histories loadedCurrent matchingPreHistories loadedPreHistory |

	currentStore := AIAHistoryFileStore new.
	currentStore rootDirectory: rootDirectory.

	preStore := AIAHistoryFileStore new.
	preStore rootDirectory: rootDirectory.

	preHistory := refAIAHistory class new.
	preHistory fileStore: preStore.
	preHistory user: 'Shared pre-history'.

	currentHistory := refAIAHistory.
	currentHistory fileStore: currentStore.
	currentHistory user: 'Current history'.
	currentHistory addPreHistory: preHistory.

	refAIAHistory class clearHistories.
	refAIAHistory class reloadHistoriesFrom: rootDirectory.
	histories := refAIAHistory class histories.

	loadedCurrent := histories detect: [ :each |
		each messages = currentHistory messages ].

	matchingPreHistories := histories select: [ :each |
		each messages = preHistory messages ].

	self assert: histories size equals: 2.
	self assert: matchingPreHistories size equals: 1.

	loadedPreHistory := matchingPreHistories first.
	self assert: loadedCurrent preHistories size equals: 1.
	self assert:
		loadedCurrent preHistories first == loadedPreHistory
]

{ #category : 'tests' }
AIAHistoryTest >> testReloadHistoriesRestoresAllStoredHistories [
	"Reloading must discard the current in-memory collection and reconstruct
	every stored history. File order is irrelevant; observable conversations
	must be preserved."

	| firstHistory secondHistory firstStore secondStore histories |
	firstStore := AIAHistoryFileStore new.
	firstStore rootDirectory: rootDirectory.
	secondStore := AIAHistoryFileStore new.
	secondStore rootDirectory: rootDirectory.

	firstHistory := refAIAHistory.
	firstHistory fileStore: firstStore.
	firstHistory user: 'First stored history'.

	secondHistory := AIAHistory new.
	secondHistory fileStore: secondStore.
	secondHistory user: 'Second stored history'.

	refAIAHistory class clearHistories.
	refAIAHistory class reloadHistoriesFrom: rootDirectory.
	histories := refAIAHistory class histories.

	self assert: histories size equals: 2.
	self assert: (histories anySatisfy: [ :each |
		each messages = firstHistory messages ]).
	self assert: (histories anySatisfy: [ :each |
		each messages = secondHistory messages ])
]

{ #category : 'tests' }
AIAHistoryTest >> testSamePreHistoryIsAddedOnlyOnce [
	"A repeated addition of the identical pre-history must not create
	duplicate graph edges, duplicate tree nodes or duplicate file references."

	| preHistory |
	refAIAHistory fileStore rootDirectory: rootDirectory.

	preHistory := AIAHistory new.
	preHistory fileStore rootDirectory: rootDirectory.

	refAIAHistory addPreHistory: preHistory.
	refAIAHistory addPreHistory: preHistory.

	self assert: refAIAHistory preHistories size equals: 1.
	self assert:
		refAIAHistory preHistories first
			identicalTo: preHistory
]

{ #category : 'tests' }
AIAHistoryTest >> testStoredHistoriesAreNotSilentlyDiscarded [
	"Creating many persistent histories must not silently remove older
	histories from the observable collection. Deletion is an explicit action."

	| initialSize history |
	initialSize := AIAHistory histories size.

	1 to: 25 do: [ :index |
		history := AIAHistory new.
		history fileStore rootDirectory: rootDirectory.
		history user: 'History ', index asString ].

	self
		assert: AIAHistory histories size
		equals: initialSize + 25
]
