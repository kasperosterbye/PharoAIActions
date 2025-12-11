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

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase class >> paperNameSuggestion [
	"Title: The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling"
	
	"Abstract:
Most LLM conversation APIs enforce or assume alternating user-assistant message roles. When conversation histories violate this assumption—through consecutive messages from the same role—models exhibit unpredictable behavior ranging from correct responses to API errors. Testing 28 models across 7 providers with four malformed turn patterns revealed success rates from 50% to 100%, with architectural differences determining robustness. These findings expose a critical but untested assumption in production LLM systems with direct implications for prompt injection resistance and API reliability."

"""Empirical Investigation""
But actually, following Kent Beck more literally, you want THREE sections:

The Problem (or ""Background"" or ""The Turn-Taking Assumption"")
The Solution (or ""Method"" or ""Testing Approach"")
The Defence (or ""Results"" or ""Findings"")"
]

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase class >> paperNameSuggestion02 [
	"## The Solution: Experimental Method

Our investigation tests 28 models across 7 providers using four distinct patterns of malformed conversation histories. Each pattern represents a different type of turn-taking violation that could occur through prompt injection, API misuse, or multi-agent system behavior.

### Test Patterns

We designed four conversation patterns that systematically violate the alternating turn assumption:

**Pattern 1: Consecutive User Messages (user:user:user:)**  
Three sequential user messages without intervening assistant responses. This pattern simulates scenarios where a user sends multiple thoughts in succession, or where an attacker attempts to inject context by fabricating earlier user statements. The test sequence establishes two variable definitions followed by a query about their sum.

**Pattern 2: Consecutive Assistant Messages (assistant:assistant:assistant:)**  
Three sequential assistant messages with no user prompts, followed by an implicit request for response via `getResponse()`. This pattern simulates the most direct form of prompt injection: an attacker crafting conversation history that places statements in the assistant's ""mouth,"" then requesting a response as if continuing naturally. This tests whether models accept pre-loaded assistant context or reject malformed role sequences.

**Pattern 3: Interleaved with Minimal Responses (user:assistant:user:assistant:user:)**  
Standard alternation but with the assistant providing only minimal acknowledgment (""OK"") rather than substantive responses. This tests whether models can track context across turns when intermediate assistant messages contribute no semantic content. Real conversations often include such acknowledgments, making this pattern the closest to naturally-occurring edge cases.

**Pattern 4: Assistant Self-Priming (assistant:assistant:assistant:user:?)**  
Three consecutive assistant messages establishing context, followed by a minimal user query (""?""). This tests whether models can respond coherently when ""primed"" with their own statements but given minimal user guidance. It represents a sophisticated prompt injection where an attacker pre-loads assistant beliefs before asking a vague question designed to elicit those beliefs.

### Implementation

We implemented the test harness in Pharo Smalltalk using our AIActions framework, which provides a uniform interface across multiple LLM providers. The framework's `AIAHistory` class allows programmatic construction of conversation sequences with arbitrary role patterns:

```smalltalk
responseOf: aiLLM
    ""Returns the response from the specified AI LLM model for a predefined set of user prompts""
    | hist |
    hist := AIAHistory new.
    hist 
        api: aiLLM;
        user: 'aaa is 2';
        user: 'bbb is 3';
        user: 'so aaa + bbb is what';
        getResponse.
    ^ hist response.
```

This example shows Pattern 1 (consecutive user messages). The framework abstracts away provider-specific API details, allowing identical test logic across Claude, Gemini, Grok, Mistral, Ollama, OpenAI, and Together APIs.

### Task Design

The test task requires models to establish that `aaa = 2` and `bbb = 3`, then compute their sum. This design offers several advantages:

**Simplicity**: The correct answer (5) is unambiguous and requires only basic arithmetic. There is no room for subjective interpretation.

**Context Dependency**: Answering requires retaining information across multiple conversational turns. Models cannot answer correctly by responding only to the final message; they must integrate all prior context.

**Failure Mode Revelation**: Incorrect answers reveal *how* the model failed. For instance, if a model responds ""3"" after counting the letters in ""aaa"", we learn it misinterpreted the variable assignment entirely. If it responds with an apology for not having prior context, we learn it failed to access earlier messages.

**Cross-Model Fairness**: The task involves no cultural knowledge, no domain-specific terminology, and no language ambiguity. Simple arithmetic provides a level playing field for comparing models of vastly different sizes and training approaches.

**Scalability**: The identical task across all four patterns allows direct comparison of how pattern type affects success rates, independent of task difficulty.

### Scoring Methodology

We classified each model response into three categories:

- **Correct (+)**: Response correctly states the sum is 5, regardless of reasoning detail
- **Incorrect (-)**: Response provides wrong answer, refuses to answer despite having sufficient context, or misinterprets the task
- **Error**: API returns error message rather than model response (e.g., role validation failure, server error)

This classification emphasizes functional correctness from a system reliability perspective. A response is only ""correct"" if it would satisfy a user or application expecting the sum. Refusals, apologies for lack of context, or wrong arithmetic all constitute failures, even if the model's reasoning process is understandable.

### Coverage

We tested 28 models spanning seven major LLM providers, with four models selected from each provider's current offerings:

| Provider | Model 1 | Model 2 | Model 3 | Model 4 |
|----------|---------|---------|---------|---------|
| ClaudeApi | claude-sonnet-4-20250514 | claude-3-haiku-20240307 | claude-3-5-haiku-20241022 | claude-3-7-sonnet-20250219 |
| GeminiApi | gemini-2.0-flash-lite | gemini-2.5-pro | gemini-2.5-flash-lite | gemini-2.5-flash |
| GrokApi | grok-code-fast-1 | grok-4-fast-reasoning | grok-4-fast-non-reasoning | grok-3-mini |
| MistralApi | codestral-latest | mistral-small-latest | devstral-medium-2507 | mistral-medium-2508 |
| OllamaApi | gemma3:270m | mistral:latest | llama3.2:latest | phi4:latest |
| OpenAIApi | gpt-5.1 | gpt-5-mini | gpt-5-nano | gpt-4.1-nano |
| TogetherApi | Meta-Llama-3.1-70B-Instruct-Turbo | Refuel-Llm-V2 | Qwen3-235B-A22B-Thinking-2507 | DeepSeek-V3.1 |

This selection includes flagship models (Claude Sonnet 4, GPT-5.1), efficient models (Haiku variants, GPT-nano), specialized models (Grok reasoning variants, Codestral), and extremely small models (Gemma 270M). Model sizes range from 270 million to over 200 billion parameters. All tests were conducted on December 10, 2025, ensuring temporal consistency across providers.

The combination of 28 models, 4 patterns, and systematic scoring produces 112 individual test results, providing sufficient statistical power to identify both provider-level trends and model-specific behaviors."
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
		<< ('### Experiment unbalanced turns - multiple {1} prompts. ' format: { self words at: '00' }) << String cr	
]

{ #category : 'Protocol (markdown) - 9 selector(s)' }
AIAMultiLLMResponseBase >> markdown10Explanation [
	"Generates the explanation section of the Markdown report, detailing the experiment conditions and response criteria."

	markDown << '$$$$$comment$$$$$' << String cr << String cr.
	
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdown25response [
	"Generates a Markdown table listing the tested models by provider"
	markDown << '#### History tested on this method' << String cr
		<< '```text' << String cr 
		<< (self class >> #responseOf:) sourceCode << String cr 
		<< '```' << String cr << String cr.
	
]

{ #category : 'markdown' }
AIAMultiLLMResponseBase >> markdown30LLMResponses [
	"Generates a Markdown table comparing simplified responses fror multiple LLM models"
	
	markDown << ('#### Responses of `{1}` ' format: { self words at: '30' }) << String cr << String cr.
	
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
	markDown << ('#### Full responses for  `{1}` ' format: { self words at: '40' }) << String cr << String cr.
	
	
	responseTable do: [ :res |
		markDown << '##### ' << res key asString << String cr .
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
		"markdown20LLMnames;"
		markdown25response;
		markdown30LLMResponses;
		markdown40LLMFullResponses .
	markDown := markDown contents.
	overview ifNil: [  
		overview:= self rebuildOverview].
	markDown := markDown 
			copyReplaceAll: '$$$$$comment$$$$$'
			with: overview . 	
	"AIAPresenter onText: markDown."
	^ markDown 
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
AIAMultiLLMResponseBase >> old_markdown20LLMnames [
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

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase >> summary00Title [
	markDown 
		<< '## Details of the four LLM turns' << String cr
		<< '### On '<< Date today asString << String cr << String cr.
]

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase >> summary10Explanation [
]

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase >> summary20Names [

	markDown << '### Over view of the tested models ' << String cr << String cr.

	markDown << '| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |' << String cr.
	markDown << '| ------------ | ----------- | ----------- | ----------- | ----------- |' << String cr.
	self modelsList do: [ :provider |
			markDown << '| ' << provider first asString << ' | '.
			1 to: 4 do: [ :index | markDown << (provider second at: index) << ' | ' ].
			markDown << String cr ].
	^ markDown contents
]

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase >> summary28PlusMinusError [

	markDown << '#### Resonces show are:' << String cr
		<< '* `+` means that the model gave a correct answer' << String cr
		<< '* `-` means that the model gave a wrong answer' << String cr
		<< '* `error` means that the model gave a error response' << String cr
		<< String cr << String cr.
]

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase >> summary80TheFourDetails [
	markDown << '## The details of the four experiments' << String cr << String cr.
	self theFour do: [ :experiment |
		markDown << experiment report markdownResponse << String cr << String cr
		 ]
]

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase >> summaryOfTheFour [
	
	markDown := WriteStream on: ''.
	self
		summary00Title;
		summary10Explanation;
		summary20Names;
		summary28PlusMinusError;
		summary80TheFourDetails.
	
	markDown := markDown contents.
	AIAPresenter onText: markDown.
	^ markDown 
]

{ #category : 'as yet unclassified' }
AIAMultiLLMResponseBase >> theFour [ 
	^ { AIA1UAUAUTurns. AIA2UUUTurns. AIA3AAAUTurns. AIA4AAATurns }
	
]

{ #category : 'matching' }
AIAMultiLLMResponseBase >> words [
	self subclassResponsibility 
]
