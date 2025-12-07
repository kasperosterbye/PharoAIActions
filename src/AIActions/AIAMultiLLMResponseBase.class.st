Class {
	#name : 'AIAMultiLLMResponseBase',
	#superclass : 'Object',
	#instVars : [
		'results'
	],
	#classVars : [
		'MarkDown',
		'Results'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'examples' }
AIAMultiLLMResponseBase class >> initializeRTResults [
	"Initializes the RTResults collection for storing response data"
	<example>
	Results := nil 
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> excludeProviders [
	^ { }
]

{ #category : 'initialization' }
AIAMultiLLMResponseBase >> initialize [ 
	"Initializes the AIAResponseType instance and ensures RTResults is nil"
	super initialize.
	Results ifNil: [ Results := OrderedCollection new].
]

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase >> markdown0Title [
	MarkDown 
		<< '# Experiment results on '<< Date today asString << String cr << String cr.
	
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdown1Explanation [
	"This method generates a Markdown explanation for the experiment results, including details about the prompts, temperature settings, and IDNK (I do not know) responses."
	MarkDown 
		<< 'All prompts sent in fresh, empty conversations.' << String cr 
		<<'Temperature = 0.0 everywhere.' << String cr 
		<< 'IDNK = response contains the exact phrase `I do not know` (case-sensitive).' << String cr << String cr.
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdown2LLMResponses [
	"This method generates a Markdown table of prompts and response types for the experiment."

	| list |
	MarkDown << '## Prompts and response types' << String cr << String cr.
	
	list := self buildPromtList.
	MarkDown << '| **Index** | **Prompts & ResponseTypes** |' << String cr.
	MarkDown << '| ----- | ----------------------- |' << String cr.
	1 to: list size do: [ :index |
		MarkDown << '| ' << index asString << ' | ' << ( ' ' join: (list at: index) lines)  << ' |' << String cr
		 ].
	^ MarkDown contents
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdownResponse [
	"This method generates a comprehensive Markdown report of experiment results, including prompts, responses, and analysis."
	AilienApi errorResponse: 'Error bla bla happended'.
	MarkDown := WriteStream on: ''.
	MarkDown 
		<< '# Experiment results on '<< Date today asString << String cr << String cr.
	self 
		markdown1Explanation;
		markdown2LLMResponses.
	AIAPresenter onText: MarkDown contents.
	^ MarkDown contents
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> modelsList [
	"This method returns a list of available models, excluding specified providers."
	| list exclude|
	exclude := self excludeProviders.
	list := OrderedCollection new.
	AilienApi providerAndModels do: [:provider |
		(exclude includes: provider first)
			ifFalse: [ list add: provider ]
		].
	^ list
]

{ #category : 'accessing' }
AIAMultiLLMResponseBase >> responseOf: aiLLM [
	^ 'Killroy'
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> responses [
	|   |
	results := OrderedCollection new.
	self modelsList do: [ :promtResonse |
			| llmResonses |
			llmResonses := (promtResonse at: 2) collect: [ :llm |
				 self responseOf: (promtResonse first new model: llm)
			] .
			results add: (promtResonse first -> llmResonses )
		].
	Results add: results.
	^ results 
		
]
