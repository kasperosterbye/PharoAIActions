Class {
	#name : 'AIA2RelatedBuilderList',
	#superclass : 'Object',
	#instVars : [
		'relatedReports'
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

{ #category : 'adding' }
AIA2RelatedBuilderList >> addReport: aReport [
	relatedReports add: aReport 
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuilderList >> arxivFindRelated [
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
AIA2RelatedBuilderList >> arxivPapers [
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

{ #category : 'as yet unclassified' }
AIA2RelatedBuilderList >> buildReports [
	| max |
	relatedReports := OrderedCollection new.
	max := self arxivPapers size.
	2 to: 2 do: [ :index |
		| reference |
		reference := AIA2RelatedBuilder new: index .
		reference build.
		self addReport: reference.
	].
	^ relatedReports 
]

{ #category : 'Protocol (initialization) - 1 selector(s)' }
AIA2RelatedBuilderList >> initialize [ 
	super initialize.
	relatedReports := OrderedCollection new.
]

{ #category : 'adding' }
AIA2RelatedBuilderList >> relatedReports [
	^ relatedReports
]

{ #category : 'adding' }
AIA2RelatedBuilderList >> relatedReports: relatedReportList [
	relatedReports := relatedReportList 
]
