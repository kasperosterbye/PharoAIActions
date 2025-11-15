Class {
	#name : 'AIAResponseType',
	#superclass : 'Object',
	#instVars : [
		'responses',
		'prompt'
	],
	#classVars : [
		'MarkDown',
		'RTResults'
	],
	#category : 'AIAExperiments',
	#package : 'AIAExperiments'
}

{ #category : 'as yet unclassified' }
AIAResponseType class >> prompts [
	^ { 
		'Who is the Computer Scientist Lars Bendix?'".
		'How many horses are there in the area around Mårum?'.
		'What is the history of the Danish city named Langborteby?'" }
]

{ #category : 'as yet unclassified' }
AIAResponseType class >> responseTypes [
	^ { 
		''.
		' Do not give a hallucinated answer.'.
		' No guessing, if you do not know, just say "I do not know"' }
]

{ #category : 'as yet unclassified' }
AIAResponseType class >> testProviders [
	^ { MistralApi. GrokApi". ClaudeApi. GeminiApi" }
]

{ #category : 'RT builder' }
AIAResponseType >> buildPromtList [
	| promptAndResponse | 
	promptAndResponse := OrderedCollection new.
	self class prompts do: [ :pr |
		self class responseTypes do: [ :rt |
			promptAndResponse add:  pr , rt.
			 ]
		 ].
	^ promptAndResponse 
	
]

{ #category : 'RT builder' }
AIAResponseType >> for: prompt inLLM: llm [ 

	| resp|
	resp := AIAHistory new. 
	resp
		api: llm;
		user: prompt ;
		getResponse.
	^ resp response 
]

{ #category : 'RT builder' }
AIAResponseType >> forLLM: llm prompt: prompt resourceType: resourceType [ 

	|  prmt resp|
	prmt := (self class prompts at: prompt) , (self class responseTypes at: resourceType ).
	resp := AIAHistory new. 
	resp
		api: llm;
		user: prmt ;
		getResponse.
	^ resp response 
]

{ #category : 'initialization' }
AIAResponseType >> initialize [ 
	super initialize.
]

{ #category : 'markdown' }
AIAResponseType >> markdownExplanation [
	MarkDown 
		<< 'Explanation of the data and their structure goes here. As plain text' << String cr << String cr.
]

{ #category : 'markdown' }
AIAResponseType >> markdownPromptsAndResponseTypes [

	| list |
	MarkDown << '## Prompts and response types' << String cr << String cr.
	
	list := self buildPromtList.
	MarkDown << '| **Index** | **Prompts & ResponseTypes** |' << String cr.
	MarkDown << '| ----- | ----------------------- |' << String cr.
	1 to: list size do: [ :index |
		MarkDown << '| ' << index asString << ' | ' << (list at: index) << ' |' << String cr
		 ].
	^ MarkDown contents
]

{ #category : 'markdown' }
AIAResponseType >> markdownResponse [
	MarkDown := WriteStream on: ''.
	MarkDown 
		<< '# Response type experiments' << String cr << String cr.
	self 
		markdownExplanation;
		markdownPromptsAndResponseTypes;
		markdownResponseTypeResults.
	AIAPresenter onText: MarkDown contents.
	^ MarkDown contents
]

{ #category : 'markdown' }
AIAResponseType >> markdownResponseTypeResults [
	| list index promtAndLLM shortResp |
	MarkDown << '## Respons for '<< (self buildPromtList first ) << String cr << String cr.
	
	list := self buildPromtList.
	MarkDown << '| **Index** | **LLM** | **Response (first 50 letters)** |' << String cr.
	MarkDown << '| --------- | ------- | ------------------------------ |' << String cr.
	1 to: RTResults size do: [ :prIndex |
		1 to: (RTResults at: prIndex) value size do: [ :llmResonseIndex |
			index := prIndex asString.
			promtAndLLM := ((RTResults at: prIndex) value at: llmResonseIndex) key asString.
			shortResp := ((RTResults at: prIndex) value at: llmResonseIndex) value asString.
			shortResp size > 50 ifTrue: [ shortResp := shortResp first: 50 ].
			MarkDown << '| ' << index << ' | ' << promtAndLLM << ' | ' << shortResp << ' |' << String cr.
			 ]
		 ].

	^ MarkDown contents
]

{ #category : 'RT builder' }
AIAResponseType >> modelsList [

	| list |
	list := OrderedCollection new. 
	self class testProviders do: [ :api |
			1 to: api modelNames size do: [ :llmId |
					list add: (api newOnModel: llmId) ] ].
	^ list
]

{ #category : 'RT builder' }
AIAResponseType >> responceTypeExperiments [
	"Collect the responses for each prompt & responseType for each prover and its models"

	| promptResponseTypes llms responses prompts |
	promptResponseTypes := self buildPromtList.
	llms := self modelsList.
	
	prompts := OrderedCollection new.
	promptResponseTypes do: [ :promtResonse | 
			responses := OrderedCollection new.

			llms do: [ :llm | 
				responses add: (llm -> (self for: promtResonse inLLM: llm ) ) 
			] .
			prompts add: (promtResonse -> responses )
		].
	RTResults := prompts.
	^ prompts 
		
]
