"
# Class Comment for AIA2RelatedWorkSynthesizer

The `AIA2RelatedWorkSynthesizer` is responsible for generating cohesive related work sections by synthesising information from multiple external papers. It utilises large language models to create integrated narratives that highlight thematic connections and comparative insights between our research and existing literature.

## Key Responsibilities:
- **Single Paper Integration**: Generates concise, context-aware summaries that incorporate new papers into existing related work sections
- **Multi-Paper Synthesis**: Produces cohesive paragraphs that synthesise information from groups of related papers
- **Thematic Grouping**: Organises papers by shared topics to create more meaningful comparative analyses
- **Word Count Management**: Ensures output adheres to specified word limits while maintaining readability

## Usage Example:
```st
""AIA2RelatedWorkSynthesizer default
    buildSynthesizerForGroup: #(1 2 3);
    inspect""
```

The example demonstrates how to synthesise information from papers indexed 1, 2, and 3, with the result being ready for inspection in the Playground.
"
Class {
	#name : 'AIA2RelatedWorkSynthesizer',
	#superclass : 'Object',
	#instVars : [
		'relatorGroups',
		'synthesizedRelatedPaper'
	],
	#classVars : [
		'RelationList'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIAExperiments-PaperWriting',
	#package : 'AIAExperiments',
	#tag : 'PaperWriting'
}

{ #category : 'accessing' }
AIA2RelatedWorkSynthesizer class >> default [
	<example>
	default ifNil: [ default := self basicNew. default initialize ].
	^ default 
]

{ #category : 'instance creation' }
AIA2RelatedWorkSynthesizer class >> llmModel [
	"Returns a new instance of the Claude API configured for model version 1"
	^ OpenAIApi newOnModel: 1
]

{ #category : 'accessing' }
AIA2RelatedWorkSynthesizer class >> new [
	self error: 'Use default'
]

{ #category : 'accessing' }
AIA2RelatedWorkSynthesizer class >> resetDefault [
	<example>
	default := nil
]

{ #category : 'building' }
AIA2RelatedWorkSynthesizer >> build [
	| relations index |
	relations := AIA2RelatedPaperRelator rawRelationList.
	synthesizedRelatedPaper := WriteStream on: ''.
	index := 1.
	index to: 3 do: [ :id |
		self halt.
		 ].
	synthesizedRelatedPaper := synthesizedRelatedPaper contents.
	^ synthesizedRelatedPaper
]

{ #category : 'as yet unclassified' }
AIA2RelatedWorkSynthesizer >> buildSynthesizer: id [
	"Builds the raw relation between our paper and an external paper using an LLM model"
	| hist |
	hist := AIAHistory new.
	hist
		api: self class llmModel;
		user: 'This is `previous papers` ', String lf, self previousPapers;
		user: 'This is `externalPaper` (', id asString, ')', String lf, (self relator: id);
		user: (self buildSynthesizerPrompt) ;
		getResponse.
	synthesizedRelatedPaper << hist response << String lf << String lf
]

{ #category : 'as yet unclassified' }
AIA2RelatedWorkSynthesizer >> buildSynthesizerForGroup: paperIndices [
    "Generates prompt for synthesizing multiple papers into one paragraph"
    |  targetWords |
self halt.
    targetWords := paperIndices size * 60.  "~60 words per paper"
    
    ^ 'Write ONE cohesive paragraph covering externalPapers {1}.
    
    TARGET: {2} words total (±15 words). This covers ALL papers together.
    
    STRUCTURE:
    - Opening (1 sentence): Frame the shared theme across these papers
    - Body (1-2 sentences per paper): Each paper''s unique angle/contribution
    - Closing (1 sentence): What they collectively establish relative to our work
    
    CRITICAL REQUIREMENTS:
    - Write as SYNTHESIS, not a sequence of separate summaries
    - Papers should share sentences and transitions
    - No repetitive formulae like "This work relates to our investigation by..."
    - Assume reader already knows our basic findings (AAA/UAUAU patterns)
    - Each paper title + index must appear at least once: "ExternalPaper (x)" or "Paper (x)"
    
    INTEGRATION PATTERNS:
    - Contrast within single sentence: "While (1) weaponizes X, (2) mitigates it through Y"
    - Sequential building: "ExternalPaper (1) demonstrates X; (2) extends this to Y; (3) operationalizes both in Z"
    - Thematic grouping: "Papers (1-3) collectively show that [theme]..."
    
    FORBIDDEN:
    - Do NOT write "(1) does A. (2) does B. (3) does C." as separate sentences
    - Do NOT repeat our methodology/results unless comparing directly
    - Do NOT explain shared concepts multiple times
    
    Example opening: "The structural vulnerabilities we characterize—particularly role-boundary sensitivities and turn-taking contracts—manifest across three complementary perspectives..."
    
    Your paragraph must be EXACTLY {2} words (±15).' 
        format: { paperIndices asString. targetWords }
]

{ #category : 'as yet unclassified' }
AIA2RelatedWorkSynthesizer >> buildSynthesizerPrompt [
    ^ 'You are required to extend an existing text about Related Work with one new paper.

EXISTING TEXT: `previous papers`

NEW PAPER: `externalPaper`

TASK:
1. Write one sentence that integrates the new paper into the narrative.
2. Use the format: "While [externalPaper] focused on X, [externalPaper] contributes Y."
3. Make sure that the combined text still flows as one paragraph.
4. Response must at absloute max size be 75-100 words, and response must not have a header'
]

{ #category : 'as yet unclassified' }
AIA2RelatedWorkSynthesizer >> buildSynthesizerPromptFor: paperIndices [
    ^ 'Write ONE cohesive paragraph covering externalPapers {1}.
    
    TARGET: {2} words total (±15 words). This covers ALL papers together.
    
    STRUCTURE:
    - Opening (1 sentence): Frame the shared theme across these papers
    - Body (1-2 sentences per paper): Each paper''s unique angle/contribution
    - Closing (1 sentence): What they collectively establish relative to our work
    
    CRITICAL REQUIREMENTS:
    - Write as SYNTHESIS, not a sequence of separate summaries
    - Papers should share sentences and transitions
    - No repetitive formulae like "This work relates to our investigation by..."
    - Assume reader already knows our basic findings (AAA/UAUAU patterns)
    - Each paper title + index must appear at least once: "ExternalPaper (x)" or "Paper (x)"
    
    INTEGRATION PATTERNS:
    - Contrast within single sentence: "While (1) weaponizes X, (2) mitigates it through Y"
    - Sequential building: "ExternalPaper (1) demonstrates X; (2) extends this to Y; (3) operationalizes both in Z"
    - Thematic grouping: "Papers (1-3) collectively show that [theme]..."
    
    FORBIDDEN:
    - Do NOT write "(1) does A. (2) does B. (3) does C." as separate sentences
    - Do NOT repeat our methodology/results unless comparing directly
    - Do NOT explain shared concepts multiple times
    
    Example opening: "The structural vulnerabilities we characterize—particularly role-boundary sensitivities and turn-taking contracts—manifest across three complementary perspectives..."
    
    Your paragraph must be EXACTLY {2} words (±15).' 
        format: { paperIndices asString. 75 asString }
]

{ #category : 'as yet unclassified' }
AIA2RelatedWorkSynthesizer >> groupSynthesizer [
	synthesizedRelatedPaper := WriteStream on: ''.
	self groupingRelator do: [ :array |
		self groupSynthesizer: array 
		 ].
	synthesizedRelatedPaper := synthesizedRelatedPaper contents.
	^ synthesizedRelatedPaper
]

{ #category : 'as yet unclassified' }
AIA2RelatedWorkSynthesizer >> groupSynthesizer: idArray [
	"Builds the raw relation between our paper and an external paper using an LLM model"
	| externals hist |
	externals := AIA2RelatedPaperRelator rawRelationStringFor: idArray.
	hist := AIAHistory new.
	hist
		api: self class llmModel.
	synthesizedRelatedPaper contents size > 10 ifTrue: [
		hist user: 'Previous responces for other external papers. Avoid writing thise topics again. ',
				 synthesizedRelatedPaper contents].
	hist
		user: 'Single or group of `externalPapers` ', String lf, externals ;
		user: self groupSynthesizerPrompt ;
		getResponse.
	synthesizedRelatedPaper << hist response << String lf << String lf
]

{ #category : 'as yet unclassified' }
AIA2RelatedWorkSynthesizer >> groupSynthesizerPrompt [
    ^ 'You are required to write a text about Related Work for some `externalPapers`.

NEW PAPERS: `externalPapers`

TASK:
1. Write one sentence that the issue the `externalPapers` have in common.
2. Make sure you refer to paper title and number of each element in  `externalPapers`. "
3. Relate the externalPapers to our paper.
4. Make sure that the combined text still flows as one paragraph.
5. Response must at absloute max size be 75-100 words pr element in `externalPapers` , and response must not have a header'
]

{ #category : 'as yet unclassified' }
AIA2RelatedWorkSynthesizer >> groupingRelator [
	| hist response|
	relatorGroups ifNotNil: [ ^ relatorGroups ].
	hist := AIAHistory new.
	hist
		api: (ClaudeApi newOnModel: 1);
		background: AIA2RelatedPaperRelator rawRelationString;
		user: 'Please group the background papers based those that works on the same topics. Your response should be only #(x y z)';
		getResponse.
	response := hist response.
	relatorGroups := OrderedCollection new.
	response lines do: [ :line | 
		relatorGroups add: (CodeImporter evaluateString: line)
	].
	relatorGroups := relatorGroups asArray.
	^ relatorGroups
	
]

{ #category : 'building' }
AIA2RelatedWorkSynthesizer >> old_build [
	| relations index |
	relations := AIA2RelatedPaperRelator rawRelationList.
	synthesizedRelatedPaper := WriteStream on: ''.
	index := 1.
	index to: 3 do: [ :id |
		self buildSynthesizer: id
		 ].
	synthesizedRelatedPaper := synthesizedRelatedPaper contents.
	^ synthesizedRelatedPaper
]

{ #category : 'as yet unclassified' }
AIA2RelatedWorkSynthesizer >> previousPapers [
	^ synthesizedRelatedPaper contents
]

{ #category : 'as yet unclassified' }
AIA2RelatedWorkSynthesizer >> relator: id [
	^ (AIA2RelatedPaperRelator rawRelationList at: id) rawRelation
]
