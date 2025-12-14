Class {
	#name : 'AIA4AAATurns',
	#superclass : 'AIA1MultiLLMResponseBase',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'markdown' }
AIA4AAATurns >> responseOf: aiLLM [
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
	^ 'assistant: assistant: assistant:'
]
