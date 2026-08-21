"
AIASWMreport builds a multi-model “paper judgement” markdown report from a paper text file.

What it does
- Reads the paper background text from a file stored in the SWM directory.
- Asks AI models to extract a short title/author header, then evaluate the paper.
- Runs evaluations in multiple levels:
  1) Level 1: each model gives independent strengths, weaknesses, and missing areas.
  2) Level 2: models refine by synthesising the Level 1 outputs into a combined review.
  3) Level 3: a final pass combines/refines the judgement into a final summary.
- Optionally writes the final markdown report to a .md file based on the paper title.
- Can display the report text using AIAPresenter.

Input / output
- Input: a .txt paper filename (derived from a target paper file) located under swmDirectory.
- Output: a markdown string containing sections like:
  - “Paper judgement” (date, paper title, a brief paper summary, and final judgement)
  - “Level 1 AI based readings…” (one subsection per model)
  - “Level 2 AI based readings…” (a synthesised subsection per model, if enabled)

Examples
- If the paper text is in `…/SWM/<paperName>.txt`, then `forFile: '…/SWM/<paperName>.pdf'` (or the .txt itself) will eventually produce `<paperName>.md`.
- Level 1 examples of questions asked to each model:
  - “What are its strengths, weaknesses, and missing areas?”
- Level 2 example of synthesis prompt:
  - “Please combine your answers from the responses given so far.”
"
Class {
	#name : 'AIASWMreport',
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
		'Markdown'
	],
	#category : 'AIAZipArchive-ExperimentsResearch',
	#package : 'AIAZipArchive',
	#tag : 'ExperimentsResearch'
}

{ #category : 'default-settings' }
AIASWMreport class >> finalApi [
	"Returns Claude API configured for model 4 final responses"
	^ ClaudeApi newOnModel: 4
]

{ #category : 'default-settings' }
AIASWMreport class >> forFile: fileName [
	"Creates report from file by locating or OCR extracting its text content"
	| root txtFile |
	root := self swmDirectory.
	txtFile := (fileName first: (fileName size - 4)) , '.txt'.
	(root, txtFile ) asFileReference exists 
		ifFalse: [ "Assume it is a pdf file"
			AilienOCR pdf: fileName in: root ].
	^ self new forPaper: txtFile; yourself 
	
]

{ #category : 'default-settings' }
AIASWMreport class >> includeAll [
	"Whether to include all items in the markdown report output"
	^ false
]

{ #category : 'default-settings' }
AIASWMreport class >> swmDirectory [
	^  '/Users/kasper/D/AI-Experiments/SWM/'.
    
]

{ #category : 'default-settings' }
AIASWMreport class >> testModels [
	"Returns a set of configured model api instances for the research report"
	^ {
		  GrokApi newOnModel: 4.
		  GeminiApi newOnModel: 1.
		  ClaudeApi newOnModel: 3.
		  OpenAIApi newOnModel: 4 }
]

{ #category : 'file in/out' }
AIASWMreport >> fileMarkdown: md [
	| title file |
	title := (paperTitle copyReplaceAll: '.txt' with: '.md').
	file := self class swmDirectory asFileReference / title .
	file writeStreamDo: [ :s | s nextPutAll: md ]
]

{ #category : 'markdown' }
AIASWMreport >> forPaper: paper [
	"Creates report by reading a paper title and running multi model evaluations"

	| md |
	paperTitle := paper.
	self
		get1PaperHistory;
		get2Evaluations;
		get2RefinedResponses;
		get4FinalResponses.
	md := self markdownReport.
	self fileMarkdown: md.
	^ md
]

{ #category : 'SWM builder' }
AIASWMreport >> get1PaperHistory [
	"Loads paper text from swm directory, asks for title and author, stores history"
	| paperBackground |
	paperBackground := (self class swmDirectory asFileReference / paperTitle )
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
AIASWMreport >> get2Evaluations [
	"Runs level 1 evaluations with each model and stores their strength weakness and missing areas"

	resposeHistories := OrderedCollection new.
	[ :level | level interruptBlock: [ ^ self ].
		models do: [ :model | | hist |
				level title: 'Doing level 1 - Finished ', resposeHistories size asString, 
						' of ', models size asString , ' models'.
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
AIASWMreport >> get2RefinedResponses [
	"Refines level one analyses by synthesising each model responses into combined review"
	
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

{ #category : 'SWM builder' }
AIASWMreport >> get4FinalResponses [
	"Finalises Level 3 combining model analyses and producing final markdown judgement"

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
AIASWMreport >> getPaperSummary [
	"Build paper summary using Mistral from original paper history and return markdown"
	| summary |
	summary := AIAHistory new.
	summary 
		api: (MistralApi newOnModel: 1);
		addPreHistory: originalPaperHistory;
		user: '[responsetype] please answer in Markdown';
		user: 'Please give a 20 line summary of the paper. 
			Do not include paper name, do not include its authors';
	 getResponse.
	^ summary messages third value
]

{ #category : 'initialization' }
AIASWMreport >> initialize [ 
	"Initialises superclass and selects models for subsequent paper evaluation steps"
	super initialize.
	models := self class testModels
]

{ #category : 'markdown' }
AIASWMreport >> markdownRefinedResponses [
	"Builds Markdown section describing level 2 refined model analyses"
		
	Markdown ifNil: [   Markdown := WriteStream on: ''].
	Markdown 
		<< '## Level 2 AI based readings of the paper' << String cr << String cr
		<< 'Each AI model was then shown ALL Level 1 responses and asked 
to synthesize them into a combined analysis. This tests whether models 
can integrate multiple viewpoints coherently.

This approach reveals both individual AI perspectives and their ability 
to perform meta-analysis across different viewpoints.' << String cr << String cr.
	refinedResponses do: [ :rh |
		Markdown << '### ' "<< rh messages first key << ' -> '" <<  rh messages first value << String cr .
		Markdown << rh messages second key << ' -> ' <<  rh messages second value << String cr .
		
		Markdown << rh messages third key << ' -> ' << String cr << 
			rh messages third value << String cr <<  String cr<< String cr.
		
		 ].
	^ Markdown contents
]

{ #category : 'markdown' }
AIASWMreport >> markdownReport [
	"Builds the paper judgement markdown including overview and evaluations"
	
	| title  overview |
	[ :markdownJob |
		markdownJob interruptBlock: [ ^ self ].
		title := originalPaperHistory messages second value.
		markdownJob title: 'Building overview'.
		overview := self getPaperSummary.
		markdownJob title: 'Building Biblatex'.
		

		Markdown := WriteStream on: ''.
		Markdown << '# Paper judgement ' << Date today asString << String lf << String lf 
					<< title << String lf << String lf 
					<< overview << String lf << String lf << String lf << String lf
					<< '### Best, weak, and missing summary' << String lf << String lf 
					<< finalResponse messages last value << String lf << String lf.
		self class includeAll ifTrue: [
			markdownJob title: 'Building Level 1'.
			Markdown << self markdownResposeHistories.
			markdownJob title: 'Building Level 2'.
			Markdown << self markdownRefinedResponses ]] asJob run.
	AIAPresenter onText: Markdown contents.
	^ Markdown contents
]

{ #category : 'markdown' }
AIASWMreport >> markdownResposeHistories [ 
	"Builds Level 1 AI analysis markdown sections from model response histories"
	
	Markdown ifNil: [   Markdown := WriteStream on: ''].
	Markdown 
		<< '## Level 1 AI based readings of the paper' << String cr << String cr
		<< 'Each AI model received the paper and was asked: "What are its 
strengths, weaknesses, and missing areas?" These are independent, 
single-perspective analyses.' << String cr << String cr.
	resposeHistories do: [ :rh |
		Markdown << '### ' "<< rh messages first key << ' -> ' " <<  rh messages first value << String cr .
		Markdown << rh messages second key << ' -> ' <<  rh messages second value << String cr .
		
		Markdown << rh messages third key << ' -> ' << String cr << 
			rh messages third value << String cr <<  String cr<< String cr.
		
		 ].
	^ Markdown contents
]
