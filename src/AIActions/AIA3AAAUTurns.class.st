Class {
	#name : 'AIA3AAAUTurns',
	#superclass : 'AIAMultiLLMResponseBase',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'markdown' }
AIA3AAAUTurns >> responseOf: aiLLM [
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
	^ 'assistant: assistant: assistant: user:'
]
