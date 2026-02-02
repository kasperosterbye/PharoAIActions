Class {
	#name : 'AIACommentExperiments',
	#superclass : 'Object',
	#instVars : [
		'commentSamples',
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
AIACommentExperiments >> llmCommentBuilders [
	^ { {MistralApi. 1}. {GrokApi . 2}. {GeminiApi . 2} }
]

{ #category : 'accessing' }
AIACommentExperiments >> llmCommentEvaluators [
	^ { OpenAIApi newOnModel: 1. ClaudeApi newOnModel: 1 }
]
