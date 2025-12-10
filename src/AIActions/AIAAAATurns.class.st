Class {
	#name : 'AIAAAATurns',
	#superclass : 'AIAMultiLLMResponseBase',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'markdown' }
AIAAAATurns >> responseOf: aiLLM [
	"Returns the response from an AI LLM model for a specific history scenario"
	| hist |
	hist := AIAHistory new.
	hist 
		api: aiLLM;
		assistant: 'aaa is 2';
		assistant: 'bbb is 3';
		assistant: 'the sum of aaa + bbb is 5';
		user: '?';
		getResponse.
	^ hist response.
]

{ #category : 'matching' }
AIAAAATurns >> words [
	| dict |
	dict := Dictionary new.
	dict 
		at: '00' put: 'assistant:';
		at: '30' put: 'assistant: assistant: assistant:';
		at: '40' put: 'assistant: assistant: assistant:'.
	^ dict
]
