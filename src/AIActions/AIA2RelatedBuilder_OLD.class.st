Class {
	#name : 'AIA2RelatedBuilder_OLD',
	#superclass : 'Object',
	#instVars : [
		'myId',
		'myPdf',
		'externalPdfText',
		'ownPaperOriginal',
		'buildBibTeX',
		'buildTitle',
		'buildFormattedRef',
		'buildComparison'
	],
	#category : 'AIActions-AIAPaperBuilding',
	#package : 'AIActions',
	#tag : 'AIAPaperBuilding'
}

{ #category : 'building' }
AIA2RelatedBuilder_OLD >> build [
	"Builds the related work comparison for a paper by fetching external PDF text, processing it, and generating a comparison with the original paper."
	self 
		build10OwnPaperOriginal;
		build20ExternalPdfText;
		build30ExternalPaperDetails;
		build40Comparison.
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder_OLD >> build10OwnPaperOriginal [
	"Sets the original paper text for comparison purposes"
	ownPaperOriginal := "AIA2MultiLLMPaper paper paperText" 
		AIA2MultiLLMArchive paperExperiment .
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder_OLD >> build20ExternalPdfText [
	"Fetches external PDF text, converts it to a readable format, and stores it for comparison purposes"
	| directory pdfFile textFile  command  |
	directory := FileSystem workingDirectory.
	pdfFile := directory / ('reportFile.pdf').
	textFile := directory / ('reportFile.txt').
	pdfFile exists ifTrue: [ pdfFile delete ].
	textFile exists ifTrue: [ textFile delete ].
	pdfFile binaryWriteStreamDo: [ :stream | stream nextPutAll: myPdf ].
	command := 'pdftotext {1} {2}' format: { pdfFile fullName. textFile fullName}.
	LibC system: command.
	"read the textFile..."
	externalPdfText := textFile readStream contents.
	^ externalPdfText 
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder_OLD >> build30ExternalPaperDetails [
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
AIA2RelatedBuilder_OLD >> build40Comparison [
	| prompt previousResponses hist |
	prompt := self getPrompt .
	previousResponses := AIA2RelatedBuilderList default summaryOfRelatedWork.
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

{ #category : 'accessing' }
AIA2RelatedBuilder_OLD >> buildComparison [
	^ buildComparison
]

{ #category : 'accessing' }
AIA2RelatedBuilder_OLD >> buildTitle [

	^ buildTitle
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder_OLD >> getPrompt [
	"Returns the prompt for generating a related-work comparison between the external paper and the original paper"
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
' format: { buildTitle. myId asString }
]

{ #category : 'accessing' }
AIA2RelatedBuilder_OLD >> initialize [
	super initialize.
]

{ #category : 'accessing' }
AIA2RelatedBuilder_OLD >> initialize: id [
	super initialize.
]

{ #category : 'accessing' }
AIA2RelatedBuilder_OLD >> myId: anObject [

	myId := anObject
]

{ #category : 'accessing' }
AIA2RelatedBuilder_OLD >> myPdf: anObject [

	myPdf := anObject
]
