"
# AIASWMreport Class Comment

## Purpose and Role in the System

The `AIASWMreport` class serves as a **multi-AI scientific paper analysis and reporting engine**, designed to systematically evaluate and synthesise critiques of academic papers using diverse large language models (LLMs). Its primary role is to automate the generation of structured, multi-perspective assessments of research documents, facilitating rapid and comprehensive peer-review-like analysis.

This class is a core component of an **experimental research pipeline** for evaluating the capabilities of AI models in academic critique, meta-analysis, and synthesis. It orchestrates interactions between multiple AI providers (e.g., Mistral, Claude, Grok, Gemini, OpenAI) to produce layered evaluations: independent model assessments, integrated refinements, and a final consolidated report. The output is a **Markdown-formatted document** that can be exported for further review or publication.

`AIASWMreport` is particularly suited for **comparative AI research**, **automated literature review**, and **scientific paper evaluation workflows**, where human-like analysis is augmented by machine intelligence.

---

## Main Collaborators or Dependencies

### **Core Dependencies**
- **`AIAHistory`**: A key collaborator that encapsulates the interaction history with a single AI model, including prompts, responses, and API configuration. `AIASWMreport` creates and manages multiple `AIAHistory` instances to track evaluations from different models.
- **AI API Wrappers**: Classes such as `MistralApi`, `ClaudeApi`, `GrokApi`, `GeminiApi`, and `OpenAIApi`, which provide standardised interfaces to external AI services. These are configured dynamically via `testModels` and related class-side methods.
- **`MicHTMLDocument`** (optional): Used for converting Markdown reports into HTML for web-based presentation.

### **Data and Configuration**
- **FileSystem**: Used to read input papers (as `.txt` files) and write output reports (`.md` and optionally `.html`).
- **`OrderedCollection`**: Central to managing collections of models, response histories, and refined responses.
- **`Job` framework**: Used to provide progress feedback and interruptible execution for long-running analysis tasks, ensuring user control and transparency.

### **External Systems**
- **AI Model Providers**: The class depends on external APIs (e.g., Mistral, Anthropic, OpenAI) for generating evaluations. Network availability, API keys, and rate limits are implicit constraints.

---

## Important Invariants and Design Constraints

### **Invariants**
1. **Multi-Stage Evaluation Pipeline**:
   - The analysis process is **three-tiered**:
     1. **Level 1**: Independent evaluations by each model.
     2. **Level 2**: Each model refines its analysis after seeing all Level 1 responses.
     3. **Level 3**: A high-level model (e.g., Claude) synthesises all refined responses into a final assessment.
   - This structure ensures **diversity of perspective** and **meta-analytic depth**.

2. **Immutability of Input Paper**:
   - The original paper content, once loaded via `getPaperHistory:`, remains **unchanged** throughout the analysis. All evaluations are derived from this fixed input.

3. **Progressive State Construction**:
   - The instance variables (`models`, `resposeHistories`, `refinedResponses`, `finalResponse`, `originalPaperHistory`) are populated **sequentially** and must not be modified out of order. For example, `getRefinedResponses` depends on the completion of `getEvaluations`.

4. **Markdown Output Format**:
   - All reports are generated in **Markdown**, ensuring portability, readability, and ease of conversion to other formats (e.g., HTML, PDF).

### **Design Constraints**
- **Interruptibility**: All long-running operations (e.g., API calls across multiple models) are wrapped in `Job` blocks, allowing users to **cancel** the analysis at any stage without data corruption.
- **Configurability via Class Methods**: Model selection, output inclusion, and API endpoints are controlled via class-side methods (e.g., `testModels`, `includeAll`, `finalApi`), enabling **experimentation without subclassing**.
- **Error Resilience**: While not explicitly error-handled, the design assumes that individual model failures (e.g., API timeouts) do not halt the entire process. Failed models are skipped, and the pipeline continues with available data.
- **Resource Intensity**: The class is **computationally and financially expensive** to run, as it involves multiple API calls across several high-end models. It is intended for **batch processing** rather than real-time use.

---

## Illustrative Usage Examples

### Example 1: Generating a Full Report for a Single Paper

```smalltalk
""Create a report instance and generate a full Markdown analysis for a paper file.""
| report paperFile markdownReport |

paperFile := 'RustBelt.txt'.  ""Assumed to be in the configured directory""
report := AIASWMreport new.
markdownReport := report forPaper: paperFile.

""Save the report to disk (optional)""
report mdFileFor: paperFile markdown: markdownReport.
```

**When to Use**:
- When evaluating a single research paper for strengths, weaknesses, and gaps.
- When a **detailed, multi-AI perspective** is required for internal review or peer feedback.
- When generating **standardised reports** for a collection of papers (e.g., conference submissions).

---

### Example 2: Customising Model Selection for an Experiment

```smalltalk
""Override default models to use only fast, lightweight models for a quick analysis.""
AIASWMreport class compile: 'testModels ^ { MistralApi newOnModel: 1 }'.

| report markdown |
report := AIASWMreport new.
report getPaperHistory: 'Paper1.txt'.
report getEvaluations.
report getRefinedResponses.
markdown := report markdownReport.

""View the report in a presenter""
AIAPresenter onText: markdown.
```

**When to Use**:
- When conducting **ablation studies** or comparing the performance of specific AI models.
- When **time or cost constraints** require limiting the number of models or API calls.
- When testing **new prompts or evaluation strategies** without full-scale deployment.

---

### Example 3: Batch Processing Multiple Papers

```smalltalk
""Process all papers in the directory and generate reports.""
| papers |

papers := #('Paper1.txt' 'Paper2.txt' 'Paper3.txt').
papers do: [ :paper |
    | report |
    report := AIASWMreport new.
    report forPaper: paper.
    Transcript show: 'Generated report for ', paper; cr.
].
```

**When to Use**:
- When evaluating **multiple submissions** (e.g., for a conference or journal).
- When building a **corpus of AI-generated critiques** for meta-research.
- When automating **pre-screening** of papers for relevance or quality.

---

## Summary

`AIASWMreport` is a **powerful, configurable tool** for AI-driven scientific paper analysis, designed for researchers and developers working at the intersection of **natural language processing** and **academic research**. It excels in scenarios requiring **multi-perspective synthesis**, **automated critique**, and **scalable evaluation workflows**, but should be used judiciously due to its resource demands. Its design emphasises **modularity**, **interruptibility**, and **reproducibility**, making it suitable for both exploratory and production use in research settings.
"
Class {
	#name : 'AIASWM2report',
	#superclass : 'Object',
	#instVars : [
		'paperTitle',
		'models',
		'resposeHistories',
		'refinedResponses',
		'finalResponse',
		'originalPaperHistory'
	],
	#classVars : [
		'MarkDown'
	],
	#category : 'AIAZipArchive-ExperimentsResearch',
	#package : 'AIAZipArchive',
	#tag : 'ExperimentsResearch'
}

{ #category : 'default-settings' }
AIASWM2report class >> finalApi [
	^ ClaudeApi newOnModel: 4
]

{ #category : 'default-settings' }
AIASWM2report class >> forFile: fileName [
	| root txtFile |
	root := self swmDirectory.
	txtFile := (fileName first: (fileName size - 4)) , '.txt'.
	(root, txtFile ) asFileReference exists 
		ifFalse: [ "Assume it is a pdf file"
			AilienOCR pdf: fileName in: root ].
	^ self new forPaper: txtFile 
	
]

{ #category : 'default-settings' }
AIASWM2report class >> includeAll [
	^ false
]

{ #category : 'default-settings' }
AIASWM2report class >> swmDirectory [
	^  '/Users/kasper/D/AI-Experiments/SWM/'.
    
]

{ #category : 'default-settings' }
AIASWM2report class >> testModels [
	^ {
		  GrokApi newOnModel: 4.
		  GeminiApi newOnModel: 1.
		  ClaudeApi newOnModel: 3.
		  OpenAIApi newOnModel: 4 }
]

{ #category : 'file in/out' }
AIASWM2report >> fileFor: paper fileType: ft [
	^ FileSystem disk root / 'Users' / 'kasper' 
        / 'D' / 'AI-Experiments' / 'SWPM' 
        / (paper copyReplaceAll: '.txt' with: ft)
]

{ #category : 'markdown' }
AIASWM2report >> forPaper: paper [

	| md |
	paperTitle := paper.
	self halt.
	self
		getPaperHistory: paper;
		getEvaluations;
		getRefinedResponses;
		getFinalResponses.
	md := self markdownReport.
	self mdFileFor: paper markdown: md.
	^ md
]

{ #category : 'SWM builder' }
AIASWM2report >> getEvaluations [
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
						user: self swmDefinition ;
						user: 'What do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?';
						responseType: 'Your response should be written in Markdown.';
						getResponse .
				resposeHistories add: hist 
				]
	] asJob run
]

{ #category : 'SWM builder' }
AIASWM2report >> getFinalResponses [
	"The method generates a consolidated evaluation of a paper by synthesizing responses from multiple AI models. It uses a high-level model (Claude) to combine and refine all previous evaluations into a final comprehensive assessment."

	finalResponse := AIAHistory new.
	finalResponse api: self class finalApi.
	[ :job |
		job interruptBlock: [ ^ self ].
		job title: 'Doing level 3 - Finalizing '.
		refinedResponses do: [ :model |
				finalResponse
					user: model messages third value ].
		
		finalResponse	
			user: self swmDefinition ;
			user:
			'The previous responses were from several AI systems reading and understanding the original paper. Based on their answers, what do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?. Do not summarize, but include aspects you think are important. To ensure your response style, you are not given the original paper.'.
		finalResponse getResponse ] asJob run.
	^ finalResponse
]

{ #category : 'SWM builder' }
AIASWM2report >> getModels [
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
AIASWM2report >> getPaperHistory: paper [
	"Method reads paper content, creates history object with Mistral API, and extracts title and authors in Markdown format"
	| paperBackground |
	paperBackground := (self class swmDirectory asFileReference / paper)
				readStream contents trimBoth.
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
AIASWM2report >> getPaperSummary [
	"Generates a concise 20-line Markdown summary of the paper including title and authors"
	| summary |
	summary := AIAHistory new.
	summary 
		api: (MistralApi newOnModel: 1);
		addPreHistory: originalPaperHistory;
		user: '[responsetype] please answer in Markdown';
		user: 'Please give a 20 line summary of the paper';
	 getResponse.
	^ summary messages third value
]

{ #category : 'SWM builder' }
AIASWM2report >> getRefinedResponses [
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
					user: self swmDefinition ;
					user:
						'What do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas? Please combine your answers from the responces given sofar';
					responseType: 'Your response should be written in Markdown. Your response should be smaller than header `###`';
					getResponse.
				refinedResponses add: refined ] ] asJob run
]

{ #category : 'initialization' }
AIASWM2report >> initialize [ 
	"Initializes the AIASWMreport instance by setting up the models collection."
	super initialize.
	models := self class testModels
]

{ #category : 'markdown' }
AIASWM2report >> markdownRefinedResponses [
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
AIASWM2report >> markdownReport [
	"The method generates a comprehensive Markdown report combining all AI evaluations of a scientific paper."

	| title  overview |
	[ :markdownJob |
		markdownJob interruptBlock: [ ^ self ].
		title := originalPaperHistory messages second value.
		markdownJob title: 'Building overview'.
		overview := self getPaperSummary.
		markdownJob title: 'Building Biblatex'.
		
		MarkDown := WriteStream on: ''.
		MarkDown << '# Paper judgement ' << Date today asString << String cr << String cr 
			<< title << String cr << String cr << overview
			<< String cr << String cr 
			<< 'SWM only evaluates the text itself. Related work is not examined.'
			<< String cr << String cr
			<< '### Best, weak, and missing summary' << String cr << String cr 
			<< finalResponse messages last value << String cr
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
AIASWM2report >> markdownResposeHistories [ 
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

{ #category : 'file in/out' }
AIASWM2report >> mdFileFor: paper markdown: md [
	| file |
	file := self fileFor: paper fileType: '.md'.
   file writeStreamDo: [ :s | s nextPutAll: md ]
]

{ #category : 'as yet unclassified' }
AIASWM2report >> swmDefinition [
	^ 'Strength is what is in the article and is good. Weakness is what is only mentioned briefly, but is important. Missing is what is not mentioned, but would have been a strength. '
]
