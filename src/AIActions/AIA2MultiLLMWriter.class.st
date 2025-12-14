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

{ #category : 'as yet unclassified' }
AIA2MultiLLMWriter >> buildWriteStorages [
	| storage turnPatternType providerTypes llmNoTypes responseList responseListCombined|
	self writeStorage ifNotEmpty: [ ^ self ].
	storage := AIA2MultiLLMStorage storage storeRows.
	self writeStorage: OrderedCollection new.
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
				self writeStorage add: { #turnPattern -> turn. 
					#provider ->prov. #llmNo -> llm. #summary ->responseListCombined contents } asDictionary
			]
		]
	].
	^ self writeStorage 
	
]

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

{ #category : 'markdown' }
AIA2MultiLLMWriter >> markdown25response [
	"Generates a Markdown table listing the tested models by provider"
	markDown << '#### History tested on this method' << String lf
		<< 'This Pharo method constructs a fixed user/assistant history and returns the response from the given LLM.' << String lf
		<< '```text' << String lf 
		<< (self class >> #responseOf:) sourceCode << String lf 
		<< '```' << String lf << String lf.
	
]

{ #category : 'Protocol (markdown) - 4 selector(s)' }
AIA2MultiLLMWriter >> markdown30LLMResponses [
	| turnPatterns |
	turnPatterns := (writeStorage collect: [ :elem | elem at: #turnPattern ] as: Set) asArray sorted.
	turnPatterns do: [ :turnPattern | self markdown30LLMResponses: turnPattern ].
	^ markDown contents
	
]

{ #category : 'Protocol (markdown) - 4 selector(s)' }
AIA2MultiLLMWriter >> markdown30LLMResponses: turnPattern [
	"Generates a Markdown table comparing simplified responses fror multiple LLM models"

	| elements llms prompts collumnsAt |
	markDown := WriteStream on: ''.
	markDown << '#### Responses for ' << turnPattern << String lf << '<!--- Per-provider, per-model results.--->' << String lf << String lf.
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
	markDown << String lf << String lf.
	^ markDown contents
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
		markdown25response;
		markdown30LLMResponses;
		markdown40LLMFullResponses .

	^ markDown contents
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

{ #category : 'accessing' }
AIA2MultiLLMWriter >> writeStorage [

	^ writeStorage
]

{ #category : 'accessing' }
AIA2MultiLLMWriter >> writeStorage: anObject [

	writeStorage := anObject
]
