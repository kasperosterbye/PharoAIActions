Class {
	#name : 'AIAHistoryFileStoreAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAHistoryFileStore'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIAHistoryFileStoreAITest >> setUp [
	super setUp.
	refAIAHistoryFileStore := AIAHistoryFileStore new.
]

{ #category : 'AI generated test' }
AIAHistoryFileStoreAITest >> testAssociationFromRoleDictionaryArg [
	"Test that associationFromRoleDictionary: converts a role/content dictionary into an association"
	| dict result |
	dict := Dictionary new.
	dict at: 'role' put: 'user'.
	dict at: 'content' put: 'hello'.
	result := refAIAHistoryFileStore associationFromRoleDictionary: dict.
	self assert: (result key = 'user').
	self assert: (result value = 'hello')
]

{ #category : 'AI generated test' }
AIAHistoryFileStoreAITest >> testFileName [
	"Set createdAt to a fixed DateAndTime with a known timezone offset, then
	verify fileName builds the expected 'YYYYMMDD-HHMMSS-<chars21to25>.json' string.
	Note: createdString is createdAt asString (e.g. '2025-01-15T09:05:07+02:00'),
	so characters 21 to 25 yield '02:00' from the offset part."

	| expected |
	"Fix createdAt so fileName is deterministic"
	refAIAHistoryFileStore
		instVarNamed: #createdAt
		put: (DateAndTime
				 year: 2025
				 month: 1
				 day: 15
				 hour: 9
				 minute: 5
				 second: 7
				 offset: (Duration hours: 2)).

	"date=20250115, time=090507, shortId=02:00 (chars 21..25 of the asString)"
	expected := '20250115-090507-02:00.json'.

	self assert: (refAIAHistoryFileStore fileName = expected)

]

{ #category : 'AI generated test' }
AIAHistoryFileStoreAITest >> testFileReference [
	"Test fileReference builds path from class rootDirectory / instance fileName"
	| expected |
	expected := AIAHistoryFileStore rootDirectory / refAIAHistoryFileStore fileName.
	self assert: (refAIAHistoryFileStore fileReference = expected)
]

{ #category : 'AI generated test' }
AIAHistoryFileStoreAITest >> testHistoryFromJsonArg [
	"Test that historyFromJson: correctly parses a JSON string and builds an AIAHistory.
	 The provider must be a concrete AilienApi subclass (e.g. MistralApi), since the
	 method checks AilienApi allSubclasses includes: the provider class."

	| jsonString history |
	"Build a JSON string with one firstRole, one message and no lastRoles"
	jsonString := '{"preHistoryIds":[],"createdAt":"2024-01-01T00:00:00","modifiedAt":"2024-01-02T00:00:00","provider":"MistralApi","model":"test-model","title":"Test Title","responseHeaderLevel":2,"firstRoles":[{"role":"system","content":"be nice"}],"messages":[{"role":"user","content":"hi"}],"lastRoles":[]}'.
	"Parse the JSON via the file store held in the instance variable"
	history := refAIAHistoryFileStore historyFromJson: jsonString.
	"The result is an AIAHistory"
	self assert: (history isKindOf: AIAHistory).
	"Scalar properties are read from the dictionary"
	self assert: (history title = 'Test Title').
	self assert: (history responseHearderLevel = 2).
	"The api is an instance of the named concrete provider, configured with the model"
	self assert: (history api isKindOf: MistralApi).
	self assert: (history api model = 'test-model').
	"The history points back to the file store that created it"
	self assert: (history fileStore == refAIAHistoryFileStore).
	"createdAt and modifiedAt are stored on the file store as DateAndTime"
	self assert: ((refAIAHistoryFileStore instVarNamed: #createdAt) = (DateAndTime fromString: '2024-01-01T00:00:00')).
	self assert: ((refAIAHistoryFileStore instVarNamed: #modifiedAt) = (DateAndTime fromString: '2024-01-02T00:00:00')).
	"firstRoles and messages become role -> content associations; lastRoles stays empty"
	self assert: (history firstRoles asArray = { 'system' -> 'be nice' }).
	self assert: (history messages asArray = { 'user' -> 'hi' }).
	self assert: ((history instVarNamed: #lastRoles) isEmpty)

]

{ #category : 'AI generated test' }
AIAHistoryFileStoreAITest >> testInitialize [
	"Test that initialize sets createdAt and modifiedAt correctly via super initialize and DateAndTime now"
	self assert: ((refAIAHistoryFileStore instVarNamed: #createdAt) isKindOf: DateAndTime).
	self assert: ((refAIAHistoryFileStore instVarNamed: #modifiedAt) isKindOf: DateAndTime).
	self assert: ((refAIAHistoryFileStore instVarNamed: #createdAt) = (refAIAHistoryFileStore instVarNamed: #modifiedAt))
]

{ #category : 'AI generated test' }
AIAHistoryFileStoreAITest >> testJsonFromHistoryArg [
	"Test that jsonFromHistory: converts an AIAHistory into a JSON string
	 containing the file store's createdAt/modifiedAt and the history's
	 scalar properties and role/message associations."

	| history json parsed |
	"Fix createdAt and modifiedAt on the file store so the JSON is deterministic"
	refAIAHistoryFileStore
		instVarNamed: #createdAt
		put: (DateAndTime fromString: '2024-01-01T00:00:00').
	refAIAHistoryFileStore
		instVarNamed: #modifiedAt
		put: (DateAndTime fromString: '2024-01-02T00:00:00').

	"Build an AIAHistory with a concrete AilienApi provider, one firstRole and one message"
	history := AIAHistory new.
	history title: 'Test Title'.
	history api: (MistralApi new model: 'test-model'; yourself).
	history responseHearderLevel: 2.
	history firstRoles add: 'system' -> 'be nice'.
	history messages add: 'user' -> 'hi'.

	"Convert the history to JSON via the file store held in the instance variable"
	json := refAIAHistoryFileStore jsonFromHistory: history.

	"The result is a JSON string"
	self assert: (json isKindOf: String).

	"Parse it back to check the individual fields"
	parsed := STONJSON fromString: json.

	"Format version is fixed to 1"
	self assert: ((parsed at: 'formatVersion') = 1).

	"Scalar properties come from the history"
	self assert: ((parsed at: 'title') = 'Test Title').
	self assert: ((parsed at: 'provider') = 'MistralApi').
	self assert: ((parsed at: 'model') = 'test-model').
	self assert: ((parsed at: 'responseHeaderLevel') = 2).

	"No pre-histories were added, so preHistoryIds is empty"
	self assert: ((parsed at: 'preHistoryIds') isEmpty).

	"createdAt and modifiedAt come from the file store's fixed instance variables"
	self assert: ((parsed at: 'createdAt') = (refAIAHistoryFileStore instVarNamed: #createdAt) asString).
	self assert: ((parsed at: 'modifiedAt') = (refAIAHistoryFileStore instVarNamed: #modifiedAt) asString).

	"firstRoles and messages are turned into role/content dictionaries; lastRoles is empty"
	self assert: (((parsed at: 'firstRoles') first at: 'role') = 'system').
	self assert: (((parsed at: 'firstRoles') first at: 'content') = 'be nice').
	self assert: (((parsed at: 'messages') first at: 'role') = 'user').
	self assert: (((parsed at: 'messages') first at: 'content') = 'hi').
	self assert: ((parsed at: 'lastRoles') isEmpty)

]

{ #category : 'AI generated test' }
AIAHistoryFileStoreAITest >> testLoad [
	"Test that load reads the previously saved file and rebuilds the AIAHistory from its JSON contents."
	| history file loaded |
	"Build an AIAHistory with a concrete AilienApi provider, one firstRole and one message"
	history := AIAHistory new.
	history title: 'Test Title'.
	history api: (MistralApi new model: 'test-model'; yourself).
	history responseHearderLevel: 2.
	history firstRoles add: 'system' -> 'be nice'.
	history messages add: 'user' -> 'hi'.
	"Save it so that fileReference actually exists on disk for load to read"
	file := refAIAHistoryFileStore save: history.
	"Load reads the file back and reconstructs the history from JSON"
	loaded := refAIAHistoryFileStore load.
	"The result is an AIAHistory with the scalar properties restored"
	self assert: (loaded isKindOf: AIAHistory).
	self assert: (loaded title = 'Test Title').
	self assert: (loaded api model = 'test-model').
	"The reconstructed history points back to the file store that loaded it"
	self assert: (loaded fileStore == refAIAHistoryFileStore).
	"The messages association is restored"
	self assert: (loaded messages asArray = { 'user' -> 'hi' }).
	"Clean up the file written during the test"
	file ensureDelete.

]

{ #category : 'AI generated test' }
AIAHistoryFileStoreAITest >> testRoleDictionaryFromArg [
	"Test that roleDictionaryFrom: converts an association into the expected dictionary structure"
	| association result |
	association := 'user' -> 'Hello world'.
	result := refAIAHistoryFileStore roleDictionaryFrom: association.
	self assert: (result isKindOf: Dictionary).
	self assert: (result size = 2).
	self assert: ((result at: 'role') = 'user').
	self assert: ((result at: 'content') = 'Hello world')
]

{ #category : 'AI generated test' }
AIAHistoryFileStoreAITest >> testSaveArg [
	"Test that save: writes the given AIAHistory to disk as JSON and returns
	 the file reference where it was written."
	| history file |
	"Build a real AIAHistory (a Dictionary would not answer #preHistories, #api, etc.)"
	history := AIAHistory new.
	history title: 'Test Title'.
	history api: (MistralApi new model: 'test-model'; yourself).
	history responseHearderLevel: 2.
	history firstRoles add: 'system' -> 'be nice'.
	history messages add: 'user' -> 'hi'.
	"save: returns the file reference it wrote to"
	file := refAIAHistoryFileStore save: history.
	"rootDirectory uses FileLocator home, so the result is an AbstractFileReference (a FileLocator)"
	self assert: (file isKindOf: AbstractFileReference).
	"The file must actually exist on disk after saving"
	self assert: (file exists).
	"The returned file matches the store's computed fileReference"
	self assert: (file = refAIAHistoryFileStore fileReference).
	"Clean up the file written during the test"
	file ensureDelete

]
