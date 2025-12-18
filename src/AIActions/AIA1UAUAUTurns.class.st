Class {
	#name : 'AIA1UAUAUTurns',
	#superclass : 'AIA1MultiLLMResponseBase',
	#category : 'AIActions-ExperimentsOLD',
	#package : 'AIActions',
	#tag : 'ExperimentsOLD'
}

{ #category : 'markdown' }
AIA1UAUAUTurns >> responseOf: aiLLM [
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
	^ 'user: assistant: user: assistant: user:'.
]
