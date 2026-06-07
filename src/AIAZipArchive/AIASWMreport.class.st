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
AIASWMreport class >> last [
	AIAPresenter onText: MarkDown contents
]

{ #category : 'as yet unclassified' }
AIASWMreport class >> mdRemoveBib: mdFile [
	| file md md2 include|
	file := FileSystem disk root / 'Users' / 'kasper' / 'D' 
			/ 'AI-Experiments' / 'SWM' / mdFile.
	md := file readStream contents trimBoth.
	include := true.
	md2 := OrderedCollection new.
	md lines do: [ :line |
		line = '```text' ifTrue: [ include := false ].
		include 
			ifTrue: [ md2 add: line ].
		line = '```' ifTrue: [ include := true ]
	].
	self halt.
	file delete.
	file writeStreamDo: [ :s | s nextPutAll: (String lf join: md2) ] 
]

{ #category : 'as yet unclassified' }
AIASWMreport class >> mdToHtlm: mdFile [
	| md |
	md := ( (FileSystem disk root / 'Users' / 'kasper' / 'D' 
			/ 'AI-Experiments' / 'SWM' / 'IWST2026_paper_XXX23.md') 
				readStream contents trimBoth) readStream contents trimBoth.
]

{ #category : 'as yet unclassified' }
AIASWMreport class >> paperNumbers [
	^ ('IWST2026_paper_XXX2.md
IWST2026_paper_XXX3.md
IWST2026_paper_XXX4.md
IWST2026_paper_XXX5.md
IWST2026_paper_XXX6.md
IWST2026_paper_XXX9.md
IWST2026_paper_XXX10.md
IWST2026_paper_XXX13.md
IWST2026_paper_XXX14.md
IWST2026_paper_XXX16.md
IWST2026_paper_XXX17.md
IWST2026_paper_XXX18.md
IWST2026_paper_XXX19.md
IWST2026_paper_XXX21.md
IWST2026_paper_XXX22.md
IWST2026_paper_XXX23.md
IWST2026_paper_XXX24.md' lines 
collect: [ :line | (line withoutPrefix: 'IWST2026_paper_XXX') withoutSuffix: '.md'  ] )
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
		  GeminiApi newOnModel: 1 "" .
		  TogetherApi newOnModel: 4 "DeepSeek-V3.1".
		  OpenAIApi newOnModel: 3 "gpt-5.1" }
]

{ #category : 'default-settings' }
AIASWMreport class >> testModelsAll [
	^ {
		  GrokApi newOnModel: 2 "grok-code-fast-1".
		  GeminiApi newOnModel: 1 "" .
		  TogetherApi newOnModel: 4 "DeepSeek-V3.1".
		  OpenAIApi newOnModel: 3 "gpt-5.1" }
]

{ #category : 'default-settings' }
AIASWMreport class >> testModelsOne [
	^ {
		  MistralApi newOnModel: 1 "codestral-latest".}
]

{ #category : 'as yet unclassified' }
AIASWMreport >> fileFor: paper fileType: ft [
	^ FileSystem disk root / 'Users' / 'kasper' 
        / 'D' / 'AI-Experiments' / 'SWM' 
        / (paper copyReplaceAll: '.txt' with: ft)
]

{ #category : 'markdown' }
AIASWMreport >> forPaper: paper [

	| md |
	self
		getPaperHistory: paper;
		getEvaluations;
		getRefinedResponses;
		getFinalResponses.
	md := self markdownReport.
	self mdFileFor: paper markdown: md.
	self htmlFileFor: paper markdown: md.
	^ md
]

{ #category : 'SWM builder' }
AIASWMreport >> getBiblatex [
	"This method generates BibTeX citation information for the analyzed paper by prompting an AI model with the paper's content. It creates a new AIAHistory instance, configures it with the Mistral API, adds the paper's background information, and requests a complete BibTeX entry. The method returns the BibTeX string from the AI's response."
	| bib |
	bib := AIAHistory new.
	bib 
		api: (OpenAIApi newOnModel: 2);
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

{ #category : 'as yet unclassified' }
AIASWMreport >> htmlFileFor: paper markdown: md [
	| html file |
	file := self fileFor: paper fileType: '.html'.
	html := MicHTMLDocument new
        fromMicrodown: md;
        contents.
   file writeStreamDo: [ :s | s nextPutAll: html ]
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

	| title  overview |
	[ :markdownJob |
		markdownJob interruptBlock: [ ^ self ].
		title := originalPaperHistory messages second value.
		markdownJob title: 'Building overview'.
		overview := self getPaperSummary.
		markdownJob title: 'Building Biblatex'.
		

		MarkDown := WriteStream on: ''.
		MarkDown << '# Paper judgement ' << Date today asString << String cr << String cr << title << String cr << String cr << overview
		<< String cr << String cr << String cr << String cr
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
AIASWMreport >> markdownReport_OLD [
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

{ #category : 'as yet unclassified' }
AIASWMreport >> mdFileFor: paper markdown: md [
	| file |
	file := self fileFor: paper fileType: '.md'.
   file writeStreamDo: [ :s | s nextPutAll: md ]
]
