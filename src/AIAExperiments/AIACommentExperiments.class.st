Class {
	#name : 'AIACommentExperiments',
	#superclass : 'Object',
	#instVars : [
		'commentSamples',
		'commentGenerationStableness',
		'appendixTexts'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIAExperiments-PaperWriting',
	#package : 'AIAExperiments',
	#tag : 'PaperWriting'
}

{ #category : 'examples' }
AIACommentExperiments class >> clearDefault [
	<example>
	default := nil
]

{ #category : 'examples' }
AIACommentExperiments class >> default [
	default ifNil: [ default := super new ].
	^ default
]

{ #category : 'examples' }
AIACommentExperiments class >> new [
	"Use default instead of creating a new instance"
	self error: 'use default instead'
]

{ #category : 'as yet unclassified' }
AIACommentExperiments >> buildCommentGenerationStableness [
	"commentGenerationStableness ifNotNil: [ ^ self ]."
	commentGenerationStableness := OrderedCollection new.
	self llmCommentBuilders do: [ :builder |
		self classCommentTypes do: [ :commentTypes | 
			| trials compared|
			trials := (commentSamples select: [:sample |
					sample first  = builder and: [sample second = commentTypes]])
					collect: [:elem | elem fourth].
			"trials := (String lf, '------------', String lf) join: trials."
			compared := self compareComments: trials.
			commentGenerationStableness add: { builder. commentTypes. compared }
			]
		 ].
	^ commentGenerationStableness 
]

{ #category : 'as yet unclassified' }
AIACommentExperiments >> buildSamples [
	commentSamples ifNotNil: [ ^ self ].
	commentSamples := OrderedCollection new.
	self llmCommentBuilders do: [ :builder |
		builder first defaultModel: builder second. 
		AilienApi provider: builder first.
		self classCommentTypes do: [ :commentTypes | 
			AIACommentBuilding commentType: commentTypes.
			1 to: 3 do: [ :trialIndex |
				| comment |
				comment := AIASWMreport aiaComment.
				commentSamples add: { builder. commentTypes. trialIndex. comment }.
				 ]
			]
		 ].
	^ commentSamples 
]

{ #category : 'accessing' }
AIACommentExperiments >> classCommentTypes [
	"'Default' 'LLM' 'Beginner' 'Basic' 'Expert' 'TestGuide'"
	^ { 3. 2. 4. 6 }
]

{ #category : 'accessing' }
AIACommentExperiments >> commentSamples [
	^ commentSamples
]

{ #category : 'as yet unclassified' }
AIACommentExperiments >> compareComments: trails [
	| prompt hist response|
	prompt := 'Compare these three comments for AIASWMreport.

Classify semantic similarity as:
- IDENTICAL: Same facts, same claims, only trivial wording differs
- MINOR: 1-2 facts mentioned in some but not all versions
- MAJOR: Different factual claims or significant information asymmetry

Ignore: formatting, examples, provider lists, narrative style.
Focus on: what information each comment conveys.

Return only one word: IDENTICAL, MINOR, or MAJOR.'.
	hist := AIAHistory new.
	hist
		api: (OpenAIApi newOnModel: 1);
		background: (AIASourceCodeBuilder new forClass: AIASWMreport);
		user: 'Comment 1: ', String lf, trails first, String lf;
		user: 'Comment 2: ', String lf, trails second, String lf;
		user: 'Comment 3: ', String lf, trails third, String lf;
		user: prompt;
		getResponse.
	response := hist response.
	^ response
]

{ #category : 'accessing' }
AIACommentExperiments >> llmCommentBuilders [
	^ { {MistralApi. 1}. {GrokApi . 2}. {GeminiApi . 2} }
]

{ #category : 'accessing' }
AIACommentExperiments >> llmCommentEvaluators [
	^ { OpenAIApi newOnModel: 1. ClaudeApi newOnModel: 1 }
]

{ #category : 'as yet unclassified' }
AIACommentExperiments >> old_compareComments: trails [
	| prompt hist response|
	prompt := 'Compare the three previus comments for the class AIASWMreport. Just return an single word, one of : `Identical` if there is nearly no difference, `Minor variants` if there are a few differences, and `Major variants` if there are some significan differences. Structure of the comments does not matter, so ignore that. Ignore differences in examples, code blocks, and lists of providers/models. Ignore differences in wording, tone, and level of detail, as long as the same core claims are present. And return a single or two words describing your choinde.'.
	hist := AIAHistory new.
	hist
		api: (OpenAIApi newOnModel: 1);
		background: (AIASourceCodeBuilder new forClass: AIASWMreport);
		user: 'Comment 1: ', String lf, trails first, String lf;
		user: 'Comment 2: ', String lf, trails second, String lf;
		user: 'Comment 3: ', String lf, trails third, String lf;
		user: prompt;
		getResponse.
	response := hist response.
	^ response
]
