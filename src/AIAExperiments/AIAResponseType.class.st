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
AIAResponseType class >> RT [
	^ RTResults last
]

{ #category : 'initialization' }
AIAResponseType class >> initializeRTResults [
	<example>
	RTResults := nil 
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
		' No guessing, if you do not know, just start your response with "I do not know"'
	 }
]

{ #category : 'as yet unclassified' }
AIAResponseType class >> testProviders [
	
	"^ { TogetherApi.}"
	^ { MistralApi . GrokApi. GeminiApi. OllamaApi. OpenAIApi . ClaudeApi. TogetherApi}
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

{ #category : 'as yet unclassified' }
AIAResponseType >> getResponses [
	| id |
	id := RTResults size.
	[ :job | | aiProcess |
		aiProcess := [ self responceTypeExperiments ] newProcess.
		aiProcess priority: Processor userBackgroundPriority. 
		aiProcess resume.
		SystemProgressMorph uniqueInstance position: 10@20.
		job interruptBlock: [ 
			aiProcess terminate.
			^ self
		].
		1 to: 600 do: [:each |
			job
				progress: ((1/600) * each) ;
				title: 'Building responses'.
				RTResults size > id ifFalse: [100 milliSeconds wait].
		].
	] asJob run.
]

{ #category : 'initialization' }
AIAResponseType >> initialize [ 
	super initialize.
	RTResults ifNil: [ RTResults := OrderedCollection new].
]

{ #category : 'markdown' }
AIAResponseType >> markdownExplanation [
	MarkDown 
		<< 'All prompts sent in fresh, empty conversations.' << String cr 
		<<'Temperature = 0.0 everywhere.' << String cr 
		<< 'IDNK = response contains the exact phrase `I do not know` (case-sensitive).' << String cr << String cr.
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
	AilienApi errorResponse: 'Error bla bla happended'.
	MarkDown := WriteStream on: ''.
	MarkDown 
		<< '# Experiment results on '<< Date today asString << String cr << String cr.
	self 
		markdownExplanation;
		markdownPromptsAndResponseTypes;
		markdownResponseTypeResults.
	AIAPresenter onText: MarkDown contents.
	^ MarkDown contents
]

{ #category : 'markdown' }
AIAResponseType >> markdownResponseTypeResults [
	| list index promtAndLLM shortResp lastResults idnk|
	MarkDown << '## Summary of Responses' << String cr << String cr.
	MarkDown << 'If `response` stars with 1, it includes `I do not know`, stars with 0, it does not include `I do not know`'  << String cr << String cr 
	 << 'So indexes 1,3 and 5 should start with 0, while indexes 2, 4 and 6 should start with 1.' << String cr << String cr 
	 << 'The third collumn specifies if the response contains *I do not know* (IDNK)' << String cr << String cr << String cr .
	
	list := self buildPromtList.
	MarkDown << '| **Index** | **LLM** | **IDNK** | **Response (first 50 letters)** |' << String cr.
	MarkDown << '| --------- | ------- | -------- | --------------------- |' << String cr.
	lastResults := RTResults last.
	1 to: lastResults size do: [ :prIndex |
		1 to: (lastResults at: prIndex) value size do: [ :llmResonseIndex |
			index := prIndex asString.
			promtAndLLM := ((lastResults at: prIndex) value at: llmResonseIndex) key asString.
			shortResp := ((lastResults at: prIndex) value at: llmResonseIndex) value asString.
			(shortResp includesSubstring: 'I do not know')
				ifTrue: [ idnk := 'Yes' ]
				 ifFalse: [((shortResp includesSubstring: 'Error bla bla') or: [shortResp = 'Data receive timed out.'])
						ifFalse: [ idnk := 'No'  ] 
						ifTrue: [ idnk := '- (error)' ]
					].
			shortResp size > 50 ifTrue: [ shortResp := shortResp first: 50 ].
			shortResp := ' ' join: shortResp lines.
			MarkDown << '| ' << index << ' | ' << promtAndLLM << ' | ' 
				<< idnk << ' | ' << shortResp << ' |' << String cr.
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
	MarkDown << String cr << String cr.
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
