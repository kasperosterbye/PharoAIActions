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
	#name : 'AIAMultiLLMResponseBase',
	#superclass : 'Object',
	#instVars : [
		'responseTable',
		'markDown',
		'overview'
	],
	#classInstVars : [
		'report'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'accessing' }
AIAMultiLLMResponseBase class >> overview [

	| overviewWrite |
			overviewWrite := WriteStream on: ''.
			overviewWrite 
				<< 'All prompts sent in fresh, empty conversations.' << String cr 
				<< 'Temperature = 0.0 everywhere.' << String cr
				<< 'IDNK = response contains the exact phrase `I do not know` (case-sensitive).' 
				<< String cr << String cr .
	^ overviewWrite contents
]

{ #category : 'reporting' }
AIAMultiLLMResponseBase class >> report [
	report ifNil: [ report := self new ].
	^ report
]

{ #category : 'adding' }
AIAMultiLLMResponseBase >> addResponseTable: hist [
	"Adds a response table entry for a given history object, extracting the provider and the last message from the history."
	| provider  response |
	provider := hist api.
	response := hist messages last value.
	self responseTable add: { provider. response}.
]

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase >> clearOverview [
	overview := nil
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> excludeProviders [
	"This method excludes specific providers from the list of available models."
	^ { MistralApiWithTools." OllamaApi. OpenAIApi.  TogetherApi. ClaudeApi. GeminiApi" }
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> getResponses [
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
AIAMultiLLMResponseBase >> markdown00Title [
	"Generates the title section of the Markdown report with the current date"
	markDown 
		<< ('# Experiment unbalanced turns - multiple {1} prompts. ' format: { self words at: '00' }) << String cr
		<< '### On '<< Date today asString << String cr << String cr.
	
]

{ #category : 'Protocol (markdown) - 9 selector(s)' }
AIAMultiLLMResponseBase >> markdown10Explanation [
	"Generates the explanation section of the Markdown report, detailing the experiment conditions and response criteria."

	markDown << '$$$$$comment$$$$$' << String cr << String cr.
	
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdown20LLMnames [
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

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdown25response [
	"Generates a Markdown table listing the tested models by provider"
	markDown << '### History tested on this method' << String cr
		<< '```text' << String cr 
		<< (self class >> #responseOf:) sourceCode << String cr 
		<< '```' << String cr << String cr.
	
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdown30LLMResponses [
	"Generates a Markdown table comparing simplified responses fror multiple LLM models"
	
	markDown << ('### Responses of `{1}` ' format: { self words at: '30' }) << String cr << String cr.
	
	markDown << 'Resonces show are:' << String cr
		<< '* `+` means that the model gave a correct answer' << String cr
		<< '* `-` means that the model gave a wrong answer' << String cr
		<< '* `error` means that the model gave a error response' << String cr
		<< String cr << String cr.
	markDown << '| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |' << String cr.
	markDown << '| ------------ | ----------- | ----------- | ----------- | ----------- |' << String cr.
	responseTable do: [ :res |
		markDown << '| ' << res key asString << ' | ' .
		res value do: [ :resp | markDown << ( self markdownSimplifiedResponse: resp) << ' | '  ].
		markDown << String cr].
	^ markDown contents
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdown40LLMFullResponses [
	"Generates a Markdown section with full responses for each provider's models"
	markDown << ('### Full responses for  `{1}` ' format: { self words at: '40' }) << String cr << String cr.
	
	
	responseTable do: [ :res |
		markDown << '#### ' << res key asString << String cr .
		res value do: [ :resp | 
			markDown << '1. ' << (' ' join: resp lines) << String cr.
		 ].
		markDown << String cr << String cr].
	^ markDown contents
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdownResponse [
	"Generates a comprehensive Markdown report of LLM responses, including title, explanation, model overview, and response tables."
	
	"AilienApi errorResponse: 'Error bla bla happended'."
	AilienApi errorResponse: nil.
	markDown := WriteStream on: ''.
	self
		markdown00Title;
		markdown10Explanation;
		markdown20LLMnames;
		markdown25response;
		markdown30LLMResponses;
		markdown40LLMFullResponses .
	markDown := markDown contents.
	overview ifNil: [  
		overview:= self rebuildOverview].
	markDown := markDown 
			copyReplaceAll: '$$$$$comment$$$$$'
			with: overview . 	
	AIAPresenter onText: markDown.
	^ markDown contents
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdownSimplifiedResponse: originalResponse [
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
AIAMultiLLMResponseBase >> modelsList [
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
AIAMultiLLMResponseBase >> old_markdownResponse [
	"Generates a comprehensive Markdown report of LLM responses, including title, explanation, model overview, and response tables."
	
	"AilienApi errorResponse: 'Error bla bla happended'."
	AilienApi errorResponse: nil.
	markDown := WriteStream on: ''.
	self
		markdown00Title;
		markdown10Explanation;
		markdown20LLMnames;
		markdown25response;
		markdown30LLMResponses;
		markdown40LLMFullResponses .
	self rebuildOverview.
	markDown := WriteStream on: ''.
	self
		markdown00Title;
		markdown10Explanation;
		markdown20LLMnames;
		markdown25response;
		markdown30LLMResponses;
		markdown40LLMFullResponses .
		
	AIAPresenter onText: markDown contents.
	^ markDown contents
]

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase >> rebuildOverview [
	overview := (('[background] Temperature = 0.0 everywhere. 
	 [prompt] Can you make an abstract for this report : "',  markDown ),
	 '" [responseTable] Response should be a few lines, response should be technical, not academic') q0.
	^ overview 
]

{ #category : 'accessing' }
AIAMultiLLMResponseBase >> responseOf: aiLLM [
	"Returns the response from the specified AI LLM model"
	self subclassResponsibility 
]
