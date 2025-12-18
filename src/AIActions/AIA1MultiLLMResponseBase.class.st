"
# Class Comment for AIAMultiLLMResponseBase

The `AIAMultiLLMResponseBase` class serves as a foundational framework for managing and comparing responses from multiple Large Language Model (LLM) providers. It facilitates the execution of LLM experiments, collection of responses, and generation of comprehensive Markdown reports for analysis.

## Key Features

- **Multi-LLM Experimentation**: Coordinates interactions with various LLM providers and models.
- **Response Management**: Stores and processes responses in a structured format for comparison.
- **Markdown Reporting**: Generates detailed reports including model overviews, response comparisons, and error analysis.
- **Progress Tracking**: Provides visual feedback during the execution of LLM queries.

## Usage Example

```st
""Example demonstrating the setup and execution of an LLM response experiment""
| experiment |
experiment := AIAMultiLLMResponseBase new.
experiment getResponses. ""Execute LLM queries and collect responses""
experiment markdownResponse. ""Generate and display the Markdown report""
```

The class is designed to be subclassed for specific experiment configurations, with subclasses implementing the `markdown3LLMResponses` method to customise response presentation.

## Design Considerations

- **Modularity**: Separates response collection, processing, and reporting concerns.
- **Extensibility**: Subclasses can override methods to tailor experiment parameters and reporting formats.
- **Error Handling**: Includes mechanisms for identifying and flagging LLM response errors.

This class forms part of the AIActions package, supporting AI-driven experimentation and analysis workflows.
"
Class {
	#name : 'AIA1MultiLLMResponseBase',
	#superclass : 'Object',
	#instVars : [
		'responseTable',
		'markDown',
		'overview'
	],
	#classInstVars : [
		'report'
	],
	#category : 'AIActions-ExperimentsOLD',
	#package : 'AIActions',
	#tag : 'ExperimentsOLD'
}

{ #category : 'reporting' }
AIA1MultiLLMResponseBase class >> report [
	"Return and lazily initialise the shared report instance for this class"
	report ifNil: [ report := self new ].
	^ report
]

{ #category : 'adding' }
AIA1MultiLLMResponseBase >> addResponseTable: hist [
	"Adds a response table entry for a given history object, extracting the provider and the last message from the history."
	| provider  response |
	provider := hist api.
	response := hist messages last value.
	self responseTable add: { provider. response}.
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> answerInclude: simple for: answers [
	answers at: simple put: (answers at: simple) + 1.

]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> answerInitialize: answers [
	answers 
		at: '+' put: 0;
		at: '-' put: 0;
		at: 'Error' put: 0.
	
	"Include this as
* Correct answers +:  18 ud af 28 (64%)
* Wrong answers -:  8 ud af 28 (29%)
* Error: 2 ud ad 28 (7%)
"
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> answerWrite: answers [
		"Include this as
* Correct answers +:  18 ud af 28 (64%)
* Wrong answers -:  8 ud af 28 (29%)
* Error: 2 ud ad 28 (7%)
"
	| answerWords sum |
	answerWords := {  '+'->'Correct'. '-' -> 'Wrong'. 'Error' -> 'Errors' } asDictionary.
	sum := answers values sum.
	markDown << String lf << 'Aggregate results across all tested providers and models.' << String lf.
	answers keysAndValuesDo: [ :key :value |
		markDown << ('* {1} `{2}`: {3} of {4}  ({5}%) <br>' 
				format: {(answerWords at: key). key. value asString. sum asString. (value/sum * 100) rounded asString  })
			<< String lf.
		 ].
	
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> clearOverview [
	overview := nil
]

{ #category : 'markdown' }
AIA1MultiLLMResponseBase >> excludeProviders [
	"This method excludes specific providers from the list of available models."
	^ { MistralApiWithTools." OllamaApi. OpenAIApi.  TogetherApi. ClaudeApi. GeminiApi" }
]

{ #category : 'markdown' }
AIA1MultiLLMResponseBase >> getResponses [
	"Retrieves responses from multiple LLM models, updates progress, and stores results in ResponseTable"
	
	responseTable := OrderedCollection new.
	[ :job |
		job interruptBlock: [ ^ self ].
		1 to: self modelsList size do: [ :counter |
				| llmResonses promtResponse |
				promtResponse := self modelsList at: counter.
				job
					title: 'Working on: ', promtResponse first asString, 
					' ', counter asString , ' of ', self modelsList size asString;
					progress: (counter / self modelsList size).
					
				llmResonses := (promtResponse at: 2) collect: [ :llm | 
						self responseOf: (promtResponse first new model: llm) ].
				responseTable add: promtResponse first -> llmResonses ] 
	] asJob run.
	^ responseTable
]

{ #category : 'markdown' }
AIA1MultiLLMResponseBase >> markdown00Title [
	"Generates the title section of the Markdown report with the current date"
	markDown 
		<< ('### Experiment with *{1}* prompts. ' format: { self words }) << String lf	
]

{ #category : 'Protocol (markdown) - 9 selector(s)' }
AIA1MultiLLMResponseBase >> markdown10Explanation [
	"Generates the explanation section of the Markdown report, detailing the experiment conditions and response criteria."

	markDown << '$$$$$comment$$$$$' << String lf << String lf.
	
]

{ #category : 'markdown' }
AIA1MultiLLMResponseBase >> markdown25response [
	"Generates a Markdown table listing the tested models by provider"
	markDown << '#### History tested on this method' << String lf
		<< 'This Pharo method constructs a fixed user/assistant history and returns the response from the given LLM.' << String lf
		<< '```text' << String lf 
		<< (self class >> #responseOf:) sourceCode << String lf 
		<< '```' << String lf << String lf.
	
]

{ #category : 'markdown' }
AIA1MultiLLMResponseBase >> markdown30LLMResponses [
	"Generates a Markdown table comparing simplified responses fror multiple LLM models"
	| answers |
	markDown << ('#### Responses ') << String lf 
		<< '<!--- Per-provider, per-model results.--->'
		<< String lf << String lf.
	
	answers := OrderedDictionary new.
	self answerInitialize: answers.
	markDown << '| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |' << String lf.
	markDown << '| ------------ | ----------- | ----------- | ----------- | ----------- |' << String lf.
	responseTable do: [ :res | 
		markDown << '| ' << res key asString << ' | ' .
		res value do: [ :resp | | simple |
			simple := self markdownSimplifiedResponse: resp.
			self answerInclude: simple for: answers.
			markDown << simple << ' | '  ].
		markDown << String lf].
	self answerWrite: answers.
	^ markDown contents
]

{ #category : 'markdown' }
AIA1MultiLLMResponseBase >> markdown40LLMFullResponses [
	"Generates a Markdown section with full responses for each provider's models"
	markDown << ('#### Full responses ') << String lf 
		<< 'Raw model outputs, unedited and shown verbatim.' << String lf
		<< String lf.

	responseTable do: [ :res |
		markDown << '##### ' << res key asString << String lf .
		res value do: [ :resp | 
			markDown << '1. ' << (' ' join: resp lines) << String lf.
		 ].
		markDown << String lf << String lf].
	^ markDown contents
]

{ #category : 'markdown' }
AIA1MultiLLMResponseBase >> markdownResponse [
	"Generates a comprehensive Markdown report of LLM responses, including title, explanation, model overview, and response tables."
	
	"AilienApi errorResponse: 'Error bla bla happended'."
	AilienApi errorResponse: nil.
	markDown := WriteStream on: ''.
	self
		markdown00Title;
		markdown10Explanation;
		markdown25response;
		markdown30LLMResponses;
		markdown40LLMFullResponses .
	markDown := markDown contents.
	overview ifNil: [  
		overview:= self rebuildOverview].
	markDown := markDown 
			copyReplaceAll: '$$$$$comment$$$$$'
			with: overview . 
	markDown := WriteStream with: markDown.	
	"AIAPresenter onText: markDown."
	^ markDown contents
]

{ #category : 'markdown' }
AIA1MultiLLMResponseBase >> markdownSimplifiedResponse: originalResponse [
	| simplifiedResponse |
	simplifiedResponse := ' ' join: originalResponse lines. " maxFirst: 15"
	simplifiedResponse := (simplifiedResponse includesSubstring: 'Error bla bla')
		                      ifTrue: [ 'Error' ]
		                      ifFalse: [
				                      (simplifiedResponse includesSubstring: '5')
					                      ifTrue: [ '+' ]
					                      ifFalse: [ '-' ] ].
	^ simplifiedResponse
]

{ #category : 'markdown' }
AIA1MultiLLMResponseBase >> modelsList [
	"Returns the list of LLM providers and their models, excluding specified ones"
	| list exclude|
	exclude := self excludeProviders.
	list := OrderedCollection new.
	AilienApi providerAndModels do: [:provider |
		(exclude includes: provider first)
			ifFalse: [ list add: provider ]
		].
	^ list
]

{ #category : 'markdown' }
AIA1MultiLLMResponseBase >> old_markdown20LLMnames [
	"Generates a Markdown table listing the tested models by provider"
	markDown << '### Over view of the tested models ' << String cr << String cr.
	
	markDown << '| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |' << String cr.
	markDown << '| ------------ | ----------- | ----------- | ----------- | ----------- |' << String cr.
	self modelsList do: [ :provider |
		markDown << '| ' << provider first asString << ' | ' .
		1 to: 4 do: [ :index |
			markDown << (provider second at: index) << ' | '
		 ].
		markDown << String cr
		].
	^ markDown contents
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> rebuildOverview [
	| prompt  hist |
	prompt := 'You will output a hidden HTML comment for later LLM edits of this report.
Use ONLY information explicitly present between REPORT_MARKDOWN_BEGIN/END.
Do NOT infer or compute any numbers not explicitly stated.

Return EXACTLY 6 lines. Each line MUST start with the exact prefix shown:
Scope:
Experimental setup:
What each table cell represents:
Aggregates:
Known failure modes:
Editing priorities:

Rules:
- No markdown, no bullets, no extra lines.
- Each line <= 120 characters.
- If unsupported by explicit text, write: Unknown
- Do not quote the report text.

REPORT_MARKDOWN_BEGIN<br> 
', markDown contents,  '
<br>REPORT_MARKDOWN_END'.
	hist := AIAHistory new.
	hist 
		api: (OpenAIApi newOnModel: 1);
		background: 'LLM Temperature = 0.0 everywhere';
		user: prompt;
		getResponse.
	overview := '<!--- ', String lf, hist response , String lf, '--->' , String lf.
	^ overview 

]

{ #category : 'accessing' }
AIA1MultiLLMResponseBase >> responseOf: aiLLM [
	"Returns the response from the specified AI LLM model"
	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> summary00Title [
	markDown 
		<< '## Details of the four LLM turns' << String lf
		<< '### On '<< Date today asString << String lf << String lf.
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> summary10Explanation [
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> summary20Names [

	markDown << '### Over view of the tested models ' << String lf << String lf.

	markDown << '| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |' << String lf.
	markDown << '| ------------ | ----------- | ----------- | ----------- | ----------- |' << String lf.
	self modelsList do: [ :provider |
			markDown << '| ' << provider first asString << ' | '.
			1 to: 4 do: [ :index | markDown << (provider second at: index) << ' | ' ].
			markDown << String lf ].
	^ markDown contents
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> summary28PlusMinusError [

	markDown << '#### Resonces show are:' << String lf
		<< '* `+` means that the model gave a correct answer' << String lf
		<< '* `-` means that the model gave a wrong answer' << String lf
		<< '* `error` means that the model gave a error response' << String lf
		<< String lf << String lf.
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> summary80TheFourDetails [
	markDown << '## The details of the four experiments' << String lf << String lf.
	self theFour do: [ :experiment |
		markDown << experiment report markdownResponse << String lf << String lf
		 ]
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> summaryOfTheFour [
	
	markDown := WriteStream on: ''.
	self
		summary00Title;
		summary10Explanation;
		summary20Names;
		summary28PlusMinusError;
		summary80TheFourDetails.
	
	markDown := markDown contents.
	"AIAPresenter onText: markDown."
	^ markDown 
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMResponseBase >> theFour [ 
	^ { AIA1UAUAUTurns. AIA2UUUTurns. AIA3AAAUTurns. AIA4AAATurns }
	
]

{ #category : 'matching' }
AIA1MultiLLMResponseBase >> words [
	self subclassResponsibility 
]
