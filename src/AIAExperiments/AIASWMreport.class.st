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
	#category : 'AIAExperiments',
	#package : 'AIAExperiments'
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

{ #category : 'as yet unclassified' }
AIASWMreport >> getBiblatex [
	| bib |
	bib := AIAHistory new.
	bib 
		api: (MistralApi newOnModel: 1);
		addPreHistory: originalPaperHistory;
		user: 'Please give the complete biblatex text for the background paper; just return the bibtex, no explanation.';
	 getResponse.
	^ bib messages second value
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
AIASWMreport >> getFinalResponses [
	finalResponse := AIAHistory new.
	finalResponse api: (ClaudeApi newOnModel: 1).
	refinedResponses do: [ :model | 
		finalResponse
			user: model messages first value, ' was asked, and gave this response';
			user: model messages third value.
		].
	finalResponse
		user: 'The previous responses were from several AI systems. Based on their answers, what do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?. Do not summarize, but include aspects you think are important.'.
	finalResponse getResponse.
	finalResponse 
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

{ #category : 'RT builder' }
AIASWMreport >> getPaperHistory: id [
	originalPaperHistory := AIAHistory new.
	originalPaperHistory 
		api: (MistralApi newOnModel: 1);
		background: (self class papers at: id);
		"user: 'Please give a biblatex entry for the background paper. Respond only the biblatex in Markdown ```biblates, nothing else';"
		user: 'What is the title of the paper, and who wrote it';
		responseType: 'Your response should be written in Markdown. Your response should be smaller than header `###`';
		getResponse.
	^ originalPaperHistory 
		
	
]

{ #category : 'as yet unclassified' }
AIASWMreport >> getPaperSummary [
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

{ #category : 'as yet unclassified' }
AIASWMreport >> getRefinedResponses [
	| allResponses |
	allResponses := AIAHistory new.
	resposeHistories do: [ :hist| allResponses addPreHistory: hist ].
	refinedResponses := OrderedCollection new.
	resposeHistories do: [ :model | |refined|
		refined := AIAHistory new.
		refined
			api: model api;
			addPreHistory: allResponses;
			user: '[PROMTED] ',(model api printString);
			user: 'What do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas? Please combine your answers from the responces given sofar';
			responseType: 'Your response should be written in Markdown. Your response should be smaller than header `###`';
			getResponse.
		refinedResponses add: refined.
		]
]

{ #category : 'initialization' }
AIASWMreport >> initialize [ 
	"Initializes the AIAResponseType instance and ensures RTResults is nil"
	super initialize.
]

{ #category : 'markdown' }
AIASWMreport >> markdownRefinedResponses [
	
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
	|  title bib overview|
	title := originalPaperHistory messages second value.
	bib := self getBiblatex.
	overview := self getPaperSummary.
	
	MarkDown := WriteStream on: ''.
	MarkDown 
		<< '# Paper judgement '<< Date today asString << String cr << String cr 
		<< title << String cr << String cr
		<< overview << String cr << String cr
		<< '```' << String cr << bib << String cr << '```' << String cr << String cr
		<< '### Best, weak, and missing summary' << String cr << String cr 
		<< finalResponse messages last value << String cr << String cr 
		<< self markdownResposeHistories
		<< self markdownRefinedResponses.
	AIAPresenter onText: MarkDown contents.
	^ MarkDown contents
]

{ #category : 'markdown' }
AIASWMreport >> markdownResposeHistories [ 
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
	^ self class testModels
]

{ #category : 'accessing' }
AIASWMreport >> origunalPaperHistory [

	^ originalPaperHistory
]

{ #category : 'accessing' }
AIASWMreport >> origunalPaperHistory: anObject [

	originalPaperHistory := anObject
]
