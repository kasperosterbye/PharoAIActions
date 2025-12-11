Class {
	#name : 'AIA2UUUTurns',
	#superclass : 'AIAMultiLLMResponseBase',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'markdown' }
AIA2UUUTurns >> responseOf: aiLLM [
	"Returns the response from the specified AI LLM model for a predefined set of user prompts"
	| hist |
	hist := AIAHistory new.
	hist 
		api: aiLLM;
		user: 'aaa is 2';
		user: 'bbb is 3';
		user: 'so aaa + bbb is what';
		getResponse.
	^ hist response.
]

{ #category : 'matching' }
AIA2UUUTurns >> words [
	| dict |
	dict := Dictionary new.
	dict 
		at: '00' put: 'user:';
		at: '30' put: 'user: user: user:';
		at: '40' put: 'user: user: user:'.
	^ dict
]
