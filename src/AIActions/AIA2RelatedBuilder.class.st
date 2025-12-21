Class {
	#name : 'AIA2RelatedBuilder',
	#superclass : 'Object',
	#instVars : [
		'myID',
		'externalPdfText',
		'ownPaperOriginal',
		'buildBibTeX',
		'buildTitle',
		'buildFormattedRef',
		'buildComparison'
	],
	#classInstVars : [
		'reporterx',
		'relatedReportsx'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'instance creation' }
AIA2RelatedBuilder class >> new [
	"Raise an error if new is called without an argument use new: instead"
	self error: 'Use new:'
]

{ #category : 'instance creation' }
AIA2RelatedBuilder class >> new: id [
	^ self basicNew initialize: id; yourself.
]

{ #category : 'building' }
AIA2RelatedBuilder >> build [
	self 
		build10OwnPaperOriginal;
		build20ExternalPdfText;
		build30ExternalPaperInfo;
		build40Comparison.
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> build10OwnPaperOriginal [
	ownPaperOriginal := AIA2MultiLLMPaper paper paperText .
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> build20ExternalPdfText [
	"Converts PlantUML text to an image using the plantuml command line tool."
	| directory pdfFile textFile pdf command  |
	pdf :=  ZnClient new get: 
		((AIA2RelatedBuilderList default arxivPapers at: myID ) copyReplaceAll: 'abs' with: 'pdf').
	directory := FileSystem workingDirectory.
	pdfFile := directory / ('reportFile-', myID asString, '.pdf').
	textFile := directory / ('reportFile-', myID asString, '.txt').
	pdfFile exists ifTrue: [ pdfFile delete ].
	textFile exists ifTrue: [ textFile delete ].
	pdfFile binaryWriteStreamDo: [ :stream | stream nextPutAll: pdf ].
	command := 'pdftotext {1} {2}' format: { pdfFile fullName. textFile fullName}.
	LibC system: command.
	"read the textFile..."
	externalPdfText := textFile readStream contents.
	^ externalPdfText 
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> build30ExternalPaperInfo [
	| prompt hist |
	prompt := 'Produce a biblatex for the background paper. Just for the paper itself, not its references'.
	hist := AIAHistory new.
	hist 
		api: (OpenAIApi newOnModel: 1);
		background: 'EXTERNAL PAPER: ', externalPdfText ;
		user:  prompt;
		responseType: 'Just return the response to the prompt, no other text' ;
		getResponse.
	buildBibTeX := hist response.
	hist
		user: 'And what is its title';
		getResponse.
	buildTitle := hist response.
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
	buildFormattedRef := hist response.
	^ {buildBibTeX . buildTitle . buildFormattedRef }
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> build40Comparison [
	| prompt previousResponses hist |
	prompt := self getPrompt .
	previousResponses := (String lf, String lf) join: (self class relatedReports collect: [:item | item third]).
	hist := AIAHistory new.
	hist 
		api: (OpenAIApi newOnModel: 1);
		background: 'THIS PAPER: ', ownPaperOriginal ;
		background: 'EXTERNAL PAPER: ', externalPdfText ;
		background: 'PREVIOUS RELATED WORK: ', previousResponses;
		user: 'TASK: ', prompt;
		getResponse.
	buildComparison := hist response.
	^ buildComparison 
	
	
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> getPrompt [
	^ 'Task: Decide whether the external paper is RELATED or UNRELATED to THIS PAPER.

If RELATED:
- Write a short related-work comparison (max 150 words, single paragraph).
- Start the paragraph exactly like this:
  "This paper is related to \"{1}\" ({2}), because ..."
- The paragraph must include, in this order:
  (1) one sentence stating the main overlap in problem or method,
  (2) one sentence stating the single most important difference,
  (3) one sentence stating the novelty: what THIS PAPER does that the external paper does not.

If UNRELATED:
- Output exactly the single token:
  UNRELATED

Already-covered dimensions are provided in the background as PREVIOUS RELATED WORK.
Do NOT reuse any already-covered dimension.
If the external paper only matches covered dimensions, classify it as UNRELATED.

Rules:
- No lists.
- No section headings.
- No praise or critique.
- Base all claims strictly on the provided texts.
- Do not explain why you chose UNRELATED.
' format: { buildTitle. myID asString }
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> initialize: id [
	super initialize.
	myID := id.
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> old_getExternalPdfText [
	"Converts PlantUML text to an image using the plantuml command line tool."
	| directory pdfFile textFile pdf command  |
	pdf :=  ZnClient new get: 
		((AIA2RelatedBuilderList default arxivPapers at: myID ) copyReplaceAll: 'abs' with: 'pdf').
	directory := FileSystem workingDirectory.
	pdfFile := directory / ('reportFile-', myID asString, '.pdf').
	textFile := directory / ('reportFile-', myID asString, '.txt').
	pdfFile exists ifTrue: [ pdfFile delete ].
	textFile exists ifTrue: [ textFile delete ].
	pdfFile binaryWriteStreamDo: [ :stream | stream nextPutAll: pdf ].
	command := 'pdftotext {1} {2}' format: { pdfFile fullName. textFile fullName}.
	LibC system: command.
	"read the textFile..."
	externalPdfText := textFile readStream contents.
	^ externalPdfText 
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> old_getExternalWebForIndex:  index [
	"Converts PlantUML text to an image using the plantuml command line tool."
	| directory pdfFile textFile pdf command  |
	pdf :=  ZnClient new get: 
		((AIA2RelatedBuilderList default arxivPapers at: index) copyReplaceAll: 'abs' with: 'pdf').
	directory := FileSystem workingDirectory.
	pdfFile := directory / ('reportFile-', index asString, '.pdf').
	textFile := directory / ('reportFile-', index asString, '.txt').
	pdfFile exists ifTrue: [ pdfFile delete ].
	textFile exists ifTrue: [ textFile delete ].
	pdfFile binaryWriteStreamDo: [ :stream | stream nextPutAll: pdf ].
	command := 'pdftotext {1} {2}' format: { pdfFile fullName. textFile fullName}.
	LibC system: command.
	"read the textFile..."
	externalPdfText := textFile readStream contents.
	^ externalPdfText 
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> old_getPrompt [
	^ 'Write a short related-work comparison (max 150 words, single paragraph).

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
' format: { buildTitle. (self class relatedReports size + 1) asString }
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> old_getReportFor [
	externalPdfText := self getExternalWeb.
	ownPaperOriginal := AIA2MultiLLMPaper paper paperText .
	self build40Comparison.
	^ buildComparison 
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> old_getReportFor: id [
	myID := id.
	externalPdfText := self getExternalWeb.
	ownPaperOriginal := AIA2MultiLLMPaper paper paperText .
	self build40Comparison.
	^ buildComparison 
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> old_original [
	^ AIA2MultiLLMPaper paper paperText 
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> old_pdfToString: pdf [
	"Converts PlantUML text to an image using the plantuml command line tool."
	| directory pdfFile textFile  command  |
	directory := FileSystem workingDirectory.
	pdfFile := directory / 'reportFile.pdf'.
	textFile := directory / 'reportFile.txt'.
	pdfFile binaryWriteStreamDo: [ :stream | stream nextPutAll: pdf ].
	command := 'pdftotext {1}' format: {pdfFile fullName}.
	LibC system: command.
	"read the textFile..."
	externalPdfText := textFile readStream contents.
	^ externalPdfText 
]
