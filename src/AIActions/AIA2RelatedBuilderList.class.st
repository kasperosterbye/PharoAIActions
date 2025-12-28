"
# Class Comment for AIA2RelatedBuilderList

The `AIA2RelatedBuilderList` class manages collections of arXiv paper references related to LLM conversation handling research. It maintains two primary collections:

- `arxivList`: Contains validated, relevant papers that meet the selection criteria
- `rejectedArxivList`: Stores papers that were evaluated but deemed unrelated

The class provides functionality to:
1. Collect and validate arXiv references using LLM APIs
2. Process PDF content from arXiv papers
3. Generate summaries of related work
4. Maintain exclusion lists to avoid duplicate recommendations

## Usage Example

```st
""AIA2RelatedBuilderList usage example in Playground""

""Get the default instance""
builder := AIA2RelatedBuilderList default.

""Collect related papers (may take several minutes)""
builder arxivCollect.

""View the collected papers""
builder getArxivList.

""Generate a summary of related work""
builder summaryOfRelatedWork inspect.
```

The class is designed for research purposes in the field of LLM conversation handling, particularly focusing on turn-taking patterns and role sensitivity in chat-based APIs.
"
Class {
	#name : 'AIA2RelatedBuilderList',
	#superclass : 'Object',
	#instVars : [
		'arxivList',
		'rejectedArxivListX'
	],
	#classVars : [
		'ArxivListX',
		'RejectedArxivListX'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIActions-AIAPaperBuilding',
	#package : 'AIActions',
	#tag : 'AIAPaperBuilding'
}

{ #category : 'accessing' }
AIA2RelatedBuilderList class >> default [
	default ifNil: [ default := self basicNew. default initialize ].
	^ default 
]

{ #category : 'accessing' }
AIA2RelatedBuilderList class >> new [
	self error: 'Use default'
]

{ #category : 'accessing' }
AIA2RelatedBuilderList class >> resetDefault [
	<example>
	default := nil
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> arxiv20CollectInner: url [
    | pdfLocation pdfContents candidate |
    pdfLocation := url copyReplaceAll: 'abs' with: 'pdf'.
    pdfContents := [ ZnClient new get: pdfLocation ] on: Error do: [ nil ].
    
    (pdfContents notNil and: [ pdfContents isKindOf: ByteArray ]) ifTrue: [
        candidate := AIA2RelatedBuilder new.
        candidate
            myId: arxivList size + 1;
            myHttps: pdfLocation;
            externalPdfText: (self arxiv25ExternalPdfText: pdfContents);
            ownPaperOriginal: AIA2MultiLLMArchive paperExperiment.
        
        "Skip the 'if related' check and go straight to details and summary"
        candidate build30ExternalPaperDetails. 
        candidate build40Comparison. "Generates the actual text for the paper"
        
        arxivList add: candidate ]
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> arxiv25ExternalPdfText: pdfBytes [
	"Fetches external PDF text, converts it to a readable format, and stores it for comparison purposes"
	| directory pdfFile textFile  command  |
	directory := FileSystem workingDirectory.
	pdfFile := directory / ('reportFile.pdf').
	textFile := directory / ('reportFile.txt').
	pdfFile exists ifTrue: [ pdfFile delete ].
	textFile exists ifTrue: [ textFile delete ].
	pdfFile binaryWriteStreamDo: [ :stream | stream nextPutAll: pdfBytes ].
	command := 'pdftotext {1} {2}' format: { pdfFile fullName. textFile fullName}.
	LibC system: command.
	"read the textFile..."
	^ textFile readStream contents
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> arxivCollect [
    | builder relatedURLs |
    arxivList ifNotNil: [ ^ self ].
    arxivList := OrderedCollection new.
    "rejectedArxivList := OrderedCollection new."

    "New Integration Point"
    builder := AIA2RelatedBuildeArXiv default.
    builder relatedPaperHTTPS ifNil: [ builder response ].
    relatedURLs := builder relatedPaperHTTPS.

    relatedURLs do: [ :url | 
        self arxiv20CollectInner: url ]
]

{ #category : 'accessing' }
AIA2RelatedBuilderList >> getArxivList [
	^ arxivList
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> old2_arxiv20CollectInner: url [
    | pdfLocation pdfContents candidate |
    pdfLocation := url copyReplaceAll: 'abs' with: 'pdf'.
    pdfContents := [ ZnClient new get: pdfLocation ] on: Error do: [ nil ].
    
    pdfContents class name = #ByteArray  ifTrue: [
        candidate := AIA2RelatedBuilder new.
        candidate
            myId: arxivList size + 1;
            myHttps: pdfLocation;
            externalPdfText: (self arxiv25ExternalPdfText: pdfContents);
            ownPaperOriginal: AIA2MultiLLMArchive paperExperiment;
            build30ExternalPaperDetails; "Crucial for Title/BibTeX"
            build41Comparison. "Sets the RELATED/UNRELATED state"
            
        candidate relatedState = 'RELATED'
            ifTrue: [ arxivList add: candidate ]
            ifFalse: [ rejectedArxivList add: candidate ] ]
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> old_arxiv10LLMCollect [
	| hist |
	hist := AIAHistory new.
	hist
		api: (GeminiApi newOnModel: 2);
		background: AIA2MultiLLMArchive paperExperiment;
		user: self arxiv15Related;
		getResponse.
	^ hist response lines
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> old_arxiv15Related [
	| both excludedText |
	both := arxivList | rejectedArxivList collect: [ :a | a buildTitle ].
	excludedText := both isEmpty
		ifTrue: [ 'None' ]
		ifFalse: [ String lf join: both ].

	^ 'Task: Propose arXiv papers that are CLOSEST to THIS PAPER, based on the THIS PAPER text in the background.

Hard focus (must match THIS PAPER):
- Chat-role metadata / message roles (user vs assistant) in chat APIs
- Role-sequence / turn-pattern effects (e.g., AAA vs AAAU / user-final gating)
- Deterministic failure modes like echoing the last instruction instead of answering
- Cross-provider / cross-model empirical testing of such structural effects

Important:
- Use ONLY papers you genuinely remember from training. No web lookup. No guessing.
- If you are not confident, output UNKNOWN.

Exclude (already seen):
', excludedText, '

Output format:
- Output 3 to 6 lines.
- Each line must be EITHER:
  - a single URL matching: ^https://arxiv\.org/abs/\d{4}\.\d{5}$
  - OR the single token: UNKNOWN
- No other text. One item per line. No duplicates.

Selection rule:
- Prefer papers about chat formatting / role handling / conversation templates over general “prompting” papers.
- Prefer empirical characterizations of failure modes over broad benchmarks.

Paper title (THIS PAPER):
"The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling"'

]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> old_arxiv20CollectInner: response [

	| pdfLocation pdfContents candidate |
	pdfLocation := response copyReplaceAll: 'abs' with: 'pdf'.
	[ pdfContents := ZnClient new get: pdfLocation ]
		on: Error
		do: [ pdfContents := nil ].
	pdfContents class name = #ByteArray ifTrue: [
			candidate := AIA2RelatedBuilder new.
			candidate
				myId: arxivList size + 1;
				myHttps: pdfLocation;
				externalPdfText: (self arxiv25ExternalPdfText: pdfContents);
				ownPaperOriginal: AIA2MultiLLMArchive paperExperiment;
				"AIA2MultiLLMPaper paper paperText"
				build41Comparison.
			candidate relatedState = 'UNRELATED'
				ifFalse: [ arxivList add: candidate ]
				ifTrue: [ rejectedArxivList add: candidate ] ]
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> old_arxivCollect [
	arxivList ifNotNil: [ ^ self ]. "use the class side resetDefault to restart"
	arxivList := OrderedCollection new.
	rejectedArxivList := OrderedCollection new.
	[ arxivList size < 2 ] whileTrue: [
			| responses |
			responses := self arxiv10LLMCollect.
			responses do: [ :response | self arxiv20CollectInner: response ] 
	]
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> old_arxivRelated [
    | both excludedText |
	 both := arxivList  | rejectedArxivList collect: [ :a | a buildTitle ].
    excludedText := both isEmpty 
        ifTrue: [ 'None' ] 
        ifFalse: [ String lf join: both ].
	^ 'Task: Return around 5 lines.

Important:
- Only use papers you already know from training (no web lookup, no guessing).
- It is NOT required that the papers are recent.
- I am explicitly interested in what YOU already know to exist.
- Treat the title below as the title of MY paper; do not question whether it exists.

EXCLUDE these URLs (already found):
', excludedText, '

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
"The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling"'
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> previous_arxivPapers [
"was the response form aaa1"
	^ 'https://arxiv.org/abs/2307.03172
https://arxiv.org/abs/2307.15043
https://arxiv.org/abs/2305.13598
https://arxiv.org/abs/2305.14726
https://arxiv.org/abs/2210.11416
https://arxiv.org/abs/2302.06476
https://arxiv.org/abs/2305.08382
https://arxiv.org/abs/2304.05335
https://arxiv.org/abs/2201.11903
https://arxiv.org/abs/2305.15771' lines
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> summaryOfRelatedWork [
	| summary |
	summary := (String lf, String lf) join: (arxivList collect: [:item | item buildComparison]).
	^ summary 
]
