Class {
	#name : 'AI_OllamaPromptingTest',
	#superclass : 'TestCase',
	#instVars : [
		'ollamaPrompte'
	],
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'running' }
AI_OllamaPromptingTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	ollamaPrompte := AI_OllamaPrompting
		       newSystem: ''
		       promptPrefix: ''.
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> testAskPrompt [
	"test that the connection to the model works"
 	| response |
	ollamaPrompte askPrompt: ' Please answer Yes or no. Can you read this question'.
	response := ollamaPrompte getResponse.
	self assert: (response size between: 1 and: 100).
	
	Transcript show: ollamaPrompte getResponse; cr.
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> testGetResonceForPrompt [
	| result |
	result := AI_OllamaPrompting new 
		getResonceForPrompt: ' Please answer Yes or no. Can you read these words'.
	self assert: (result includesSubstring: 'Yes')
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> testGetResponse [
	"test that the connection to the model works"

	ollamaPrompte askPrompt: ' Please answer Yes or no. Can you read this question'.
	self assert: ollamaPrompte response isNil.
	self assert: ollamaPrompte getResponse isNotNil
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> testNewSystemPromptPrefix [
	"test that the connection to the model works"

	| ollamaPrompting |
	ollamaPrompting := AI_OllamaPrompting newSystem: 'Killroy was ' promptPrefix: 'here'.
	self assert: ollamaPrompting system = 'Killroy was '.
	self assert: ollamaPrompting promptPrefix = 'here'
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> testOllamaList [
	"check at the list function works, and is larger than 0"
	| res |
	res := AI_OllamaPrompting ollamaList.
	self assert: res size >= 1
	
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> testPromptAndResponseSemaphore [
	"tests if promptAndResponseSemaphore: is returning a result"
	| result |
	result := AI_OllamaPrompting new promptAndResponseSemaphore: 
		' Please answer Yes or no. Can you read these words'.
	self assert: (result includesSubstring: 'Yes')
]
