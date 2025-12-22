Class {
	#name : 'AIA2RelatedBuilderList',
	#superclass : 'Object',
	#instVars : [
		'arxivList',
		'rejectedArxivList'
	],
	#classVars : [
		'ArxivListX',
		'RejectedArxivListX'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
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
AIA2RelatedBuilderList >> arxivCollect [

	arxivList := OrderedCollection new.
	rejectedArxivList := OrderedCollection new.
	[ arxivList size < 10 ] whileTrue: [
			| responses |
			responses := self arxivLLMCollect.
			responses do: [ :response |
					| pdfLocation pdfContents candidate |
					pdfLocation := response copyReplaceAll: 'abs' with: 'pdf'.
					[ pdfContents := ZnClient new get: pdfLocation ]
						on: Error
						do: [ pdfContents := nil ].
					pdfContents class name = #ByteArray ifTrue: [
							candidate := AIA2RelatedBuilder new.
							candidate
								myId: arxivList size + 1;
								myPdf: pdfContents.
							candidate build.
							candidate buildComparison = 'UNRELATED' 
								ifFalse: [ arxivList add: candidate ]
								ifTrue: [ rejectedArxivList add: candidate ] ].
				] 
	]
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> arxivLLMCollect [
	| hist |
	hist := AIAHistory new.
	hist
		api: (GeminiApi newOnModel: 2);
		background: AIA2MultiLLMArchive paperExperiment;
		user: self arxivRelated;
		getResponse.
	^ hist response lines
]

{ #category : 'arxiv' }
AIA2RelatedBuilderList >> arxivRelated [
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
