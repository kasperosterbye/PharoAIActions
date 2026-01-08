Class {
	#name : 'AIAChatBookReader',
	#superclass : 'Object',
	#instVars : [
		'history'
	],
	#category : 'AIAExperiments-ExperimentsTools',
	#package : 'AIAExperiments',
	#tag : 'ExperimentsTools'
}

{ #category : 'initialization' }
AIAChatBookReader >> initialize [

	history := AIAHistory new.

	AilienApi provider: MistralApi
]

{ #category : 'initialization' }
AIAChatBookReader >> paperComment: all [

	| llmModels resp hist |
	llmModels := OrderedCollection new.
	resp := OrderedCollection new.
	1 to: 2 do: [ :id | llmModels add: (MistralApi defaultModel: id) new].
	1 to: 1 do: [ :id | llmModels add: (GrokApi defaultModel: id) new].
	llmModels do: [ :model |
		hist := AIAHistory new.
		hist api: model. 
		resp add: ( self paperComment: all by: hist )].
	^ resp
]

{ #category : 'as yet unclassified' }
AIAChatBookReader >> paperComment: all by: hist [ 
	hist background: '# Paper for discussion', String cr, String cr, (AIABibLaTex new paper: 20) .
	hist user: 'These there the comments procuded of the paper. ' , String cr, String cr. all.
	hist user: 'Based on those summaries, can you write a comment that is the essence of them all. It should not be lo'.
	hist responseType: 'The response type should be academic british style. '.
	hist getResponse.
	^ hist response
]

{ #category : 'initialization' }
AIAChatBookReader >> paperFirst: hist [
	hist background: '# Paper for discussion', String cr, String cr, (AIABibLaTex new paper: 20) .
	hist user: 'Can you give a summary of the paper in background. Summary of concrete experiments in the paper is the key.'.
	hist responseType: 'The response type should be academic british style. '.
	hist getResponse.
	^ hist response
]

{ #category : 'initialization' }
AIAChatBookReader >> paperRead [

	| all  comments |
	all := self paperReadCombine.
	comments := self paperComment: all.
	^ all
	
]

{ #category : 'initialization' }
AIAChatBookReader >> paperReadAll [

	| llmModels resp hist |
	llmModels := OrderedCollection new.
	resp := OrderedCollection new.
	1 to: 2 do: [ :id | llmModels add: (MistralApi defaultModel: id) new].
	1 to: 1 do: [ :id | llmModels add: (GrokApi defaultModel: id) new].
	resp := llmModels collect: [ :model |
		hist := AIAHistory new.
		hist api: model. 
		self paperFirst: hist ].
	^ resp
]

{ #category : 'initialization' }
AIAChatBookReader >> paperReadCombine [

	| all  |
	all := self paperReadAll.
	^ '-------------------', String cr, String cr join: all.
]
