Class {
	#name : 'AIA4AAATurns',
	#superclass : 'AIAMultiLLMResponseBase',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'markdown' }
AIA4AAATurns >> responseOf: aiLLM [
	"Returns the response from an AI LLM model for a specific history scenario"
	| hist |
	hist := AIAHistory new.
	hist 
		api: aiLLM;
		assistant: 'aaa is 2';
		assistant: 'bbb is 3';
		assistant: 'the sum of aaa + bbb is 5';
		getResponse.
	^ hist response.
]

{ #category : 'matching' }
AIA4AAATurns >> words [
	| dict |
	dict := Dictionary new.
	dict 
		at: '00' put: 'assistant: no user:';
		at: '30' put: 'assistant: assistant: assistant:';
		at: '40' put: 'assistant: assistant: assistant:'.
	^ dict
]
