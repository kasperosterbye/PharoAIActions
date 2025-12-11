Class {
	#name : 'AIA1UAUAUTurns',
	#superclass : 'AIAMultiLLMResponseBase',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'markdown' }
AIA1UAUAUTurns >> responseOf: aiLLM [
	"Returns the response from the specified AI LLM model for a predefined set of user prompts"
	| hist |
	hist := AIAHistory new.
	hist 
		api: aiLLM;
		user: 'aaa is 2';
		assistant: 'OK';
		user: 'bbb is 3';
		assistant: 'OK';
		user: 'the sum of aaa + bbb is ...';
		getResponse.
	^ hist response.
]

{ #category : 'matching' }
AIA1UAUAUTurns >> words [
	| dict |
	dict := Dictionary new.
	dict 
		at: '00' put: 'user: assistant: shift';
		at: '30' put: 'user: assistant: u: a: u:';
		at: '40' put: 'user: assistant: u: a: u:'.
	^ dict
]
