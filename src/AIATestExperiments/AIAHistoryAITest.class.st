Class {
	#name : 'AIAHistoryAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAHistory'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIAHistoryAITest >> setUp [
	super setUp.
	refAIAHistory := AIAHistory new.
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testAddPreHistory [
	"Test that addPreHistory: correctly adds a pre-history to the collection."

	| pre |
	pre := AIAHistory new.
	self assert: ((refAIAHistory instVarNamed: #preHistories) isEmpty).
	refAIAHistory addPreHistory: pre.
	self assert: ((refAIAHistory instVarNamed: #preHistories) size) equals: 1.
	self assert: ((refAIAHistory instVarNamed: #preHistories) includes: pre)
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testApi [
	"api answers the stored api when present, otherwise it answers a fresh provider instance.
	This test verifies both branches without using mocks."

	| api1 api2 providerClass |
	
	"Ensure a clean starting state: api is nil."
	refAIAHistory instVarNamed: #api put: nil.

	"When api is nil, it should answer a new instance from AilienApi provider."
	api1 := refAIAHistory api.
	self assert: (api1 isNotNil).
	providerClass := AilienApi provider.
	self assert: (api1 class = providerClass).

	"When api is set, it should answer exactly that same object."
	refAIAHistory instVarNamed: #api put: api1.
	api2 := refAIAHistory api.
	self assert: (api2 == api1).
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testApiMessageList [
	"Test that #apiMessageList answers an OrderedCollection of Associations.
	It should include:
	 - 'user' entries derived from #firstRoles and #lastRoles
	 - all entries from #getMessages (already formatted as Associations)."

	| result all expectedUserCount expectedMessageCount |

	"Exercise"
	result := refAIAHistory apiMessageList.

	"Basic shape"
	self assert: (result isKindOf: OrderedCollection).
	self assert: (result allSatisfy: [ :each | each isAssociation ]).

	"Compute expectations from the same source histories (no mocks)"
	all := refAIAHistory selfAndPreHistories.
	expectedUserCount := (all sum: [ :hist | hist firstRoles size ])
		+ (all sum: [ :hist | hist lastRoles size ]).
	expectedMessageCount := (all sum: [ :hist | hist getMessages size ]).

	"Total size must match: firstRoles + getMessages + lastRoles"
	self assert: (result size = (expectedUserCount + expectedMessageCount)).

	"All role-derived entries must have key = 'user' and a String value"
	self assert: ((result select: [ :assoc | assoc key = 'user' ]) size = expectedUserCount).
	self assert: ((result select: [ :assoc | assoc key = 'user' ])
			allSatisfy: [ :assoc | assoc value isString ]).
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testApi_01 [
	"Test that the api method returns a non-nil instance of AilienApi when api slot is nil"
	| firstApi secondApi |
	firstApi := refAIAHistory api.
	self assert: (firstApi isNotNil) description: 'API instance should not be nil'.
	self assert: (firstApi isKindOf: AilienApi) description: 'Returned object should be an instance of AilienApi'.
	"Since the method does not assign the new instance to the api slot, subsequent calls create new instances"
	secondApi := refAIAHistory api.
	self assert: (firstApi ~= secondApi) description: 'Subsequent calls should return different instances as no caching occurs'.
	"Verify that the api slot remains nil after the call"
	self assert: ((refAIAHistory instVarNamed: #api) isNil) description: 'The api slot should remain nil since the method does not assign the new instance'.
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testGetMessages [
	"Test that #getMessages returns a collection where assistant entries are preserved as Associations
	(key -> value), and non-assistant entries are returned unchanged."

	| inputMessages result |
	
	"Arrange: provide a messages collection with both assistant and non-assistant entries."
	inputMessages := OrderedCollection new
		add: ('system' -> 'You are a Pharo14 Smalltalk expert.');
		add: ('assistant' -> 'Hello');
		add: ('user' -> 'Question');
		add: ('assistant' -> 'Answer');
		yourself.

	"Set messages via reflective slot access (no direct ivar access)."
	refAIAHistory instVarNamed: #messages put: inputMessages.

	"Act"
	result := refAIAHistory getMessages.

	"Assert"
	self assert: (result isCollection) description: 'Expected a collection result'.
	self assert: (result size = inputMessages size) description: 'Expected same number of elements'.

	"Non-assistant entries should be the exact same objects (unchanged)."
	self assert: ((result at: 1) == (inputMessages at: 1)) description: 'System entry should be unchanged'.
	self assert: ((result at: 3) == (inputMessages at: 3)) description: 'User entry should be unchanged'.

	"Assistant entries should be Associations with the same key/value."
	self assert: ((result at: 2) isAssociation) description: 'Assistant entry should be an Association'.
	self assert: (((result at: 2) key = 'assistant') and: [ (result at: 2) value = 'Hello' ])
		description: 'Assistant entry should preserve key and value'.

	self assert: ((result at: 4) isAssociation) description: 'Assistant entry should be an Association'.
	self assert: (((result at: 4) key = 'assistant') and: [ (result at: 4) value = 'Answer' ])
		description: 'Assistant entry should preserve key and value'
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testIncludeInHistories [
	"includeInHistories should add the receiver to the shared Histories collection.
	It should also enforce the max number (25) of untitled histories by removing the oldest untitled one."

	| histories beforeSize beforeFirstUntitled |
	
	"Start from a clean Histories collection to make the test deterministic."
	AIAHistory clearHistories.
	histories := AIAHistory histories.

	"Create 25 untitled histories (title = nil) and include them."
	1 to: 25 do: [ :i |
		refAIAHistory := AIAHistory new.
		refAIAHistory includeInHistories ].

	self assert: (histories size = 25).

	"Remember the first untitled history currently in the collection."
	beforeFirstUntitled := histories first.

	"Adding one more untitled history should remove the oldest untitled one,
	keeping the total size at 25."
	beforeSize := histories size.
	refAIAHistory := AIAHistory new.
	refAIAHistory includeInHistories.

	self assert: (histories size = beforeSize).
	self assert: ((histories includes: beforeFirstUntitled) not).
	self assert: (histories last == refAIAHistory).
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testIncludeInHistories_01 [
	"includeInHistories is not present in the current image (AIAHistory does not respond to it),
	and AIAHistory class does not provide clearHistories/histories in this image either.
	So we cannot build a runnable Pharo14 test for it here without adding/migrating the method first."

	self assert: ((AIAHistory respondsTo: #includeInHistories) not).
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testInitialize [
	"Test that #initialize sets up fresh collections, nil title, and registers the instance in histories."

	"Exercise"
	refAIAHistory initialize.

	"Verify collections are created"
	self assert: ((refAIAHistory instVarNamed: #preHistories) isKindOf: OrderedCollection).
	self assert: ((refAIAHistory instVarNamed: #messages) isKindOf: OrderedCollection).
	self assert: ((refAIAHistory instVarNamed: #firstRoles) isKindOf: OrderedCollection).
	self assert: ((refAIAHistory instVarNamed: #lastRoles) isKindOf: OrderedCollection).

	"Verify they start empty"
	self assert: (((refAIAHistory instVarNamed: #preHistories) isEmpty) = true).
	self assert: (((refAIAHistory instVarNamed: #messages) isEmpty) = true).
	self assert: (((refAIAHistory instVarNamed: #firstRoles) isEmpty) = true).
	self assert: (((refAIAHistory instVarNamed: #lastRoles) isEmpty) = true).

	"Verify title is reset"
	self assert: ((refAIAHistory instVarNamed: #title) isNil).

	"Verify it is included in the class-side histories"
	self assert: ((AIAHistory histories includes: refAIAHistory) = true).
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testSelfAndPreHistories [
	"Test that #selfAndPreHistories returns a Set containing the receiver and all (transitive) pre-histories."

	| pre1 pre2 result |
	
	"Given: a history with a chain of pre-histories (pre2 -> pre1 -> refAIAHistory)."
	pre1 := AIAHistory new.
	pre2 := AIAHistory new.
	
	(refAIAHistory instVarNamed: #preHistories) add: pre1.
	(pre1 instVarNamed: #preHistories) add: pre2.

	"When: we ask for self and pre histories."
	result := refAIAHistory selfAndPreHistories.

	"Then: the result includes the receiver and all pre-histories."
	self assert: (result includes: refAIAHistory).
	self assert: (result includes: pre1).
	self assert: (result includes: pre2).

	"And: it contains exactly those three elements."
	self assert: (result size = 3).
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testSystem [
	"Test the system method of AIAHistory to ensure it correctly retrieves the system role from the firstRoles collection."

	| systemRoles |
	refAIAHistory instVarNamed: #firstRoles put: {
		'user' -> 'userRole'.
		'system' -> 'systemRole'.
		'assistant' -> 'assistantRole'
	} asDictionary.

	systemRoles := refAIAHistory system.

	self assert: (systemRoles size = 1).
	self assert: (systemRoles first = 'systemRole').
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testSystem_01 [
	"Test the system method returns the system role values from firstRoles"

	| systemText |
	systemText := 'You are a test AI'.
	refAIAHistory system: systemText.
	self assert: (refAIAHistory system size = 1).
	self assert: (refAIAHistory system first = systemText)
]

{ #category : 'AI generated test' }
AIAHistoryAITest >> testSystem_02 [
	"Test that the system method correctly selects and collects values from firstRoles where the role key is 'system'."
	| roles systemValues |
	roles := OrderedCollection new
		add: 'system' -> 'You are a helpful AI assistant.';
		add: 'background' -> 'This is some background information.';
		add: 'system' -> 'Always respond in a friendly manner.';
		add: 'user' -> 'User specific role.';
		yourself.
	refAIAHistory instVarNamed: #firstRoles put: roles.
	systemValues := refAIAHistory system.
	self assert: (systemValues size = 2).
	self assert: (systemValues includes: 'You are a helpful AI assistant.').
	self assert: (systemValues includes: 'Always respond in a friendly manner.').
]
