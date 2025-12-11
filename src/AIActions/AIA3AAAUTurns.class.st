Class {
	#name : 'AIA3AAAUTurns',
	#superclass : 'AIAMultiLLMResponseBase',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'markdown' }
AIA3AAAUTurns >> responseOf: aiLLM [
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
AIA3AAAUTurns >> words [
	| dict |
	dict := Dictionary new.
	dict 
		at: '00' put: 'assistant: with user:';
		at: '30' put: 'assistant: a: a: user:';
		at: '40' put: 'assistant: a: a: user:'.
	^ dict
]
