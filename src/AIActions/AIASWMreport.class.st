"
# Class Comment for AIASWMreport

The `AIASWMreport` class is designed to facilitate automated analysis of scientific papers using multiple AI models. It implements a multi-stage evaluation process that:

1. Extracts and processes paper content
2. Generates independent evaluations from multiple AI models
3. Synthesizes these evaluations into a cohesive report
4. Produces a comprehensive Markdown report combining all findings

## Key Features

- **Multi-model evaluation**: Uses different AI providers (Grok, Mistral, Together, etc.) to generate diverse perspectives
- **Three-tiered analysis**:
  - Level 1: Independent evaluations of each model
  - Level 2: Synthesized evaluations combining all Level 1 responses
  - Final: Consolidated assessment from a high-level model
- **Comprehensive reporting**: Generates detailed Markdown reports including:
  - Paper metadata (title, authors, BibTeX)
  - Summary of findings
  - Strengths, weaknesses, and missing areas
  - Individual model evaluations

## Usage Example

```st
""Create and execute a report for a specific paper""
report := AIASWMreport new.
report forPaper: 'Paper1.txt'.

""Inspect the generated Markdown report""
report markdownReport inspect.
```

This class is particularly useful for:
- Automated literature reviews
- Comparative analysis of AI model evaluations
- Systematic assessment of scientific papers
- Generating reproducible evaluation reports
"
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
		'ResponseList'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'initialization' }
AIASWMreport class >> initializeRTResults [
	"Initializes the RTResults collection for storing response data"
	<example>
]

{ #category : 'default-settings' }
AIASWMreport class >> old_testModels [	
	"Returns a dictionary of AI models and their versions for testing purposes"
	^ { 
		GrokApi -> { 2 "Grok-4-fast-reasoning". 1 "grok-code-fast-1" }.
		MistralApi -> { 1 "codestral-latest". 3 "devstral-medium-2507" }.
		TogetherApi -> { 4 "DeepSeek-V3.1". 3 "Qwen3-235B-A22B"  }.
		OpenAIApi -> { 1 "gpt-5.1" }".
		GeminiApi -> { 2  ""gemini-2.5-pro"" }"
	}
	
]

{ #category : 'default-settings' }
AIASWMreport class >> papers [
	| papers |
	papers := { 'Paper1.txt' .'Paper2.txt' . 'Paper3.txt' . 'Paper4.txt' . 'Paper5.txt' . 'RustBelt.txt' }.
	^ papers collect: [ :p |
	(FileSystem disk root / 'Users' / 'kasper' / 'D' / 'AIExperiments' / 'SWM' / p) readStream contents trimBoth ].
 	
]

{ #category : 'default-settings' }
AIASWMreport class >> prompts [
	^ { 
		'This is a short background report. What do you see as its strengts, weaknesses, and missing areas?'. }
]

{ #category : 'default-settings' }
AIASWMreport class >> testModels [
	^ {
		  GrokApi newOnModel: 1 "grok-code-fast-1".
		  GrokApi newOnModel: 2 "Grok-4-fast-reasoning".
		  MistralApi newOnModel: 1 "codestral-latest".
		  MistralApi newOnModel: 3 "devstral-medium-2507".
		  TogetherApi newOnModel: 3 "Qwen3-235B-A22B" .
		  TogetherApi newOnModel: 4 "DeepSeek-V3.1".
		  OpenAIApi newOnModel: 1 "gpt-5.1" .
		  "GeminiApi newOnModel: 2 ""gemini-2.5-pro"" "}
]

{ #category : 'markdown' }
AIASWMreport >> forPaper: paper [
	"This method generates a comprehensive AI-based report for a given paper by orchestrating a multi-stage evaluation process."
	self 
		getPaperHistory: paper;
		getEvaluations;
		getRefinedResponses;
		getFinalResponses.
	^ self markdownReport 
]

{ #category : 'SWM builder' }
AIASWMreport >> getBiblatex [
	"This method generates BibTeX citation information for the analyzed paper by prompting an AI model with the paper's content. It creates a new AIAHistory instance, configures it with the Mistral API, adds the paper's background information, and requests a complete BibTeX entry. The method returns the BibTeX string from the AI's response."
	| bib |
	bib := AIAHistory new.
	bib 
		api: (MistralApi newOnModel: 1);
		addPreHistory: originalPaperHistory;
		user: 'Please give the complete biblatex text for the background paper; just return the bibtex, no explanation.';
	 getResponse.
	^ bib messages second value
]

{ #category : 'SWM builder' }
AIASWMreport >> getEvaluations [
	"This method generates independent evaluations of a paper using multiple AI models, creating a collection of responses that form the first level of analysis."

	resposeHistories := OrderedCollection new.
	[ :level | level interruptBlock: [ ^ self ].
		models do: [ :model | | hist |
				level title: 'Doing level 1 - Finished ', resposeHistories size asString, ' of ', models size asString , ' models'.
				level progress: (resposeHistories size / models size ).
					hist := AIAHistory new.
					hist
						api: model;
						addPreHistory: originalPaperHistory;
						user: '[PROMTED] ' , model printString;
						user: 'What do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?';
						responseType: 'Your response should be written in Markdown.';
						getResponse .
				resposeHistories add: hist 
				]
	] asJob run
]

{ #category : 'SWM builder' }
AIASWMreport >> getFinalResponses [
	"The method generates a consolidated evaluation of a paper by synthesizing responses from multiple AI models. It uses a high-level model (Claude) to combine and refine all previous evaluations into a final comprehensive assessment."

	finalResponse := AIAHistory new.
	finalResponse api: (ClaudeApi newOnModel: 1).
	[ :job |
		job interruptBlock: [ ^ self ].
		job title: 'Doing level 3 - Finalizing '.
		refinedResponses do: [ :model |
				finalResponse
					user: model messages first value , ' was asked, and gave this response';
					user: model messages third value ].
		finalResponse user:
			'The previous responses were from several AI systems. Based on their answers, what do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?. Do not summarize, but include aspects you think are important.'.
		finalResponse getResponse ] asJob run.
	^ finalResponse
]

{ #category : 'SWM builder' }
AIASWMreport >> getModels [
	"This method initializes and returns a collection of AI models configured for testing purposes. It creates instances of different AI providers with specific model versions, ensuring a diverse set of models for evaluation."
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

{ #category : 'SWM builder' }
AIASWMreport >> getPaperHistory: paper [
	"Method reads paper content, creates history object with Mistral API, and extracts title and authors in Markdown format"
	| paperBackground |
	paperBackground := (FileSystem disk root / 'Users' / 'kasper' 
		/ 'D' / 'AIExperiments' / 'SWM' / paper) readStream contents trimBoth.
	originalPaperHistory := AIAHistory new.
	originalPaperHistory 
		api: (MistralApi newOnModel: 1);
		background: paperBackground ;
		user: 'What is the title of the paper, and who wrote it';
		responseType: 'Your response should be written in Markdown. Your response should be smaller than header three `###`';
		getResponse.
	^ originalPaperHistory 
		
	
]

{ #category : 'SWM builder' }
AIASWMreport >> getPaperSummary [
	"Generates a concise 20-line Markdown summary of the paper including title and authors"
	| summary |
	summary := AIAHistory new.
	summary 
		api: (MistralApi newOnModel: 1);
		addPreHistory: originalPaperHistory;
		user: '[responsetype] please answer in Markdown';
		user: 'Please give a 20 line summary of the paper. Include paper name and its authors';
	 getResponse.
	^ summary messages third value
]

{ #category : 'SWM builder' }
AIASWMreport >> getRefinedResponses [
	"The method synthesizes multiple AI evaluations into refined responses by combining all initial assessments and prompting each model to integrate them into a cohesive analysis."

	| allResponses |
	allResponses := AIAHistory new.
	resposeHistories do: [ :hist | allResponses addPreHistory: hist ].
	refinedResponses := OrderedCollection new.
	[ :level | level interruptBlock: [ ^ self ].
		resposeHistories do: [ :model |
				| refined |
				level title: 'Doing level 2 - Finished ' , refinedResponses size asString 
						, ' of ' , resposeHistories size asString , ' models'.
				level progress: refinedResponses size / resposeHistories size.
				refined := AIAHistory new.
				refined
					api: model api;
					addPreHistory: allResponses;
					user: '[PROMTED] ' , model api printString;
					user:
						'What do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas? Please combine your answers from the responces given sofar';
					responseType: 'Your response should be written in Markdown. Your response should be smaller than header `###`';
					getResponse.
				refinedResponses add: refined ] ] asJob run
]

{ #category : 'initialization' }
AIASWMreport >> initialize [ 
	"Initializes the AIASWMreport instance by setting up the models collection."
	super initialize.
	models := self class testModels
]

{ #category : 'markdown' }
AIASWMreport >> markdownRefinedResponses [
	"The method generates a Markdown-formatted summary of refined AI evaluations, combining multiple perspectives into a cohesive analysis."
	
	MarkDown ifNil: [   MarkDown := WriteStream on: ''].
	MarkDown 
		<< '## Level 2 AI based readings of the paper' << String cr << String cr
		<< 'Each AI model was then shown ALL Level 1 responses and asked 
to synthesize them into a combined analysis. This tests whether models 
can integrate multiple viewpoints coherently.

This approach reveals both individual AI perspectives and their ability 
to perform meta-analysis across different viewpoints.' << String cr << String cr.
	refinedResponses do: [ :rh |
		MarkDown << '### ' "<< rh messages first key << ' -> '" <<  rh messages first value << String cr .
		MarkDown << rh messages second key << ' -> ' <<  rh messages second value << String cr .
		
		MarkDown << rh messages third key << ' -> ' << String cr << 
			rh messages third value << String cr <<  String cr<< String cr.
		
		 ].
	^ MarkDown contents
]

{ #category : 'markdown' }
AIASWMreport >> markdownReport [
	"The method generates a comprehensive Markdown report combining all AI evaluations of a scientific paper."

	| title bib overview |
	[ :markdownJob |
		markdownJob interruptBlock: [ ^ self ].
		title := originalPaperHistory messages second value.
		markdownJob title: 'Building overview'.
		overview := self getPaperSummary.
		markdownJob title: 'Building Biblatex'.
		bib := self getBiblatex.

		MarkDown := WriteStream on: ''.
		MarkDown << '# Paper judgement ' << Date today asString << String cr << String cr << title << String cr << String cr << overview
		<< String cr << String cr << '```' << String cr << bib << String cr << '```' << String cr << String cr
		<< '### Best, weak, and missing summary' << String cr << String cr << finalResponse messages last value << String cr
		<< String cr.
		markdownJob title: 'Building Level 1'.
		MarkDown << self markdownResposeHistories.
		markdownJob title: 'Building Level 2'.
		MarkDown << self markdownRefinedResponses ] asJob run.
	AIAPresenter onText: MarkDown contents.
	^ MarkDown contents
]

{ #category : 'markdown' }
AIASWMreport >> markdownResposeHistories [ 
	"The method generates a Markdown-formatted summary of initial AI evaluations, showing individual model perspectives on paper strengths, weaknesses, and missing areas."
	MarkDown ifNil: [   MarkDown := WriteStream on: ''].
	MarkDown 
		<< '## Level 1 AI based readings of the paper' << String cr << String cr
		<< 'Each AI model received the paper and was asked: "What are its 
strengths, weaknesses, and missing areas?" These are independent, 
single-perspective analyses.' << String cr << String cr.
	resposeHistories do: [ :rh |
		MarkDown << '### ' "<< rh messages first key << ' -> ' " <<  rh messages first value << String cr .
		MarkDown << rh messages second key << ' -> ' <<  rh messages second value << String cr .
		
		MarkDown << rh messages third key << ' -> ' << String cr << 
			rh messages third value << String cr <<  String cr<< String cr.
		
		 ].
	^ MarkDown contents
]

{ #category : 'markdown' }
AIASWMreport >> modelsList [
	"The method retrieves the list of AI models configured for testing in the AIASWMreport class."
self halt. "DELETE ME if not used..."
	^ self class testModels
]
