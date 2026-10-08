Class {
	#name : 'AIAOpenAIResponsesTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'tests' }
AIAOpenAIResponsesTest >> testParsesOrdinaryResponsesMessage [
	| inner history reply |

	history := AIAHistory new.

	inner := OpenAIResponsesInnerCall new.
	inner outer: (OpenAIApi new
		history: history;
		yourself).

	reply := Dictionary newFrom: {
		'output' -> {
			Dictionary newFrom: {
				'type' -> 'message'.
				'content' -> {
					Dictionary newFrom: {
						'type' -> 'output_text'.
						'text' -> 'seven' } } } } }.

	inner llmReply: reply.

	self assert: inner check equals: '*notool*'.
	self assert: history response equals: 'seven'
]

{ #category : 'tests' }
AIAOpenAIResponsesTest >> testReasoningModelAllowsTools [
	self assert:
		(OpenAIApi toolsEnabledFor: 'gpt-6-astra')
]

{ #category : 'tests' }
AIAOpenAIResponsesTest >> testRequestUsesInput [
	| entity |

	entity := OpenAIApi new
		messageList: { 'user' -> 'Hello' };
		znClientEntity.

	self assert: (entity asDictionary includesKey: 'input').
	self deny: (entity asDictionary includesKey: 'messages')
]

{ #category : 'tests' }
AIAOpenAIResponsesTest >> testRequestUsesResponsesReasoningFormat [
	| entity reasoning |

	entity := OpenAIApi new
		model: 'gpt-6-astra';
		reasoningLevel: #high;
		messageList: { 'user' -> 'Hello' };
		znClientEntity.

	entity := entity asDictionary.

	self deny: (entity includesKey: 'reasoning_effort').

	reasoning := entity at: 'reasoning'.
	self assert: (reasoning at: 'effort') equals: #high
]

{ #category : 'tests' }
AIAOpenAIResponsesTest >> testToolSpecificationUsesResponsesFormat [
	| entity tool |

	entity := OpenAIApi new
		toolsEnabled: true;
		messageList: { 'user' -> 'Hello' };
		znClientEntity.

	tool := (entity asDictionary at: 'tools') first.

	self assert: (tool at: 'type') equals: 'function'.
	self assert: (tool includesKey: 'name').
	self assert: (tool includesKey: 'parameters').
	self deny: (tool includesKey: 'function')
]

{ #category : 'tests' }
AIAOpenAIResponsesTest >> testUsesResponsesEndpoint [
	self
		assert: OpenAIApi apiGenerateUrl
		equals: 'https://api.openai.com/v1/responses'
]

{ #category : 'tests' }
AIAOpenAIResponsesTest >> testUsesResponsesInnerCall [
	self
		assert: OpenAIApi new innerCallClass
		equals: OpenAIResponsesInnerCall
]
