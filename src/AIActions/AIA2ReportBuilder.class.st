Class {
	#name : 'AIA2ReportBuilder',
	#superclass : 'Object',
	#instVars : [
		'webLocation',
		'textFromWeb',
		'textBib',
		'bibText',
		'textTitle',
		'paperOriginal',
		'relatedCompare'
	],
	#classInstVars : [
		'reporter',
		'relatedReports'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'adding' }
AIA2ReportBuilder class >> addReport: aReport [
	relatedReports add: aReport 
]

{ #category : 'examples' }
AIA2ReportBuilder class >> clearReporter [
	<example>
	reporter := nil.
	relatedReports := OrderedCollection new.
]

{ #category : 'adding' }
AIA2ReportBuilder class >> clearSelectedReports [ 
	relatedReports := OrderedCollection new 
]

{ #category : 'adding' }
AIA2ReportBuilder class >> relatedReports [
	^ relatedReports
]

{ #category : 'accessing' }
AIA2ReportBuilder class >> reporter [
	reporter ifNil: [ reporter := self new ].
	^ reporter
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> arxivFindRelated [
"Works for 'GeminiApi: gemini-2.5-pro'"
^ 'Task: Return between 5 and 20 lines.

Important:
- Only use papers you already know from training (no web lookup, no guessing).
- It is NOT required that the papers are recent.
- I am explicitly interested in what YOU already know to exist.
- Treat the title below as the title of MY paper; do not question whether it exists.

Output format:
- Each line must be EITHER:
  - a single URL matching: ^https://arxiv\.org/abs/\d{4}\.\d{5}$
  - OR the single token: UNKNOWN
- No other text is allowed.
- One item per line.
- Do not repeat the same URL twice.

Selection criterion:
- List the closest papers you know that relate to:
  chat role structure,
  turn-taking patterns,
  or sensitivity to message roles in chat-based LLM APIs.
- Prefer papers that isolate structural effects over content.

Paper title (my paper):
"The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling"

Background (full paper text):
' q0: [ AIA2MultiLLMPaper paper paperText ].
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> arxivPapers [
"was the response form aaa1"
	^ 'https://arxiv.org/abs/2307.03172
https://arxiv.org/abs/2307.15043
https://arxiv.org/abs/2305.14726
https://arxiv.org/abs/2210.11416
https://arxiv.org/abs/2305.13598
https://arxiv.org/abs/2302.06476
https://arxiv.org/abs/2305.08382
https://arxiv.org/abs/2304.05335
https://arxiv.org/abs/2201.11903
https://arxiv.org/abs/2305.15771' lines
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> compare [
	| prompt hist |
	prompt := self getPrompt .
	hist := AIAHistory new.
	hist 
		api: (OpenAIApi newOnModel: 1);
		background: 'THIS PAPER: ', paperOriginal ;
		background: 'EXTERNAL PAPER: ', textFromWeb ;
		user: 'TASK: ', prompt;
		getResponse.
	relatedCompare := hist response.
	^ relatedCompare 
	
	
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> getExternalPaperInfo [
	| prompt hist |
	prompt := 'Produce a biblatex for the background paper. Just for the paper itself, not its references'.
	hist := AIAHistory new.
	hist 
		api: (OpenAIApi newOnModel: 1);
		background: 'EXTERNAL PAPER: ', textFromWeb ;
		user:  prompt;
		responseType: 'Just return the response to the prompt, no other text' ;
		getResponse.
	textBib := hist response.
	hist
		user: 'And what is its title';
		getResponse.
	textTitle := hist response.
	hist
		user: 'Task: Render a single human-readable reference from the BibTeX entry below.
Rules:
- Use only information present in the BibTeX.
- Do not add or infer missing data.
- Output plain text only (no Markdown, no lists).
- Use this format exactly:

Authors.
Title.
Venue or arXiv identifier, year. Optional version/date if present.
URL

If a field is missing, omit that line silently.';
		getResponse.
	bibText := hist response.
	^ {textBib . textTitle . bibText }
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> getExternalWebForIndex:  index [
	"Converts PlantUML text to an image using the plantuml command line tool."
	| directory pdfFile textFile pdf command  |
	pdf :=  ZnClient new get: ((self arxivPapers at: index) copyReplaceAll: 'abs' with: 'pdf').
	directory := FileSystem workingDirectory.
	pdfFile := directory / 'reportFile.pdf'.
	textFile := directory / 'reportFile.txt'.
	pdfFile binaryWriteStreamDo: [ :stream | stream nextPutAll: pdf ].
	command := 'pdftotext {1}' format: {pdfFile fullName}.
	LibC system: command.
	"read the textFile..."
	textFromWeb := textFile readStream contents.
	^ textFromWeb 
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> getPrompt [
	^ 'Write a short related-work comparison (max 300 words, single paragraph).

Start the paragraph exactly like this:
"This paper is related to \"{1}\" ({2}), because ..."

In the paragraph:
- Briefly state the main overlap in problem or method.
- State the single most important difference.
- End with one clear novelty sentence explaining what THIS PAPER does that the external paper does not.

Rules:
- No lists.
- No section headings.
- No praise or critique.
- Base all claims strictly on the provided texts.
- If a claim cannot be supported, state it explicitly.
' format: { textTitle. (self class relatedReports size + 1) asString }
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> getReportFor: id [
	textFromWeb := self getExternalWebForIndex: id.
	paperOriginal := AIA2MultiLLMPaper paper paperText .
	self compare.
	^ relatedCompare 
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> getReports [
	| max |
	self class clearSelectedReports.
	max := self arxivPapers size.
	1 to: max do: [ :index |
		self getExternalWebForIndex:  index.
		self getExternalPaperInfo.
		self getReportFor: index.
		self class addReport: {textTitle. textBib. relatedCompare} 
	].
	^ self class relatedReports
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> old_getPdfFrom: arXivAbs [
	"https://arxiv.org/abs/2302.12173"
	| pdf |
	pdf := ZnClient new get: (arXivAbs copyReplaceAll: 'abs' with: 'pdf').
	^ pdf
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> old_getReport [
	self error: 'Should not be called'.
	textFromWeb := self getExternalWebForIndex: 1.
	paperOriginal := AIA2MultiLLMPaper paper paperText .
	self compare.
	^ relatedCompare 
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> old_getReports [
	| max |
	self class clearSelectedReports.
	max := self arxivPapers size.
	1 to: 3 do: [ :index |
		self getExternalWebForIndex:  index.
		self getExternalPaperInfo.
		self getReportFor: index.
		self class addReport: {textTitle. textBib. relatedCompare} 
	].
	^ self class relatedReports
]

{ #category : 'accessing' }
AIA2ReportBuilder >> original [
	^ AIA2MultiLLMPaper paper paperText 
]

{ #category : 'as yet unclassified' }
AIA2ReportBuilder >> pdfToString: pdf [
	"Converts PlantUML text to an image using the plantuml command line tool."
	| directory pdfFile textFile  command  |
	directory := FileSystem workingDirectory.
	pdfFile := directory / 'reportFile.pdf'.
	textFile := directory / 'reportFile.txt'.
	pdfFile binaryWriteStreamDo: [ :stream | stream nextPutAll: pdf ].
	command := 'pdftotext {1}' format: {pdfFile fullName}.
	LibC system: command.
	"read the textFile..."
	textFromWeb := textFile readStream contents.
	^ textFromWeb 
]
