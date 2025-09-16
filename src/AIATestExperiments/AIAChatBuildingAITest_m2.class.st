Class {
	#name : 'AIAChatBuildingAITest_m2',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAChatBuilding'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIAChatBuildingAITest_m2 >> setUp [
	super setUp.
	refAIAChatBuilding := AIADiscussion new.
]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m2 >> testAssistant [
    "Test that assistant: adds a message to the chat history and returns the updated history."
    | message |
    message := 'This is a test assistant message'.
    refAIAChatBuilding assistant: message.
    self assert: (refAIAChatBuilding history last value) equals: message.
    self assert: (refAIAChatBuilding history last key) equals: 'assistant'.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m2 >> testHistory [
    "Test that history returns an OrderedCollection and contains expected chat items."

    | chatItem |
    "Add a test item to the history"
    refAIAChatBuilding user: 'Test user message'.

    "Verify the history is an OrderedCollection"
    self assert: (refAIAChatBuilding history isKindOf: OrderedCollection).

    "Verify the history contains the added item"
    chatItem := refAIAChatBuilding history last.
    self assert: chatItem key equals: 'user'.
    self assert: chatItem value equals: 'Test user message'.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m2 >> testInitialize [
    "Test that initialize sets up the history instance variable correctly."
    | testInstance |
    testInstance := AIADiscussion new.
    self assert: testInstance history isNotNil.
    self assert: testInstance history isEmpty.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m2 >> testJsonHistory [
    "Test that jsonHistory converts chat history to JSON format correctly"
    | testHistory jsonResult expectedJson |

    "Setup test history"
    testHistory := OrderedCollection new.
    testHistory add: 'system' -> 'Test system message'.
    testHistory add: 'user' -> 'Test user message'.
    testHistory add: 'assistant' -> 'Test assistant message'.

    "Replace actual history with test data"
    refAIAChatBuilding instVarNamed: 'history' put: testHistory.

    "Execute method under test"
    jsonResult := refAIAChatBuilding jsonHistory.

    "Verify the result is an array"
    self assert: jsonResult isArray.

    "Verify the structure of the JSON"
    expectedJson := #(
        (('role' 'system') ('content' 'Test system message'))
        (('role' 'user') ('content' 'Test user message'))
        (('role' 'assistant') ('content' 'Test assistant message'))
    ).

    self assert: jsonResult size equals: 3.
    self assert: (jsonResult first at: 'role') equals: 'system'.
    self assert: (jsonResult first at: 'content') equals: 'Test system message'.
    self assert: (jsonResult second at: 'role') equals: 'user'.
    self assert: (jsonResult second at: 'content') equals: 'Test user message'.
    self assert: (jsonResult third at: 'role') equals: 'assistant'.
    self assert: (jsonResult third at: 'content') equals: 'Test assistant message'.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m2 >> testSystem [
    "Test that system: adds a system message to the chat history and returns the updated history."

    | initialHistorySize newHistorySize |

    "Setup: Get initial history size"
    initialHistorySize := refAIAChatBuilding history size.

    "Exercise: Add a system message"
    refAIAChatBuilding system: 'Test system message'.

    "Verify: Check that history size increased by 1"
    newHistorySize := refAIAChatBuilding history size.
    self assert: newHistorySize equals: initialHistorySize + 1.

    "Verify: Check that the last message is the system message"
    self assert: refAIAChatBuilding history last equals: 'system' -> 'Test system message'.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m2 >> testUser [
    "Test that user: adds a message to the chat history with the correct role and content."
    | initialCount newMessage |
    initialCount := refAIAChatBuilding history size.
    newMessage := 'Test user message'.
    refAIAChatBuilding user: newMessage.
    self assert: refAIAChatBuilding history size equals: initialCount + 1.
    self assert: (refAIAChatBuilding history last key = 'user').
    self assert: (refAIAChatBuilding history last value = newMessage).

]
