Class {
	#name : 'AIA2MultiLLMWriter',
	#superclass : 'Object',
	#instVars : [
		'title',
		'writeStorage',
		'markDown',
		'overview'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'initialization' }
AIA2MultiLLMWriter >> initialize [ 
	super initialize.
	writeStorage := OrderedCollection new.
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown00Title [
	markDown 
		<< '## Appendix - Details of the four LLM turns' << String lf
		<< '### On '<< Date today asString << String lf << String lf.
]

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown10Explanation [
	"Generates the explanation section of the Markdown report, detailing the experiment conditions and response criteria."

	markDown << '$$$$$comment$$$$$' << String lf << String lf.
	
]

{ #category : 'Protocol (markdown) - 4 selector(s)' }
AIA2MultiLLMWriter >> markdown20LLMNames|  llms [ prompts  |
	markDown << '#### List of Providers llm models' << String lf << String lf << String lf.
	llms := (writeStorage collect: [ :elem | elem at: #llmNo ] as: Set) asArray sorted.
	markDown << '| **provider** |'.
	llms do: [ :modelId | markDown << ' **Model ' << modelId asString << '** |' ].
	markDown << String lf.
	markDown << '| ------------ | '.
	llms do: [ :modelId | markDown << '----------- | ' ].
	markDown << String lf.
	prompts := writeStorage collect: [ :elem | elem at: #provider ] as: Set.
	prompts do: [ :prompt |
			| collumnsAt |
			markDown << '| ' << prompt name asSymbol << ' | '.
			collumnsAt := writeStorage select: [ :elem | (elem at: #provider) = prompt ].
			llms do: [ :modelId | markDown << (prompt modelNames at: modelId) << ' | ' ].
			markDown << String lf ].
	markDown << String lf << String lf.
	^ markDown contents
]

{ #category : 'Protocol (Protocol (markdown) - 4 selector(s)) - 2 selector(s)' }
AIA2MultiLLMWriter >> markdown25PlusMinusError [

	markDown << '#### Resonces show are:' << String lf
		<< '* `+` means that the model gave a correct answer' << String lf
		<< '* `-` means that the model gave a wrong answer' << String lf
		<< '* `E` means that the model gave a error response' << String lf
		<< String lf << String lf.
]

{ #category : 'Protocol (Protocol (markdown) - 4 selector(s)) - 2 selector(s)' }
AIA2MultiLLMWriter >> markdown30LLMResponses [
	| turnPatterns |
	
	turnPatterns := (writeStorage collect: [ :elem | elem at: #turnPattern ] as: Set) asArray sorted.
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
	| source |
	source := AIA2MultiLLMBuilder new turnsBlockSource at: turnPattern.
	markDown << '#### History tested on this method' << String lf
		<< 'This Pharo method constructs a fixed user/assistant history' << String lf
		<< '```text' << String lf 
		<< (AIA2MultiLLMBuilder >> source) sourceCode  << String lf 
		<< '```' << String lf << String lf.
	
]

{ #category : 'Protocol (markdown) - 4 selector(s)' }
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
	prompts := elements collect: [ :elem | elem at: #provider ] as: Set.
	prompts do: [ :prompt |
			markDown << '| ' << prompt name asSymbol << ' | '.
			collumnsAt := elements select: [ :elem | (elem at: #provider) = prompt ].
			collumnsAt do: [ :modelId | markDown << (modelId at: #summary) << ' | ' ].

			markDown << String lf ].
	markDown << String lf .
	^ markDown contents
]

{ #category : 'Protocol (markdown) - 4 selector(s)' }
AIA2MultiLLMWriter >> markdown38LLMResponsesSummary: turnPattern [


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
    | sortedPatterns sortedProviders |
    markDown 
        << '## Raw LLM Responses' << String lf
        << '### Date: ' << Date today asString << String lf << String lf.

    sortedPatterns := AIA2MultiLLMStorage linesToBuild at: #turnPatterns.

    sortedPatterns do: [ :pattern |
        markDown << '#### Turn Pattern: ' << pattern << String lf << String lf.
        sortedProviders := (writeStorage collect: [:e | e at: #provider]) asSet asArray sorted: [:a :b | a name <= b name].
        sortedProviders do: [ :provider |
            markDown << '##### ' << provider name asSymbol << String lf << String lf.
            {1. 3} do: [ :modelNo |  "or collect unique llmNo"
                | lines modelName |
                lines := AIA2MultiLLMStorage storage storageArray select: [ :e |
                    e turnPattern = pattern and: [
                    e provider = provider and: [
                    e llmNo = modelNo ]]].
                modelName := (provider modelNames at: modelNo).
                markDown << '###### Model ' << modelNo asString << ' (' << modelName << ')' << String lf << String lf.
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

{ #category : 'as yet unclassified' }
AIA2MultiLLMWriter >> markdown50CommentOverview [

	markDown := markDown contents.
	overview ifNil: [ overview := self rebuildOverview ].
	markDown := markDown copyReplaceAll: '$$$$$comment$$$$$' with: overview.
	markDown := WriteStream with: markDown
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMWriter >> markdown51EnsureComment [
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
	markDown := WriteStream on: ''.
	self
		markdown00Title; 
		markdown10Explanation;
		markdown20LLMNames;
		markdown25PlusMinusError;
		markdown30LLMResponses;
		markdown40LLMFullResponses ;
		markdown50CommentOverview.
	
	^ markDown contents copyReplaceAll: String cr with: String lf
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMWriter >> markdownSimplifiedResponse: originalResponse [
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

{ #category : 'as yet unclassified' }
AIA2MultiLLMWriter >> rebuildOverview [
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

{ #category : 'accessing' }
AIA2MultiLLMWriter >> writeStorage [

	^ writeStorage
]

{ #category : 'accessing' }
AIA2MultiLLMWriter >> writeStorage: anObject [

	writeStorage := anObject
]
