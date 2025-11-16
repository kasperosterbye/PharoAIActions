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

{ #category : 'initialization' }
AIAResponseType class >> initializeRTResults [
	<example>
	RTResults := nil 
]

{ #category : 'as yet unclassified' }
AIAResponseType class >> old_prompts [
	^ { 
		'Who is the Computer Scientist Lars Bendix?'".
		'How many horses are there in the area around Mårum?'.
		'What is the history of the Danish city named Langborteby?'" }
]

{ #category : 'as yet unclassified' }
AIAResponseType class >> prompts [
	^ { 
		'Who is the Computer Scientist Lars Bendix?'.
		'What is the history of the Danish village Sønder Nybrohede?'.
		'What does the networking protocol RFC 7832 define?' }
]

{ #category : 'as yet unclassified' }
AIAResponseType class >> responseTypes [
	^ { 
		''.
		' No guessing, if you do not know, just say "I do not know"'".
		' [RESPONSETYPE] No guessing, if you do not know, just say ""I do not know""'"
	 }
]

{ #category : 'as yet unclassified' }
AIAResponseType class >> testProviders [
	^ { MistralApi . GrokApi. GeminiApi. OllamaApi. OpenAIApi . ClaudeApi.}
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
	RTResults ifNil: [ RTResults := OrderedCollection new].
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
		MarkDown << '| ' << index asString << ' | ' << ( ' ' join: (list at: index) lines)  << ' |' << String cr
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
	| list index promtAndLLM shortResp lastResults|
	MarkDown << '## Summary of Responses' << String cr << String cr.
	
	list := self buildPromtList.
	MarkDown << '| **Index** | **LLM** | **Response (first 50 letters)** |' << String cr.
	MarkDown << '| --------- | ------- | ------------------------------ |' << String cr.
	lastResults := RTResults last.
	1 to: lastResults size do: [ :prIndex |
		1 to: (lastResults at: prIndex) value size do: [ :llmResonseIndex |
			index := prIndex asString.
			promtAndLLM := ((lastResults at: prIndex) value at: llmResonseIndex) key asString.
			shortResp := ((lastResults at: prIndex) value at: llmResonseIndex) value asString.
			shortResp size > 50 ifTrue: [ shortResp := shortResp first: 50 ].
			shortResp := ' ' join: shortResp lines.
			MarkDown << '| ' << index << ' | ' << promtAndLLM << ' | ' << shortResp << ' |' << String cr.
			 ]
		 ].
	MarkDown << '## Detailed of Responses' << String cr << String cr.
	1 to: lastResults size do: [ :prIndex |
		1 to: (lastResults at: prIndex) value size do: [ :llmResonseIndex |
			index := prIndex asString.
			promtAndLLM := ((lastResults at: prIndex) value at: llmResonseIndex) key asString.
			shortResp := ((lastResults at: prIndex) value at: llmResonseIndex) value asString.
			MarkDown << '#### ' << index << ' ' << promtAndLLM << String cr. 
			MarkDown << shortResp << String cr.
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

	| promptResponseTypes llms prompts |
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
	RTResults add: prompts.

	^ prompts 
		
]
