Class {
	#name : 'AIAChatBuildingAITest_m1',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAChatBuilding'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIAChatBuildingAITest_m1 >> setUp [
	super setUp.
	refAIAChatBuilding := AIADiscussion new.
]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m1 >> testAssistant [
    "Test that assistant: adds a message to history and returns the updated history."

    | message historySize |
    message := 'Test assistant message'.
    historySize := refAIAChatBuilding history size.

    "Test that the method adds the message to history"
    refAIAChatBuilding assistant: message.
    self assert: refAIAChatBuilding history size equals: historySize + 1.
    self assert: (refAIAChatBuilding history last value) equals: message.

    "Test that the method returns the updated history"
    self assert: (refAIAChatBuilding assistant: 'Another test message') equals: refAIAChatBuilding history

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m1 >> testHistory [
    "Test that history returns an ordered collection of chat history items with role and content."
    | chatItem |
    "Setup: Add a test message to the chat history"
    refAIAChatBuilding user: 'Test message'.
    "Verify the history contains the added message"
    self assert: refAIAChatBuilding history size equals: 1.
    chatItem := refAIAChatBuilding history first.
    self assert: chatItem key equals: 'user'.
    self assert: chatItem value equals: 'Test message'.
    "Test that history maintains order of messages"
    refAIAChatBuilding assistant: 'Response message'.
    self assert: refAIAChatBuilding history size equals: 2.
    self assert: (refAIAChatBuilding history at: 2) key equals: 'assistant'.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m1 >> testInitialize [
    "Test that initialize sets up the history as an empty OrderedCollection."
    self assert: refAIAChatBuilding history isEmpty.
    self assert: refAIAChatBuilding history class equals: OrderedCollection.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m1 >> testJsonHistory [
    "Test that jsonHistory converts chat history to proper JSON format with system, user, and assistant messages."

    | testHistory expectedJson |
    "Setup test history with system, user, and assistant messages"
    testHistory := OrderedCollection new.
    testHistory add: 'system' -> 'Initial setup'.
    testHistory add: 'user' -> 'What is your name?'.
    testHistory add: 'assistant' -> 'I am an AI assistant'.

    "Store original history and replace with test data"
    refAIAChatBuilding instVarNamed: 'history' put: testHistory.

    "Execute method under test"
    expectedJson := refAIAChatBuilding jsonHistory.

    "Verify JSON structure and content"
    self assert: expectedJson isArray.
    self assert: expectedJson size equals: 3.
    self assert: (expectedJson first at: 'role') equals: 'system'.
    self assert: (expectedJson first at: 'content') equals: 'Initial setup'.
    self assert: (expectedJson second at: 'role') equals: 'user'.
    self assert: (expectedJson second at: 'content') equals: 'What is your name?'.
    self assert: (expectedJson third at: 'role') equals: 'assistant'.
    self assert: (expectedJson third at: 'content') equals: 'I am an AI assistant'.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m1 >> testSystem [
    "Test that system: adds a system message to the chat history and returns the updated history."

    | expectedHistory |
    expectedHistory := OrderedCollection with: 'system' -> 'Test system message'.

    refAIAChatBuilding system: 'Test system message'.

    self assert: refAIAChatBuilding history equals: expectedHistory.
    self assert: refAIAChatBuilding history size equals: 1.
    self assert: refAIAChatBuilding history first key equals: 'system'.
    self assert: refAIAChatBuilding history first value equals: 'Test system message'.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m1 >> testUser [
    "Test that user: adds a message to history and returns the updated history"
    | message |
    message := 'Test user message'.
    self assert: (refAIAChatBuilding user: message) = refAIAChatBuilding history.
    self assert: refAIAChatBuilding history last value equals: message.
    self assert: refAIAChatBuilding history last key equals: 'user'.

]
