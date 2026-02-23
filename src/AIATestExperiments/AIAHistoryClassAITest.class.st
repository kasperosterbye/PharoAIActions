Class {
	#name : 'AIAHistoryClassAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refAIAHistory'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
AIAHistoryClassAITest >> setUp [
	super setUp.
	refAIAHistory := AIAHistory class new.
]

{ #category : 'AI generated test' }
AIAHistoryClassAITest >> testChatHistories [
	"chatHistories should answer the #chatHistory of each element returned by AIAHistory histories."

	| result expected |

	"Exercise"
	result := refAIAHistory chatHistories.

	"Verify: it answers a collection"
	self assert: (result isCollection).

	"Verify: it has the same size as the source histories"
	self assert: (result size = (AIAHistory histories size)).

	"Verify: it is exactly the collect of #chatHistory over AIAHistory histories"
	expected := (AIAHistory histories collect: [ :hist | hist chatHistory ]).
	self assert: (result = expected)
]

{ #category : 'AI generated test' }
AIAHistoryClassAITest >> testHistories [
	"Test that AIAHistory>>#histories answers the value of the class variable #Histories."

	| result |
	result := (self instVarNamed: #refAIAHistory) histories.

	"Must be exactly the class variable value."
	self assert: (result == (AIAHistory classPool at: #Histories)).
]
