Class {
	#name : 'AIAChatBuildingAITest_m9',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAChatBuilding'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIAChatBuildingAITest_m9 >> setUp [
	super setUp.
	refAIAChatBuilding := AIADiscussion new.
]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m9 >> testAssistant [
	| result |
	"Arrange"
	refAIAChatBuilding := AIADiscussion new.
	
	"Act"
	refAIAChatBuilding assistant: 'Hello, world!'.
	
	"Assert"
	result := refAIAChatBuilding history.
	self assert: result size equals: 1.
	self assert: (result first key) equals: 'assistant'.
	self assert: (result first value) equals: 'Hello, world!'.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m9 >> testHistory [
	"Tests the history method of AIAChatBuilding.
	Verifies that the method returns the correct history, which is an OrderedCollection."

	| result |
	"Arrange - No specific setup needed as history is an instance variable initialized in initialize."

	"Act"
	result := refAIAChatBuilding history.

	"Assert"
	self assert: result class equals: OrderedCollection.
	self assert: result size equals: 0. "Assuming history is initialized as an empty collection"

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m9 >> testInitialize [
	"Tests that the initialize method correctly sets up the instance."

	|  |
	"Arrange"
	"In the setUp method, the instance variable refAIAChatBuilding is initialized to an instance of AIAChatBuilding, so we use it."

	"Act"
	refAIAChatBuilding initialize.

	"Assert"
	self assert: refAIAChatBuilding history notNil.
	self assert: refAIAChatBuilding history isEmpty.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m9 >> testJsonHistory [
	| expectedHistory result |
	"Arrange - Set up the chat history"
	refAIAChatBuilding system: 'System message'.
	refAIAChatBuilding user: 'User message'.
	refAIAChatBuilding assistant: 'Assistant response'.

	"Act - Call the method under test"
	result := refAIAChatBuilding jsonHistory.

	"Assert - Verify the result"
	expectedHistory := #(
		( 'role' -> 'system' )
		( 'content' -> 'System message' )
	) asOrderedCollection , #(
		( 'role' -> 'user' )
		( 'content' -> 'User message' )
	) asOrderedCollection , #(
		( 'role' -> 'assistant' )
		( 'content' -> 'Assistant response' )
	) asOrderedCollection asArray.
	self assert: result size equals: 3.
	self assert: (result first at: 'role') equals: 'system'.
	self assert: (result first at: 'content') equals: 'System message'.
	self assert: (result second at: 'role') equals: 'user'.
	self assert: (result second at: 'content') equals: 'User message'.
	self assert: (result third at: 'role') equals: 'assistant'.
	self assert: (result third at: 'content') equals: 'Assistant response'.
	"The method should return an array of dictionaries, each with 'role' and 'content' keys."

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m9 >> testSystem [
	"Tests that the system: method correctly adds a system message to the chat history."

	| message |
	"Arrange"
	message := 'This is a system message'.

	"Act"
	refAIAChatBuilding system: message.

	"Assert"
	self assert: refAIAChatBuilding history first key equals: 'system'.
	self assert: refAIAChatBuilding history first value equals: message.

]

{ #category : 'AI generated test' }
AIAChatBuildingAITest_m9 >> testUser [
	| message |
	"Arrange"
	message := 'Hello, AI!'.

	"Act"
	refAIAChatBuilding user: message.

	"Assert"
	self assert: refAIAChatBuilding history size equals: 1.
	self assert: (refAIAChatBuilding history first key) equals: 'user'.
	self assert: (refAIAChatBuilding history first value) equals: message.

]
