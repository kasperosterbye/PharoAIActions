Class {
	#name : 'AIAOpenAIResponsesLiveTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'tests' }
AIAOpenAIResponsesLiveTest >> testOpenAIResponsesReturnsText [
	| history api |

	history := AIAHistory new.
	api := OpenAIApi new.
	api
		model: 'gpt-6-astra';
		toolsEnabled: false.

	history
		api: api;
		user: 'Answer with exactly: seven';
		getResponse.

	self assert: history response equals: 'seven'
]

{ #category : 'tests' }
AIAOpenAIResponsesLiveTest >> testQ0UsesOpenAIResponses [
	| originalProvider originalModel answer |
	self timeLimit: 120 seconds.
	originalProvider := AilienApi provider.
	originalModel := OpenAIApi defaultModel.

	[
		AilienApi provider: OpenAIApi.
		OpenAIApi defaultModel:
			(OpenAIApi modelNames indexOf: 'gpt-6-astra').

		answer := 'Who is Kasper Osterbye.' q0.

		self assert: answer isString.
		self assert: answer trimBoth isNotEmpty.
		self deny: (answer beginsWith: 'API Error:')
	]
	ensure: [
		AilienApi provider: originalProvider.
		OpenAIApi defaultModel:
			(OpenAIApi modelNames indexOf: originalModel) ]
]

{ #category : 'tests' }
AIAOpenAIResponsesLiveTest >> testQ0UsesPharoToolThroughResponses [
	| originalProvider originalModel answer |

	self timeLimit: 120 seconds.
	originalProvider := AilienApi provider.
	originalModel := OpenAIApi defaultModel.

	[
		AilienApi provider: OpenAIApi.
		OpenAIApi defaultModel:
			(OpenAIApi modelNames indexOf: 'gpt-6-astra').

		answer :=
			'Use executePharoExpression to evaluate 2 + 3 * 4. Return only the result.' q0.

		self assert: answer trimBoth equals: '20'
	]
	ensure: [
		AilienApi provider: originalProvider.
		OpenAIApi defaultModel:
			(OpenAIApi modelNames indexOf: originalModel) ]
]

{ #category : 'tests' }
AIAOpenAIResponsesLiveTest >> testReturnsOrdinaryText [
	| history api |

	api := OpenAIApi new.
	api
		model: 'gpt-6-astra';
		toolsEnabled: false;
		responseWaitingInSecs: 60.

	history := AIAHistory new.
	history
		api: api;
		user: 'Answer with exactly: seven';
		getResponse.

	self assert: history response trimBoth equals: 'seven'
]
