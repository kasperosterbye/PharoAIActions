"
# Class Comment for AIA2RelatedBuilder

The `AIA2RelatedBuilder` class is responsible for constructing and managing related-work comparisons between academic papers. It facilitates the automated generation of BibTeX entries, formatted references, and comparative analyses of external research papers relative to a specified original paper.

## Key Features

- **PDF Processing**: Converts external PDF documents to text for analysis
- **Comparison Generation**: Produces structured related-work comparisons following specific formatting rules
- **BibTeX Generation**: Creates BibTeX entries for external papers
- **Reference Formatting**: Generates human-readable references from BibTeX data
- **Relatedness Assessment**: Determines if external papers are related to the original work

## Usage Example

```st
""AIA2RelatedBuilder usage example in Playground""

| builder comparison |
builder := AIA2RelatedBuilder new
    myId: 123;
    myHttps: 'https://example.com/paper.pdf';
    ownPaperOriginal: 'This is the text of our original paper...';
    build.

""Fetch and process the external PDF""
builder build20ExternalPdfText.

""Generate the comparison""
comparison := builder build40Comparison.

""Inspect the results""
{ builder buildBibTeX. builder buildTitle. builder buildFormattedRef. comparison }
```

The builder follows a specific workflow:
1. Initialise with paper identifiers and original text
2. Process external PDF content
3. Generate comparison materials
4. Produce final comparison output

The generated comparisons follow strict formatting rules to ensure consistency in academic writing.
"
Class {
	#name : 'AIA2RelatedBuilder',
	#superclass : 'Object',
	#instVars : [
		'myId',
		'myHttps',
		'externalPdfText',
		'ownPaperOriginal',
		'relatedState',
		'buildBibTeX',
		'buildTitle',
		'buildFormattedRef',
		'buildComparison'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'building' }
AIA2RelatedBuilder >> build [
	"Builds the related work comparison for a paper by fetching external PDF text, processing it, and generating a comparison with the original paper."
	self 
		build10OwnPaperOriginal;"
		build20ExternalPdfText;
		build30ExternalPaperDetails;"
		build40Comparison.
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> build10OwnPaperOriginal [
	"Sets the original paper text for comparison purposes"
	ownPaperOriginal := "AIA2MultiLLMPaper paper paperText" 
		AIA2MultiLLMArchive paperExperiment .
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> build30ExternalPaperDetails [
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

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> build41Comparison [
    | prompt hist previous |
    prompt := self getPromptRelatedOrUnrelated.
    previous := AIA2RelatedBuilderList default summaryOfRelatedWork.
    hist := AIAHistory new.
    hist 
        api: (OpenAIApi newOnModel: 1);
        background: 'THIS PAPER: ', ownPaperOriginal;
        background: 'PREVIOUS RELATED WORK: ', previous;
        background: 'EXTERNAL PAPER: ', externalPdfText;
        user: 'TASK: ', prompt;
        getResponse.
    relatedState := hist response.
    ^ relatedState
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> buildComparison [
	^ buildComparison
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> buildTitle [

	^ buildTitle
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> externalPdfText [

	^ externalPdfText
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> externalPdfText: anObject [

	externalPdfText := anObject
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> getFormattedReference [
	^ buildFormattedRef
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> getPrompt [

	^ 'Task: Write a short related-work comparison paragraph (max 150 words).

Primary Goal:
Analyze the EXTERNAL PAPER in relation to THIS PAPER.

Narrative Continuity:
- Review the PREVIOUS RELATED WORK provided in the background.
- If the EXTERNAL PAPER addresses the same dimension as a previous paper, acknowledge it (e.g., "Similar to [Paper X], this work examines...").
- Do not repeat explanations of concepts already defined in PREVIOUS RELATED WORK.

Structure:
- Start exactly with: "This paper is related to \"{1}\" ({2}), because ..."
- Sentence 1: State the main overlap with THIS PAPER (referencing PREVIOUS RELATED WORK if they share a theme).
- Sentence 2: State the single most important difference from THIS PAPER.
- Sentence 3: State the novelty: what THIS PAPER does that the EXTERNAL PAPER does not.

Rules:
- Strictly single paragraph. No lists.
- No praise or critique.
- Direct, technical language only.' 
format: { buildTitle . myId asString }
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> getPromptRelatedOrUnrelated [
	^ 'Task: Decide whether the EXTERNAL PAPER is RELATED or UNRELATED to THIS PAPER.

Definition:
- RELATED means: the external paper addresses the same phenomenon, mechanism, or engineering constraint as THIS PAPER
  (e.g., chat role metadata, message-role sequencing, turn-structure sensitivity in chat-based LLM APIs),
  and contributes non-trivially beyond what is already covered in PREVIOUS RELATED WORK.
- UNRELATED means: it does not, or it only repeats dimensions already covered.

Output:
- Output exactly ONE token: RELATED or UNRELATED.
- No other text. No punctuation. No explanation.

Rule:
- If the external paper only matches dimensions already covered in PREVIOUS RELATED WORK, output UNRELATED.'

]

{ #category : 'accessing' }
AIA2RelatedBuilder >> initialize [
	super initialize.
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> initialize: id [
	super initialize.
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> myHttps [

	^ myHttps
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> myHttps: anObject [

	myHttps := anObject
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> myId: anObject [

	myId := anObject
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> old_build20ExternalPdfText [
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
AIA2RelatedBuilder >> old_build41Comparison [
	| prompt  hist |
	prompt := self getPromptRelatedOrUnrelated .
	self halt.
	hist := AIAHistory new.
	hist 
		api: (OpenAIApi newOnModel: 1);
		background: 'THIS PAPER: ', ownPaperOriginal ;
		background: 'EXTERNAL PAPER: ', externalPdfText ;
		user: 'TASK: ', prompt;
		getResponse.
	relatedState := hist response.
	^ relatedState 
	
	
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilder >> old_getPrompt [
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
AIA2RelatedBuilder >> ownPaperOriginal [

	^ ownPaperOriginal
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> ownPaperOriginal: anObject [

	ownPaperOriginal := anObject
]

{ #category : 'printing' }
AIA2RelatedBuilder >> printOn: aStream [
	myHttps ifNil: [ super printOn: aStream. ^ self ].
	aStream << '(' << myId asString << ') ' << myHttps. 
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> relatedState [

	^ relatedState
]

{ #category : 'accessing' }
AIA2RelatedBuilder >> relatedState: anObject [

	relatedState := anObject
]
