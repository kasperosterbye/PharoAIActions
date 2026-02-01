"
# Class Comment for AIA2RelatedBuildeArXiv

AIA2RelatedBuildeArXiv is a class designed to construct and evaluate related arXiv papers based on a background paper. It implements a multi-stage pipeline that:

1. Generates a sophisticated arXiv API query from the background paper
2. Retrieves and parses the API response
3. Evaluates the relevance of retrieved papers using an LLM
4. Scores and sorts the results
5. Returns the top related paper URLs

The class utilises both Gemini and OpenAI APIs to enhance the quality of results. It maintains state through instance variables that track each stage of processing.

## Usage Example

```st
""AIA2RelatedBuildeArXiv usage example in Pharo Playground""

""Create a new instance with default background paper""
builder := AIA2RelatedBuildeArXiv default.

""Execute the complete pipeline and inspect results""
builder response inspect.
```

The example demonstrates the complete workflow from query generation to final results, with the final expression returning the array of related paper URLs for inspection.
"
Class {
	#name : 'AIA2RelatedBuildeArXiv',
	#superclass : 'Object',
	#instVars : [
		'myPaper',
		'retrievedPapers',
		'rawApiResponse',
		'queryUrl',
		'sortedQuality',
		'qualityReport',
		'relatedPaperHTTPS'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIAExperiments-PaperWriting',
	#package : 'AIAExperiments',
	#tag : 'PaperWriting'
}

{ #category : 'accessing' }
AIA2RelatedBuildeArXiv class >> default [
	default ifNil: [ default := self basicNew. default initialize ].
	^ default 
]

{ #category : 'accessing' }
AIA2RelatedBuildeArXiv class >> new [
	self error: 'Use default'
]

{ #category : 'accessing' }
AIA2RelatedBuildeArXiv class >> resetDefault [
	<example>
	default := nil
]

{ #category : 'initialization' }
AIA2RelatedBuildeArXiv >> myPaper [
	"Returns the background paper text used as reference for query generation and relevance scoring"
	myPaper ifNil: [ myPaper := AIA2MultiLLMPaper default paperText ].
	^ myPaper 
	
]

{ #category : 'Protocol (initialization) - 10 selector(s)' }
AIA2RelatedBuildeArXiv >> prompt [
	"Constructs a prompt for generating a sophisticated arXiv API query from background paper"
	^ 'Task: Generate a sophisticated URL-encoded arXiv API query based on the abstract below.

Goal: Find the top 30 most relevant papers that discuss role sensitivity, turn-taking assumptions, or structural prompt failures in LLMs.

Constraints for your response:

You must respond ONLY with a Markdown code block containing the URL.

The code block must start with ```https.

Use a complex search_query with logical operators (AND, OR) and prefixes (ti:, abs:).

Pick key search from my paper.

Set max_results=30 and sortBy=relevance.'
	
]

{ #category : 'initialization' }
AIA2RelatedBuildeArXiv >> qualPrompt [
	"Constructs a prompt for evaluating paper relevance to background paper using retrieved papers and quality criteria"
	^ 'You have to score the quality of each external papers: ', 
	retrievedPapers asString, 
String lf, 
' in its relation to the paper in background. A high score (10) is when the paper theme is very close, and low score (0) when the paper theme has no connection to background paper. If the only relationship between the two is "LLM", it can get the score "2".',
String lf,
'Format each result EXACTLY as: {''score: N''. ''URL''. ''Brief reasoning in single quotes''}.',
String lf,
'Sort results by score from highest to lowest.',
String lf,
'Example: {''score: 3''. ''http://arxiv.org/abs/2403.07311v9''. ''KG-LLM: converting KGs to text and fine-tuning LLMs. About encoding structured KGs as NL prompts and fine-tuning. Shares the theme "how format of structured input affects behavior," but not conversational roles''}.'
]

{ #category : 'initialization' }
AIA2RelatedBuildeArXiv >> qualPromptForBatch: aBatch [
	^ 'Score these 5 external papers based on the background paper: ', aBatch asString, 
String lf, 
' in its relation to the paper in background. A high score (10) is when the paper theme is very close, and low score (0) when the paper theme has no connection to background paper. If the only relationship between the two is "LLM", it can get the score "2".',
String lf,
'Format each result EXACTLY as: {''score: N''. ''URL''. ''Brief reasoning in single quotes''}.',
String lf,
'Example: {''score: 3''. ''http://arxiv.org/abs/2403.07311v9''. ''KG-LLM: converting KGs to text and fine-tuning LLMs. About encoding structured KGs as NL prompts and fine-tuning. Shares the theme "how format of structured input affects behavior," but not conversational roles''}.'
]

{ #category : 'as yet unclassified' }
AIA2RelatedBuildeArXiv >> queryUrlString [
	"Returns the query string from the constructed arXiv API URL"
	^ (ZnUrl fromString: queryUrl ) query  at: 'search_query'
]

{ #category : 'accessing' }
AIA2RelatedBuildeArXiv >> relatedPaperHTTPS [
	"Returns the URLs of the top related arXiv papers after processing and quality scoring"
	^ relatedPaperHTTPS
]

{ #category : 'initialization' }
AIA2RelatedBuildeArXiv >> response [
	"Executes the complete pipeline to find and score related arXiv papers"
	
	self response10QueryUrl.
	self response20RetrievedPapers.
	self response30QualityReport.
	self response40SortedQuality.
	self response50RelatedPaperHTTPS.
	self halt. "Insert into the list of AIA3RelatedPaper and the list of them AIA3RelatedPaperList"
	^ relatedPaperHTTPS
]

{ #category : 'initialization' }
AIA2RelatedBuildeArXiv >> response10QueryUrl [
	"Constructs the arXiv API query URL using a prompt generated from the background paper"
	
	| hist |
	hist := AIAHistory new.
	hist
		api: (GeminiApi newOnModel: 2);
		background: self myPaper;
		user: self prompt;
		getResponse.
	queryUrl := hist response
]

{ #category : 'initialization' }
AIA2RelatedBuildeArXiv >> response20RetrievedPapers [
	"Retrieves and parses arXiv API response to extract paper URLs and summaries"
	
	| soFar idStart idEnd paperUrl summaryStart summaryEnd summaryText |
	rawApiResponse := ZnClient new get: queryUrl .
	retrievedPapers := OrderedCollection new.
	soFar := rawApiResponse indexOfSubCollection: '<entry>' startingAt: 1 ifAbsent: [ 0 ].
	[ soFar > 0 ] whileTrue: [
			idStart := rawApiResponse indexOfSubCollection: '<id>' startingAt: soFar.
			idEnd := rawApiResponse indexOfSubCollection: '</id>' startingAt: idStart.
			paperUrl := rawApiResponse copyFrom: idStart + 4 to: idEnd - 1.
			summaryStart := rawApiResponse indexOfSubCollection: '<summary>' startingAt: idEnd.
			summaryEnd := rawApiResponse indexOfSubCollection: '</summary>' startingAt: summaryStart.
			summaryText := rawApiResponse copyFrom: summaryStart + '<summary>' size to: summaryEnd - 1.
			retrievedPapers add: { paperUrl. summaryText }.
			soFar := rawApiResponse indexOfSubCollection: '<entry>' startingAt: summaryEnd ifAbsent: [ 0 ].
			].
	^ retrievedPapers
]

{ #category : 'initialization' }
AIA2RelatedBuildeArXiv >> response30QualityReport [
	"Evaluates retrieved papers in batches of 5 to maintain LLM precision and avoid context dilution."
	| batches qualityReportStream |
	qualityReportStream := WriteStream on: ''.
	batches := retrievedPapers groupsOf: 5.
	batches do: [ :batch | | hist prompt|
		prompt :=  self qualPromptForBatch: batch.
		hist := AIAHistory new.
		hist
			api: (OpenAIApi newOnModel: 1);
			background: self myPaper;
			user:prompt;
			getResponse.
		qualityReportStream << hist response << String lf ].
	qualityReport := qualityReportStream contents.
	^ qualityReport
]

{ #category : 'initialization' }
AIA2RelatedBuildeArXiv >> response40SortedQuality [
	"Processes and sorts the quality report into an array of triples (score, URL, reasoning) for further analysis"
	
	| prelimList fullList|
	prelimList := (qualityReport copyReplaceAll: '}' with: '}.') lines.
	fullList := OrderedCollection new.
	1 to: prelimList size do: [ :idx |
		(prelimList at: idx) size >= 5 ifTrue: [
			| trible |
			trible := (OpalCompiler new evaluate: (prelimList at: idx)) asArray.
			fullList add:	trible ]
	].
	sortedQuality := fullList asArray sort: [:a : b | a first last asInteger >= b first last asInteger ].
	^ sortedQuality
]

{ #category : 'initialization' }
AIA2RelatedBuildeArXiv >> response50RelatedPaperHTTPS [
	"Returns the URLs of the top related arXiv papers after processing and quality scoring"

	| index |
	relatedPaperHTTPS := OrderedCollection new.
	index := 1.
	[ index <= 5 or: [ (sortedQuality at: index) first asInteger >= 6 ] ] whileTrue: [
			relatedPaperHTTPS add: (sortedQuality at: index) second.
			index := index + 1 ].
	relatedPaperHTTPS := relatedPaperHTTPS asArray.
	^ relatedPaperHTTPS
]
