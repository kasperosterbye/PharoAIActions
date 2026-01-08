Class {
	#name : 'AIASWMValidator',
	#superclass : 'Object',
	#instVars : [
		'models',
		'report',
		'responses'
	],
	#classVars : [
		'Foo'
	],
	#category : 'AIAExperiments-ExperimentsResearch',
	#package : 'AIAExperiments',
	#tag : 'ExperimentsResearch'
}

{ #category : 'initialization' }
AIASWMValidator >> initialize [ 
	super initialize.
	models := { OpenAIApi newOnModel: 1. ClaudeApi newOnModel: 1. GrokApi newOnModel: 2 }.
	responses := WriteStream on: ''.
	
]

{ #category : 'accessing' }
AIASWMValidator >> report: fileName [
	report := (FileSystem disk root / 'Users' / 'kasper' 
		/ 'D' / 'AIExperiments' / 'SWM' / fileName) readStream contents trimBoth.
]

{ #category : 'as yet unclassified' }
AIASWMValidator >> validateL2L3 [

	| hist |
	responses := WriteStream on: ''.
	models do: [ :model |
			responses << '## ' << model asString << String lf << String lf.
			hist := AIAHistory new.
			hist
				api: model;
				background: report;
				user: self validateL2L3prompt;
				getResponse;
				response.
			responses << hist response << String lf << String lf ].
	^ responses contents 
]

{ #category : 'as yet unclassified' }
AIASWMValidator >> validateL2L3prompt [
	^ 'The the background paper, is there an strenths aspect in several aspect in Level 2, which is not told in Level 3. For each reference to Level 2, you must include the name of the model.
		Please answer ONLY in the following table format.
No paragraphs, no explanations outside the table.

| Aspect (strength) | Mentioned by Level 2 models | Present in Level 3? | One-line reason |
|-------------------|-----------------------------|----------------------|------------------|
| …                 | …                           | Yes/No/Partial       | …                |'
		
]
