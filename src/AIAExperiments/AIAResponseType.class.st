"
# Class Comment for AIAResponseType

The `AIAResponseType` class is designed to facilitate experiments with different Large Language Model (LLM) providers by systematically testing various prompts and response types. It collects responses from multiple LLM models, analyses them, and generates comprehensive reports in Markdown format.

## Key Features

- **Prompt and Response Management**: Builds combinations of predefined prompts and response types for testing
- **Model Testing**: Evaluates responses from multiple LLM providers and their models
- **Result Analysis**: Identifies unusual responses and generates detailed reports
- **Markdown Reporting**: Produces comprehensive reports in Markdown format for easy review

## Usage Example

```st
""Example usage in Playground""
| experiment |
experiment := AIAResponseType new.
experiment getResponses. ""Run the experiments""
experiment markdownResponse. ""Generate the full report""
```

The class maintains a shared collection of results (`RTResults`) and provides methods to:
- Build prompt/response combinations
- Test models against these combinations
- Generate detailed Markdown reports
- Identify unusual responses

The experiments are designed to test whether models correctly handle ""I do not know"" responses when instructed to do so, and to evaluate the quality of responses when they do provide answers.
"
Class {
	#name : 'AIAResponseType',
	#superclass : 'Object',
	#instVars : [
		'responses',
		'prompt'
	],
	#classVars : [
		'MarkDown',
		'Results'
	],
	#category : 'AIAExperiments-ExperimentsResearch',
	#package : 'AIAExperiments',
	#tag : 'ExperimentsResearch'
}

{ #category : 'as yet unclassified' }
AIAResponseType class >> RT [
	"Returns the last result from the RTResults collection"
	^ Results last
]

{ #category : 'as yet unclassified' }
AIAResponseType class >> prompts [
	"Returns a list of example prompts for AI response generation"
	^ { 'What is the result of 2+3*4 in Smalltalk. Response should just be the number'
		"'Who is the Computer Scientist Lars Bendix?'.
		'What is the history of the Danish village Sønder Nybrohede?'.
		'What does the networking protocol RFC 7832 define?'" }
]

{ #category : 'as yet unclassified' }
AIAResponseType class >> responseTypes [
	"Returns a list of response types for AI response generation"
	^ { 
		''.
		"' No guessing, if you do not know, just start your response with ""I do not know""'"
	 }
]

{ #category : 'as yet unclassified' }
AIAResponseType class >> testProviders [
	"Returns a list of API providers for testing AI responses"
	
	^ { MistralApi . GrokApi. GeminiApi. OllamaApi. OpenAIApi . ClaudeApi. TogetherApi}
	"^ { ClaudeApi.}"
	
]

{ #category : 'RT builder' }
AIAResponseType >> buildPromtList [
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

{ #category : 'RT builder' }
AIAResponseType >> for: prompt inLLM: llm [ 
	"Returns the response from the specified LLM for the given prompt"

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
	"Returns the response from the specified LLM for a given prompt and resource type combination"

	|  prmt resp|
	prmt := (self class prompts at: prompt) , (self class responseTypes at: resourceType ).
	resp := AIAHistory new. 
	resp
		api: llm;
		user: prmt ;
		getResponse.
	^ resp response 
]

{ #category : 'RT builder' }
AIAResponseType >> getResponses [
	"This method runs experiments to collect responses from different LLM providers for various prompts and response types. It manages the process asynchronously and provides progress updates."
	| id |
	id := Results size.
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
				Results size > id ifFalse: [100 milliSeconds wait].
		].
	] asJob run.
]

{ #category : 'initialization' }
AIAResponseType >> initialize [ 
	"Initializes the AIAResponseType instance and ensures RTResults is nil"
	super initialize.
]

{ #category : 'markdown' }
AIAResponseType >> markdownExplanation [
	"This method generates a Markdown explanation for the experiment results, including details about the prompts, temperature settings, and IDNK (I do not know) responses."
	MarkDown 
		<< 'All prompts sent in fresh, empty conversations.' << String cr 
		<<'Temperature = 0.0 everywhere.' << String cr 
		<< 'IDNK = response contains the exact phrase `I do not know` (case-sensitive).' << String cr << String cr.
]

{ #category : 'markdown' }
AIAResponseType >> markdownPromptsAndResponseTypes [
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
AIAResponseType >> markdownResponse [
	"This method generates a comprehensive Markdown report of experiment results, including prompts, responses, and analysis."
	AilienApi errorResponse: 'Error bla bla happended'.
	MarkDown := WriteStream on: ''.
	MarkDown 
		<< '# Experiment results on '<< Date today asString << String cr << String cr.
	self 
		markdown1Explanation;
		markdownPromptsAndResponseTypes;
		markdownResponseTypeResults.
	AIAPresenter onText: MarkDown contents.
	^ MarkDown contents
]

{ #category : 'markdown' }
AIAResponseType >> markdownResponseTypeResults [
	"This method generates a detailed Markdown table of experiment results, showing LLM responses for each prompt and response type combination."
	| list index promtAndLLM shortResp lastResults idnk|
	MarkDown << '## Summary of Responses' << String cr << String cr.
	MarkDown << 'If `response` stars with 1, it includes `I do not know`, stars with 0, it does not include `I do not know`'  << String cr << String cr 
	 << 'So indexes 1,3 and 5 should start with 0, while indexes 2, 4 and 6 should start with 1.' << String cr << String cr 
	 << 'The third collumn specifies if the response contains *I do not know* (IDNK)' << String cr << String cr << String cr .
	
	list := self buildPromtList.
	MarkDown << '| **Index** | **LLM** | **IDNK** | **Response (first 50 letters)** |' << String cr.
	MarkDown << '| --------- | ------- | -------- | --------------------- |' << String cr.
	lastResults := Results last.
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
AIAResponseType >> markdownSpecials [
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
	lastResults := Results last.
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
AIAResponseType >> modelsList [
	"Returns a list of all available LLM models across all test providers"

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
	Results add: prompts.

	^ prompts 
		
]
