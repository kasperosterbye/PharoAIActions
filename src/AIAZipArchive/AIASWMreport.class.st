"
# Class Comment for AIASWMreport

## Purpose and Role in the System

The `AIASWMreport` class is designed to facilitate the automated evaluation and synthesis of scientific papers using multiple AI models. Its primary role is to generate comprehensive, multi-perspective analyses of research papers by leveraging various AI models to provide strengths, weaknesses, and missing areas. This class is particularly useful in academic and research settings where there is a need for objective, data-driven evaluations of scientific literature.

## Main Collaborators or Dependencies

The `AIASWMreport` class collaborates with several other classes and external APIs:

- **AIAHistory**: This class is used to manage the interaction history with AI models, storing prompts, responses, and other relevant information.
- **AI Models**: The class interacts with various AI models such as `Grok0Api`, `Mistral0Api`, `Together0Api`, and `OpenAI0Api` to generate evaluations of the papers.
- **FileSystem**: The class reads paper content from files stored in the file system.
- **AIAPresenter**: This class is used to present the generated Markdown reports.

## Important Invariants or Design Constraints

1. **Model Configuration**: The class must be initialized with a collection of AI models configured for testing. These models should be capable of generating coherent and relevant evaluations of scientific papers.
2. **Paper Content**: The class requires the content of the paper to be provided in a readable format. This content is used as the basis for generating evaluations.
3. **Response Synthesis**: The class must be able to synthesize responses from multiple AI models into a cohesive and comprehensive report. This involves combining individual evaluations into a unified analysis.

## Illustrative Usage Examples

### Example 1: Generating a Comprehensive Report

```smalltalk
| report paper |
paper := 'Paper1.txt'.
report := AIASWMreport new.
report forPaper: paper.
```

In this example, the `AIASWMreport` instance is used to generate a comprehensive report for the specified paper. The `forPaper:` method orchestrates the entire evaluation process, including generating initial evaluations, refining responses, and synthesizing the final report.

### Example 2: Initializing the Class with Custom Models

```smalltalk
| report models |
models := {
    Grok0Api newOnModel: 1.
    Mistral0Api newOnModel: 1.
    Together0Api newOnModel: 3.
}.
report := AIASWMreport new.
report models: models.
```

In this example, the `AIASWMreport` class is initialized with a custom collection of AI models. This allows for flexibility in configuring the models used for generating evaluations, enabling the use of specific models tailored to particular requirements.

By following these guidelines and examples, users can effectively utilize the `AIASWMreport` class to generate comprehensive, multi-perspective analyses of scientific papers.
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
	#category : 'AIAZipArchive-ExperimentsResearch',
	#package : 'AIAZipArchive',
	#tag : 'ExperimentsResearch'
}

{ #category : 'as yet unclassified' }
AIASWMreport class >> finalApi [
	^ ClaudeApi newOnModel: 4
	"^ MistralApi newOnModel: 1"
]

{ #category : 'as yet unclassified' }
AIASWMreport class >> includeAll [
	^ false
]

{ #category : 'initialization' }
AIASWMreport class >> initializeRTResults [
	"Initializes the RTResults collection for storing response data"
	<example>
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
		  GrokApi newOnModel: 2 "grok-code-fast-1".
		  TogetherApi newOnModel: 2 "Qwen3-235B-A22B" .
		  TogetherApi newOnModel: 4 "DeepSeek-V3.1".
		  OpenAIApi newOnModel: 3 "gpt-5.1" }
]

{ #category : 'default-settings' }
AIASWMreport class >> testModelsAll [
	^ {
		  GrokApi newOnModel: 2 "grok-code-fast-1".
		  TogetherApi newOnModel: 2 "Qwen3-235B-A22B" .
		  TogetherApi newOnModel: 4 "DeepSeek-V3.1".
		  OpenAIApi newOnModel: 3 "gpt-5.1" }
]

{ #category : 'default-settings' }
AIASWMreport class >> testModelsOne [
	^ {
		  MistralApi newOnModel: 1 "codestral-latest".}
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
	finalResponse api: self class finalApi.
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
		/ 'D' / 'AI-Experiments' / 'SWM' / paper) readStream contents trimBoth.
	originalPaperHistory := AIAHistory new.
	originalPaperHistory 
		api: (MistralApi newOnModel: 1);
		background: paperBackground ;
		user: 'What is the title of the paper, and who wrote it.';
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
		<< String cr << String cr << '```text' << String cr << bib << String cr << '```' << String cr << String cr
		<< '### Best, weak, and missing summary' << String cr << String cr << finalResponse messages last value << String cr
		<< String cr.
		self class includeAll ifTrue: [
			markdownJob title: 'Building Level 1'.
			MarkDown << self markdownResposeHistories.
			markdownJob title: 'Building Level 2'.
			MarkDown << self markdownRefinedResponses ]] asJob run.
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
