Class {
	#name : 'AIA2UUUTurns',
	#superclass : 'AIA1MultiLLMResponseBase',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'markdown' }
AIA2UUUTurns >> responseOf: aiLLM [
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
	^ 'user: user: user:'.
]
