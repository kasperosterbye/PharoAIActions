Class {
	#name : 'AIASWMreport',
	#superclass : 'Object',
	#instVars : [
		'models',
		'resposeHistories',
		'refinedResponses',
		'finalResponse',
		'originalPaperHistory'
	],
	#classVars : [
		'MarkDown',
		'RTResults'
	],
	#category : 'AIAExperiments',
	#package : 'AIAExperiments'
}

{ #category : 'as yet unclassified' }
AIASWMreport class >> RT [
	"Returns the last result from the RTResults collection"
	^ RTResults last
]

{ #category : 'initialization' }
AIASWMreport class >> initializeRTResults [
	"Initializes the RTResults collection for storing response data"
	<example>
	RTResults := nil 
]

{ #category : 'as yet unclassified' }
AIASWMreport class >> papers [
	| papers |
	papers := { 'ResponseType.md' . 'RustBelt.txt' }.
	^ papers collect: [ :p |
	(FileSystem disk root / 'Users' / 'kasper' / 'D' / 'AIExperiments' / 'SWM' / p) readStream contents trimBoth ].
 	
]

{ #category : 'as yet unclassified' }
AIASWMreport class >> prompts [
	^ { 
		'This is a short background report. What do you see as its strengts, weaknesses, and missing areas?'. }
]

{ #category : 'as yet unclassified' }
AIASWMreport class >> testModels [	
	"Returns a dictionary of AI models and their versions for testing purposes"
	^ { 
		GrokApi -> { 2 "Grok-4-fast-reasoning". 1 "grok-code-fast-1" }.
		MistralApi -> { 1 "codestral-latest". 3 "devstral-medium-2507" }.
		TogetherApi -> { 4 "DeepSeek-V3.1". 3 "Qwen3-235B-A22B"  }.
		OpenAIApi -> { 1 "gpt-5.1" }.
		GeminiApi -> { 2  "gemini-2.5-pro" }
	}
	
]

{ #category : 'RT builder' }
AIASWMreport >> buildPromtList [
	"Builds a list of prompt and response type combinations for testing"
	| promptAndResponse | 
	promptAndResponse := OrderedCollection new.
	self class prompts do: [ :pr |
		self class responseTypes do: [ :rt |
			promptAndResponse add:  pr , rt.
			 ]
		 ].
	^ promptAndResponse 
	
]

{ #category : 'as yet unclassified' }
AIASWMreport >> getEvaluations [
	resposeHistories := OrderedCollection new.
	models do: [ :model | |hist|
		hist := AIAHistory new.
		hist
			api: model;
			addPreHistory: originalPaperHistory;
			user: '[PROMTED] ',(model printString);
			user: 'What do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?';
			responseType: 'Your response should be written in Markdown.';
			getResponse.
		resposeHistories add: hist.
		 ]
	
]

{ #category : 'as yet unclassified' }
AIASWMreport >> getModels [
	| aiModels aiModel|
	aiModels := OrderedCollection new.
	self class testModels do: [ :providerInfo | 
		providerInfo value do: [ :llmInfo | 
			aiModel := (providerInfo key) new.
			aiModel model: (aiModel class modelNames at: llmInfo ).
			aiModels add: aiModel copy.
		 ] ].
	^ aiModels 
]

{ #category : 'as yet unclassified' }
AIASWMreport >> getRefinedResponses [
	| allResponses |
	allResponses := AIAHistory new.
	resposeHistories do: [ :hist| allResponses addPreHistory: hist ].
	refinedResponses := OrderedCollection new.
	resposeHistories do: [ :model | |refined|
		refined := AIAHistory new.
		refined 
			addPreHistory: allResponses;
			user: 'Based on the previous responses and the original paper - what do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?';
			responseType: 'Your response should be written in Markdown.';
			getResponse.
		refinedResponses add: refined.
		]
]

{ #category : 'as yet unclassified' }
AIASWMreport >> getResponses [
	"This method runs experiments to collect responses from different LLM providers for various prompts and response types. It manages the process asynchronously and provides progress updates."
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
AIASWMreport >> initialize [ 
	"Initializes the AIAResponseType instance and ensures RTResults is nil"
	super initialize.
	RTResults ifNil: [ RTResults := OrderedCollection new].
]

{ #category : 'markdown' }
AIASWMreport >> markdownExplanation [
	"This method generates a Markdown explanation for the experiment results, including details about the prompts, temperature settings, and IDNK (I do not know) responses."
	MarkDown 
		<< 'All prompts sent in fresh, empty conversations.' << String cr 
		<<'Temperature = 0.0 everywhere.' << String cr 
		<< 'IDNK = response contains the exact phrase `I do not know` (case-sensitive).' << String cr << String cr.
]

{ #category : 'markdown' }
AIASWMreport >> markdownPromptsAndResponseTypes [
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
AIASWMreport >> markdownResponse [ 
	| om |
	MarkDown := WriteStream on: ''.
	MarkDown 
		<< '## Paper judgement '<< Date today asString << String cr << String cr.
	om := originalPaperHistory messages.
	MarkDown
		<< om second value << String cr << String cr .
	MarkDown 
		<< '### AI based readings of the paper' << String cr << String cr.
	resposeHistories do: [ :rh |
		MarkDown << rh messages first key << ' -> ' <<  rh messages first value << String cr .
		MarkDown << rh messages second key << ' -> ' <<  rh messages second value << String cr .
		MarkDown << rh messages third key << ' -> ' <<  rh messages third value << String cr .
		
		 ].
	AIAPresenter onText: MarkDown contents.
	^ MarkDown contents
]

{ #category : 'markdown' }
AIASWMreport >> markdownResponseTypeResults [
	"This method generates a detailed Markdown table of experiment results, showing LLM responses for each prompt and response type combination."
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

{ #category : 'markdown' }
AIASWMreport >> markdownSpecials [
	"This method generates a Markdown table of unusual responses that do not contain 'I do not know'"

	| unusualOnes list index promtAndLLM shortResp lastResults idnk itemNr|
	unusualOnes := MarkDown := WriteStream on: ''.
	unusualOnes << '## Unusual Responses' << String cr << String cr.

	unusualOnes << 'These responses do not include a *I do not know* (IDNK).' << String cr << String cr.
	unusualOnes << 'Hense it need to be checked if they acrually gives a correct answer. ' << String cr << String cr.

	unusualOnes << 'To do so the actual response need to be read for each to examine thier results' << String cr << String cr.

	list := self buildPromtList.
	unusualOnes << '| **id** | **Index** | **LLM** | **IDNK** | **Response (first 50 letters)** |' << String cr.
	unusualOnes << '| ------ | --------- | ------- | -------- | --------------------- |' << String cr.
	lastResults := RTResults last.
	itemNr := 1.
	1 to: lastResults size do: [ :prIndex |
			1 to: (lastResults at: prIndex) value size do: [ :llmResonseIndex |
					index := prIndex asString.
					promtAndLLM := ((lastResults at: prIndex) value at: llmResonseIndex) key asString.
					shortResp := ((lastResults at: prIndex) value at: llmResonseIndex) value asString.
					(shortResp includesSubstring: 'I do not know')
						ifTrue: [ idnk := 'Yes' ]
						ifFalse: [
								((shortResp includesSubstring: 'Error bla bla') or: [ shortResp = 'Data receive timed out.' ])
									ifFalse: [ idnk := 'No' ]
									ifTrue: [ idnk := '- (error)' ] ].
					idnk = '- (error)' ifFalse: [
							(((prIndex odd and: [ idnk = 'Yes' ]) 
								or: [prIndex even and: [ idnk = 'No' ]]) and: [ shortResp size > 0 ])
								ifTrue: [
									shortResp size > 50 ifTrue: [ shortResp := shortResp first: 50 ].
									shortResp := ' ' join: shortResp lines. 
									"Only include those responses that are unusal"
									unusualOnes << '| ' << itemNr asString << ' | ' << index << ' | ' << promtAndLLM 
										<< ' | ' << idnk << ' | ' << shortResp << ' |' << String cr.
									itemNr := itemNr + 1 ] ] ] ].
	^ unusualOnes contents
]

{ #category : 'RT builder' }
AIASWMreport >> modelsList [
	"Returns a list of all available LLM models across all test providers"

	| list |
	list := OrderedCollection new. 
	self class testModels do: [ :api |
			1 to: api value size do: [ :llmId |
					list add: (api key newOnModel: (api value at: llmId)) ] ].
	models := list.
	^ list
]

{ #category : 'RT builder' }
AIASWMreport >> old_setPaperHistory: id [
	originalPaperHistory := AIAHistory new.
	originalPaperHistory 
		api: (MistralApi newOnModel: 1);
		background: (self class papers at: id);
		user: 'Please give the title and author(s) of the background paper please. Respond those only the title  and the authors, nothing else';
		getResponse.
	^ originalPaperHistory 
		
	
]

{ #category : 'accessing' }
AIASWMreport >> origunalPaperHistory [

	^ originalPaperHistory
]

{ #category : 'accessing' }
AIASWMreport >> origunalPaperHistory: anObject [

	originalPaperHistory := anObject
]

{ #category : 'RT builder' }
AIASWMreport >> responceTypeExperiments [
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

{ #category : 'RT builder' }
AIASWMreport >> setPaperHistory: id [
	originalPaperHistory := AIAHistory new.
	originalPaperHistory 
		api: (MistralApi newOnModel: 1);
		background: (self class papers at: id);
		user: 'Please give a biblatex entry for the background paper. Respond only the biblatex in Markdown ```biblates, nothing else';
		getResponse.
	^ originalPaperHistory 
		
	
]
