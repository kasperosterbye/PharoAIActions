Class {
	#name : 'AIAToolsExperiment',
	#superclass : 'Object',
	#instVars : [
		'responses'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIAExperiments-ExperimentsResearch',
	#package : 'AIAExperiments',
	#tag : 'ExperimentsResearch'
}

{ #category : 'examples' }
AIAToolsExperiment class >> background [
	<example>
	^ '
The result of this class was in essense that Grok LLMs are significantly better at actually using tools.
To such a degree I do not want to continue the experiment to test it.	
'
]

{ #category : 'examples' }
AIAToolsExperiment class >> default [ 
	default ifNil: [ default := self new].
	^ default 
]

{ #category : 'examples' }
AIAToolsExperiment class >> resetDefault [ 
	<example>
	default := nil.
]

{ #category : 'initialization' }
AIAToolsExperiment >> initialize [ 
	super initialize.
	responses := OrderedCollection new.
	
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> modelsCollection [
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> old_promptTools [
	Transcript reset.
	responses := OrderedCollection new.
	self prompts do: [ :prompt | 
		self responseTools do: [ :tool | 
			self prompt: prompt responseTool: tool ] ].
	^ responses 
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> prompt01 [
	^ 'What superclasses does class RSEquidistantCircleLayout have. I want a recursive answer. Just return the names of the super classes in plain text, and no comments'
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> prompt02 [
	^ 'What superclasses does class Text have. I want a recursive answer. Just return the names of the super classes in plain text, and no comments'
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> prompt03 [
	^ 'What superclasses does AIAClyPackageCommentShow have. I want a recursive answer. Just return the names of the super classes in plain text, and no comments'
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> prompt: prompt responseTool: tool [

	| hist |
	self providers do: [ :provider |
			1 to: 1 "4" do: [ :providerId |
					| api results |
					api := provider newOnModel: providerId.
					results := OrderedCollection new.
					1 to: 1 "5" do: [ :experiment |
							| toolsLast tools |
							toolsLast := Transcript contents lines size + 1.
							hist := AIAHistory new.
							hist
								api: api;
								background: tool;
								user: prompt.
							hist getResponse. "hist response. "
							tools := String lf 
								join: (Transcript contents lines copyFrom: toolsLast to: Transcript contents lines size).
							results add: {hist response. tools }.
						].
							responses add: {
									api printString.
									prompt.
									tool.
									results asArray} ] ]
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> promptTools [
	Transcript reset.
	responses := OrderedCollection new.
	self prompts do: [ :prompt | 
		self responseTools do: [ :tool | 
			self prompt: prompt responseTool: tool ] ].
	^ responses 
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> prompts [
	^ { "self prompt01. self prompt02." self prompt03 }
]

{ #category : 'accessing' }
AIAToolsExperiment >> providers [

	^ { MistralApiWithTools. GrokApiWithTools. OpenAIApiWithTools.  }
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> responseTool01 [
	^ ''
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> responseTool02 [
	^ 'If possible, use a TOOL to make a true response'
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> responseTool03 [
	^ 'Do NOT use your memory, use tool to get information. Notice, evaluatePharoExpression allows execution of any Pharo expression'
]

{ #category : 'as yet unclassified' }
AIAToolsExperiment >> responseTools [
	^ { "self responseTool01. self responseTool02." self responseTool03 }
]
