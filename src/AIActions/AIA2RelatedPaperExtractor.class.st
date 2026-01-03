"
# Class Comment for AIA2RelatedPaperExtractor

The `AIA2RelatedPaperExtractor` class is responsible for extracting and processing information from arXiv papers. It handles the retrieval of paper content from arXiv URLs, text extraction from PDFs, and the use of a language model to analyse and summarise the paper's content.

## Key Responsibilities

- **HTTP Handling**: Manages arXiv HTTP URLs to fetch paper content.
- **Text Extraction**: Extracts text from PDF versions of arXiv papers.
- **Content Analysis**: Uses a language model (LLM) to generate structured summaries of papers, including titles, authors, BibTeX entries, and paper descriptions.

## Usage Example

```st
""Example usage in the Playground""
| extractor paperInfo |
extractor := AIA2RelatedPaperExtractor on: 'https://arxiv.org/abs/2305.12345'.
paperInfo := extractor build.
paperInfo inspect.
```

This example demonstrates how to create an instance of `AIA2RelatedPaperExtractor`, build the extracted information, and inspect the results. The `build` method orchestrates the entire process, including fetching the PDF, extracting text, and generating the structured summary using the LLM.
"
Class {
	#name : 'AIA2RelatedPaperExtractor',
	#superclass : 'Object',
	#instVars : [
		'arXivHTTP',
		'arXivText',
		'arXivExtracted'
	],
	#classVars : [
		'ExtractorList'
	],
	#category : 'AIActions-AIAPaperBuilding',
	#package : 'AIActions',
	#tag : 'AIAPaperBuilding'
}

{ #category : 'examples' }
AIA2RelatedPaperExtractor class >> clearExtractorList [
	<example>
	ExtractorList := OrderedCollection new
]

{ #category : 'examples' }
AIA2RelatedPaperExtractor class >> extractorList [
	"Returns the shared extractor list for the AIA2RelatedPaperExtractor class"
   ^ ExtractorList
]

{ #category : 'instance creation' }
AIA2RelatedPaperExtractor class >> llmModel [
	"Returns a new instance of the Claude API configured for model version 1"
	^ GrokApi newOnModel: 2
]

{ #category : 'instance creation' }
AIA2RelatedPaperExtractor class >> new [
	"Use on: instead"
	self error: 'Use on: instead'
]

{ #category : 'instance creation' }
AIA2RelatedPaperExtractor class >> on: http [
	"Creates a new instance of AIA2RelatedPaperExtractor configured with the given HTTP client"
	| obj |
	obj := self basicNew.
	obj arXivHTTP: http.
	obj build.
	ExtractorList add: obj.
	^ obj
]

{ #category : 'accessing' }
AIA2RelatedPaperExtractor >> arXivHTTP: http [
	"Sets the arXiv HTTP URL for the paper extractor"
	arXivHTTP := http.
]

{ #category : 'building' }
AIA2RelatedPaperExtractor >> build [
	"Builds the extracted information from the arXiv paper by fetching, processing, and summarising its content"
	arXivHTTP ifNil: [ self error: 'arXivHTTP should be set' ].
	self build10ArXivText.
	self build20ArXivExtracted.
]

{ #category : 'building' }
AIA2RelatedPaperExtractor >> build10ArXivText [
	"Builds text from arXiv PDF by downloading, converting to text, and storing it"

	| pdfLocation pdfContents |
	pdfLocation := arXivHTTP copyReplaceAll: 'abs' with: 'pdf'.
	pdfContents := [ ZnClient new get: pdfLocation ] on: Error do: [ nil ].
	arXivText := ''.
	(pdfContents notNil and: [ pdfContents isKindOf: ByteArray ]) ifTrue: [
			| directory pdfFile textFile command |
			directory := FileSystem workingDirectory.
			pdfFile := directory / 'reportFile.pdf'.
			textFile := directory / 'reportFile.txt'.
			pdfFile exists ifTrue: [ pdfFile delete ].
			textFile exists ifTrue: [ textFile delete ].
			pdfFile binaryWriteStreamDo: [ :stream | stream nextPutAll: pdfContents ].
			command := 'pdftotext {1} {2}' format: {
					           pdfFile fullName.
					           textFile fullName }.
			LibC system: command.
			arXivText := textFile readStream contents
		].
	^ arXivText
]

{ #category : 'building' }
AIA2RelatedPaperExtractor >> build20ArXivExtracted [
	"Builds the extracted information from the arXiv text using an LLM model"

	| hist |
	hist := AIAHistory new.
	hist
		api: self class llmModel;
		background: arXivText;
		user: self buildArXivExtractedPrompt;
		getResponse.
	arXivExtracted := hist response
]

{ #category : 'building' }
AIA2RelatedPaperExtractor >> buildArXivExtractedPrompt [
	"Constructs the prompt for extracting paper details from arXiv text using an LLM model"
	^ '
from the paper given as background, your response must follow this form:
TITLE: name of the title of the paper
AUTHORS: One line per author like this "author name; author affiliation (or SOMEWHERE if you do not know)"
BIBTEX: A full bibtex of the paper on the form 
```bibtex
bibtex info of the paper, whith as much info you can find. D
```
PAPER: Extract the following about the paper (max 1000 words total):
1. CORE_CONTRIBUTION: What is the novel contribution in one sentence?
2. METHOD_TYPE: Classify as experimental, theoretical, systems, or survey
3. KEY_CLAIMS: What are the 3-5 main claims? (bullet list)
4. EVALUATION: What do they measure and how?
5. ASSUMPTIONS: What are the key assumptions or constraints?
6. LIMITATIONS: What limitations do they acknowledge or are evident?

Be factual and descriptive, not evaluative. Use the paper''''s own terminology.

RESPONSETYPE: factual, neutral, non-comparative. No superlatives.
'
	
    
]
