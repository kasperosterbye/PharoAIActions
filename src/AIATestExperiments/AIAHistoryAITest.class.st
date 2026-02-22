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
AIAHistoryAITest >> testApi_02 [
	| firstApi secondApi |
	"Retrieve the API instance first time, should create it since slot is nil"
	firstApi := refAIAHistory api.
	self assert: (firstApi notNil).
	self assert: (firstApi isKindOf: GrokApiWithTools).
	"Verify the slot is still nil, no assignment happened"
	self assert: ((refAIAHistory instVarNamed: #api) isNil).
	"Second call should create a new instance, no caching"
	secondApi := refAIAHistory api.
	self assert: (secondApi notNil).
	self assert: (secondApi isKindOf: GrokApiWithTools).
	self deny: (firstApi == secondApi).
	"Slot still nil"
	self assert: ((refAIAHistory instVarNamed: #api) isNil)
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
