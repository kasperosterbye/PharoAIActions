"
# Class Comment for AIA2MultiLLMWriter

The `AIA2MultiLLMWriter` class is responsible for generating comprehensive Markdown reports from multiple Large Language Model (LLM) responses. It organises and formats experimental results, including:

- **Title and metadata** (date, experiment context)
- **Response summaries** (simplified as `+`, `-`, or `E` for correct, incorrect, or error responses)
- **Detailed response tables** (comparing model outputs across providers)
- **Statistical aggregates** (percentages of correct/wrong/error responses)
- **Raw response sections** (full model outputs for reference)

The writer processes responses stored in `writeStorage`, which contains structured data from LLM experiments. It generates both simplified and detailed reports, with special handling for error cases.

## Usage Example

```st
""Example usage in Playground""
| writer storage |
storage := OrderedCollection new.
storage add: (Dictionary new
    at: #turnPattern put: #pattern1;
    at: #provider put: (OpenAIApi newOnModel: 1);
    at: #llmNo put: 1;
    at: #responseText put: 'The answer is 5';
    at: #summary put: '+';
    yourself).
storage add: (Dictionary new
    at: #turnPattern put: #pattern1;
    at: #provider put: (OpenAIApi newOnModel: 2);
    at: #llmNo put: 2;
    at: #responseText put: 'Error bla bla happened';
    at: #summary put: 'E';
    yourself).

writer := AIA2MultiLLMWriter new.
writer writeStorage: storage.
writer markdownResponse inspect  ""View the generated Markdown""
```

The example demonstrates creating a writer, populating it with sample responses, and generating a Markdown report. The `inspect` command displays the formatted output in the Playground.
"
Class {
	#name : 'AIA2MultiLLMWriter',
	#superclass : 'Object',
	#instVars : [
		'title',
		'writeStorage',
		'markDown',
		'overview',
		'appendix'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIActions-AIAPaperBuilding',
	#package : 'AIActions',
	#tag : 'AIAPaperBuilding'
}

{ #category : 'accessing' }
AIA2MultiLLMWriter class >> clearDefault [
	<example>
    default := nil
]

{ #category : 'accessing' }
AIA2MultiLLMWriter class >> default [
	default ifNil: [ default := self new ].
	^ default
]

{ #category : 'accessing' }
AIA2MultiLLMWriter class >> default: anObject [

	default := anObject
]

{ #category : 'accessing' }
AIA2MultiLLMWriter >> appendix [
	appendix ifNil: [ self markdownResponse ].
	^ appendix
]

{ #category : 'initialization' }
AIA2MultiLLMWriter >> buildWriteStorages [
	"Builds the write storage by organising LLM responses by turn pattern, provider, and model number, creating simplified summaries for each combination"
	| storage turnPatternType providerTypes llmNoTypes responseList responseListCombined|
	writeStorage ifNotNil: [ ^ self ].
	storage := AIA2MultiLLMStorage storage storeRows.
	writeStorage := OrderedCollection new.
	turnPatternType := storage collect: [ :elem | elem turnPattern ] as: Set.
	providerTypes := storage collect: [ :elem | elem provider ] as: Set.
	llmNoTypes := storage collect: [ :elem | elem llmNo ] as: Set.
	
	turnPatternType do: [ :turn |
		providerTypes do: [ :prov |
			llmNoTypes do: [ :llm |
				responseList := storage select: [ :line |
					(line turnPattern = turn) & (line provider = prov) & (line llmNo = llm)  ].
				responseListCombined := WriteStream on: ''.
				responseList do: [ :line | 
					responseListCombined << (self markdownSimplifiedResponse: line responseText)].
				writeStorage add: { #turnPattern -> turn. 
					#provider ->prov. #llmNo -> llm. #summary ->responseListCombined contents } asDictionary
			]
		]
	].
	^ writeStorage 
	
]

{ #category : 'initialization' }
AIA2MultiLLMWriter >> initialize [ 
	"Initialises the writer with an empty storage collection for LLM responses"
	super initialize.
	writeStorage := nil.
	markDown := nil. 
	overview := nil.
	appendix := nil
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown00Title [
	"Generates the title section of the Markdown report with the current date"
	markDown 
		<< '## Appendix - Details of the four LLM turns' << String lf
		<< '### On '<< Date today asString << String lf << String lf.
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown10Explanation [
	"Generates the explanation section of the Markdown report, detailing the experiment conditions and response criteria."

	markDown << '$$$$$comment$$$$$' << String lf << String lf.
	
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown20LLMNames [ |  llms  prompts  |
	markDown << '#### List of Providers llm models' << String lf << String lf << String lf.
	llms := AIA2MultiLLMStorage linesToBuild at: #llmNos.
	markDown << '| **provider** |'.
	llms do: [ :modelId | markDown << ' **Model ' << modelId asString << '** |' ].
	markDown << String lf.
	markDown << '| ------------ | '.
	llms do: [ :modelId | markDown << '----------- | ' ].
	markDown << String lf.
	prompts := AIA2MultiLLMStorage linesToBuild at: #providers.
	prompts do: [ :prompt |
			| collumnsAt |
			markDown << '| ' << prompt name asSymbol << ' | '.
			collumnsAt := writeStorage select: [ :elem | (elem at: #provider) = prompt ].
			llms do: [ :modelId | markDown << (prompt modelNames at: modelId) << ' | ' ].
			markDown << String lf ].
	markDown << String lf << String lf.
	^ markDown contents 
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown25PlusMinusError [
	"Adds a legend explaining the symbols used in the response tables"
	markDown << '#### Resonces show are:' << String lf
		<< '* `+` means that the model gave a correct answer' << String lf
		<< '* `-` means that the model gave a wrong answer' << String lf
		<< '* `E` means that the model gave a error response' << String lf
		<< String lf << String lf.
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown30LLMResponses [
	"This method generates a detailed Markdown section for LLM responses, including turn patterns, provider names, and model results. It organizes responses by turn pattern and creates a comprehensive table format for easy comparison."
	| turnPatterns |
	
	turnPatterns := AIA2MultiLLMStorage linesToBuild at: #turnPatterns.
	turnPatterns do: [ :turnPattern | 
		markDown << '#### Responses for ' << turnPattern << String lf 
					<< '<!--- Per-provider, per-model results.--->' << String lf << String lf.
		self markdown35Response: turnPattern.
		self markdown37LLMResponses: turnPattern.
		self markdown38LLMResponsesSummary: turnPattern ].
	^ markDown contents
	
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown35Response: turnPattern [
	"Generates detailed Markdown section for LLM responses, including turn patterns, provider names, and model results"
	| source |
	source := AIA2MultiLLMBuilder new turnsBlockSource at: turnPattern.
	markDown << '#### History tested on this method' << String lf
		<< 'This Pharo method constructs a fixed user/assistant history' << String lf
		<< '```text' << String lf 
		<< (AIA2MultiLLMBuilder >> source) sourceCode  << String lf 
		<< '```' << String lf << String lf.
	
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown37LLMResponses: turnPattern [
	"Generates a Markdown table comparing simplified responses fror multiple LLM models"

	| elements llms prompts collumnsAt |
	llms := (writeStorage collect: [ :elem | elem at: #llmNo ] as: Set) asArray sorted.
	markDown << '| **provider** |'.
	llms do: [ :modelId | markDown << ' **Model ' << modelId asString << '** |' ].
	markDown << String lf.
	markDown << '| ------------ | '.
	llms do: [ :modelId | markDown << '----------- | ' ].
	markDown << String lf.
	elements := writeStorage select: [ :elem | (elem at: #turnPattern) = turnPattern ].
	prompts := AIA2MultiLLMStorage linesToBuild at: #providers.
	"prompts := elements collect: [ :elem | elem at: #provider ] as: Set."
	prompts do: [ :prompt |
			markDown << '| ' << prompt name asSymbol << ' | '.
			collumnsAt := elements select: [ :elem | (elem at: #provider) = prompt ].
			collumnsAt := collumnsAt sort: [ :a :b | (a at: #llmNo) < (b at: #llmNo) ].
			collumnsAt do: [ :modelId | markDown << (modelId at: #summary) << ' | ' ].
			markDown << String lf ].
	markDown << String lf .
	^ markDown contents
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown38LLMResponsesSummary: turnPattern [
	"Generates a summary of LLM responses for a given turn pattern, showing counts and percentages of correct, wrong, and error responses"


	| elements correct wrong error answerWords sum|
	correct := wrong := error := 0.
	elements := writeStorage select: [ :elem | (elem at: #turnPattern) = turnPattern ].
	elements do: [ :element |
		(element at: #summary) asArray do: [ :result |
			result = $+ ifTrue: [ correct := correct + 1 ].
			result = $- ifTrue: [ wrong := wrong + 1 ].
			result = $E ifTrue: [ error := error + 1 ] ]
		 ].
	answerWords := {  {'Correct'. '+'}. {'Wrong' .'-'}. {'Errors' . 'E'} }.
	sum := correct + wrong + error .
	"Include this as
* Correct answers +:  18 ud af 28 (64%)
* Wrong answers -:  8 ud af 28 (29%)
* Error: 2 ud ad 28 (7%)
"
	markDown << String lf << 'Aggregate results across all tested providers and models.' << String lf.
	markDown << ('* Correct answers `+`: {1} of {2}  ({3}%) <br>' 
		format: {correct  asString. sum asString. (correct/sum * 100) rounded asString  }) << String lf.
	markDown << ('* Wrong answers `-`: {1} of {2}  ({3}%) <br>' 
		format: {wrong  asString. sum asString. (wrong/sum * 100) rounded asString  }) << String lf.
	markDown << ('* Error answers `E`: {1} of {2}  ({3}%) <br>' 
		format: {error  asString. sum asString. (error/sum * 100) rounded asString  }) << String lf.
	markDown << String lf.
	^ markDown contents
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown40LLMFullResponses [
	"This method generates a detailed Markdown report of raw LLM responses, organised by turn pattern and provider, including model-specific results."
    | sortedPatterns sortedProviders |
    markDown 
        << '## Raw LLM Responses' << String lf
        << '### Date: ' << Date today asString << String lf << String lf.

    sortedPatterns := AIA2MultiLLMStorage linesToBuild at: #turnPatterns.
    sortedPatterns do: [ :pattern |
        markDown << '#### Turn Pattern: ' << pattern << String lf << String lf.
		  sortedProviders := AIA2MultiLLMStorage linesToBuild at: #providers.
        sortedProviders do: [ :provider |
            markDown << '##### ' << provider name asSymbol << String lf << String lf.
            (AIA2MultiLLMStorage linesToBuild at: #llmNos) do: [ :modelNo | 
                | lines modelName |
                lines := AIA2MultiLLMStorage storage storageArray select: [ :e |
                    e turnPattern = pattern and: [
                    e provider = provider and: [
                    e llmNo = modelNo ]]].
                modelName := (provider modelNames at: modelNo).
                markDown << '###### Model ' << modelNo asString 
								<< ' (' << modelName << ')' << String lf << String lf.
                lines withIndexDo: [ :line :idx |
                    markDown 
                        << '- Response ' << idx asString << ': ' 
                        << line responseText << String lf.
                ].
                markDown << String lf.
            ].
            markDown << String lf.
        ].
    ].
    ^ markDown contents
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown50CommentOverview [
	"Generates HTML comment overview for LLM report editing, using explicit report content only"

	markDown := markDown contents.
	overview ifNil: [ overview := self rebuildOverview ].
	markDown := markDown copyReplaceAll: '$$$$$comment$$$$$' with: overview.
	markDown := WriteStream with: markDown
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown51EnsureComment [
	"Ensures the report includes a hidden HTML comment for later LLM edits, using explicit report content only"
| prompt  hist |
	prompt := 'You will output a hidden HTML comment for later LLM edits of this report.
Use ONLY information explicitly present between REPORT_MARKDOWN_BEGIN/END.
Do NOT infer, calculate, or estimate any numbers not explicitly written.
Return EXACTLY 6 lines. Each line MUST:
- Start with the exact prefix below followed by a single space and colon
- Have content <= 110 characters (to leave margin under 120)
- Have no leading or trailing whitespace on the content
- Be followed directly by the next line (no blank lines)

Scope:
Experimental setup:
What each table cell represents:
Aggregates:
Known failure modes:
Editing priorities:

Rules:
- No markdown, no bullets, no numbering, no extra lines.
- If information is missing or unclear, write: Unknown
- Do not quote or repeat report text.
- **Stop after the 6th line. Do not add anything else.**

REPORT_MARKDOWN_BEGIN
', markDown contents, '
REPORT_MARKDOWN_END'.
	hist := AIAHistory new.
	hist 
		api: (OpenAIApi newOnModel: 1);
		background: 'LLM Temperature = 0.0 everywhere';
		user: prompt;
		getResponse.
	overview := '<!--- ', String lf, hist response , String lf, '--->' , String lf.
	^ overview 
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdownResponse [
	"Generates a comprehensive Markdown report of LLM responses, including title, explanation, model overview, and response tables."
	"AilienApi errorResponse: 'Error bla bla happended'."
	AilienApi errorResponse: nil.
	self buildWriteStorages.
	markDown := WriteStream on: ''.
	self
		markdown00Title; 
		markdown10Explanation;
		markdown20LLMNames;
		markdown25PlusMinusError;
		markdown30LLMResponses;
		markdown40LLMFullResponses ;
		markdown50CommentOverview.
	appendix := markDown contents copyReplaceAll: String cr with: String lf.
	^ appendix 
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdownSimplifiedResponse: originalResponse [
	"Simplifies LLM response text by joining lines and categorising as 'E' for errors, '+' for correct answers, or '-' for incorrect answers"
	| simplifiedResponse |
	simplifiedResponse := ' ' join: originalResponse lines. " maxFirst: 15"
	simplifiedResponse := (simplifiedResponse includesSubstring: 'Error bla bla')
		ifTrue: [ 'E' ]
		ifFalse: [
			(simplifiedResponse includesSubstring: '5')
				ifTrue: [ '+' ]
				ifFalse: [ '-' ] ].
	^ simplifiedResponse
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> rebuildOverview [
	"Rebuilds the HTML comment overview for the LLM report using explicit report content only"
	| prompt  hist |
	prompt := 'You will output a hidden HTML comment for later LLM edits of this report.
Use ONLY information explicitly present between REPORT_MARKDOWN_BEGIN/END.
Do NOT infer or compute any numbers not explicitly stated.

Return EXACTLY 6 lines. Each line MUST start with the exact prefix shown:
Scope:
Experimental setup:
What each table cell represents:
Aggregates:
Known failure modes:
Editing priorities:

Rules:
- No markdown, no bullets, no extra lines.
- Each line <= 120 characters.
- If unsupported by explicit text, write: Unknown
- Do not quote the report text.

REPORT_MARKDOWN_BEGIN<br> 
', markDown contents,  '
<br>REPORT_MARKDOWN_END'.
	hist := AIAHistory new.
	hist 
		api: (OpenAIApi newOnModel: 1);
		background: 'LLM Temperature = 0.0 everywhere';
		user: prompt;
		getResponse.
	overview := '<!--- ', String lf, hist response , String lf, '--->' , String lf.
	^ overview 
]
