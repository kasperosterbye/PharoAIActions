"
Fix this - it ended as nonsence...

I convert the result of some doing the experiement (system+prompt -> result) on multiple Ollama models.
"
Class {
	#name : 'MistralApiExperiments',
	#superclass : 'Object',
	#instVars : [
		'mistralModel',
		'lines',
		'models',
		'mistralProcess',
		'presenter'
	],
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'actions' }
MistralApiExperiments >> cancelMistralPrompt [
	"This method sends a user's input to an Ollama API and updates the chat history with the response."

	mistralProcess ifNotNil: [
		mistralProcess terminate.
	].
]

{ #category : 'experiments' }
MistralApiExperiments >> fiveForAlleModeller [
	"Can the models calculate the prompt"
	| prompt|
	self initializeMistralModel.
	prompt := '2+3. What is the result'.
	self runModelsWithPrompt: prompt saveToFile: 'Test01'.
]

{ #category : 'experiments' }
MistralApiExperiments >> fiveForAlleModeller_a [
	"Can the models calculate the prompt"
	| prompt|
	self initializeMistralModel.
	prompt := '2+3. What is the result'.
	self runModelsWithPrompt: prompt saveToFile: 'Test01a'.
]

{ #category : 'experiments' }
MistralApiExperiments >> fiveForAlleModeller_b [
	"Can the models calculate the prompt"
	| prompt|
	self initializeMistralModel.
	prompt := '2+3. What is the result. just the number'.
	self runModelsWithPrompt: prompt saveToFile: 'Test01b'.
]

{ #category : 'writing' }
MistralApiExperiments >> html: html title: title do: block [
	"Initial html"
	html
		tag: #html
		do: [ html
				tag: #head
				do: [ html tag: #meta attributes: #(charset 'UTF-8').
					html tag: #title with: title.
					html
						tag: #style
						with:
							'th, td {text-align:left } tr:nth-child(even){background-color: #f2f2f2}'].
				html
					tag: #body
					do: [ html tag: #h1 with: title.
						block value ] ]
]

{ #category : 'initialization' }
MistralApiExperiments >> initializeMistralModel [
	"I am called at the beginning of one of the experiments"
	models := MistralApi modelNames "atAll: #(1 2 )".
	mistralModel := MistralApi new.
]

{ #category : 'accessing' }
MistralApiExperiments >> mistralModel [

	^ mistralModel
]

{ #category : 'accessing' }
MistralApiExperiments >> mistralModel: anObject [

	mistralModel := anObject
]

{ #category : 'writing' }
MistralApiExperiments >> oneCounterFor: modelIndex experimentIndex: experimentIndex [
	^  [  |fibbe| 
			fibbe := 0.
			presenter model: modelIndex experimentIndex: experimentIndex seconds: fibbe.
			[	(Delay forSeconds: 1) wait.
				fibbe := fibbe + 1.
				presenter model: modelIndex experimentIndex: experimentIndex seconds: fibbe.
				World doOneCycle] repeat
		] fork.
]

{ #category : 'experiments' }
MistralApiExperiments >> pharoEvaQuestion [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeMistralModel.
	prompt := 'Give an example of how to store and later retrieve a value using a Dictionary in Pharo. No explanation.'.
	self runModelsWithPrompt: prompt saveToFile: 'Test04b'.
	
	
	
]

{ #category : 'experiments' }
MistralApiExperiments >> pharoManualTestForModeller_a [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeMistralModel.
	prompt := 'What is an Unary Message in Pharo'.
	self runModelsWithPrompt: prompt saveToFile: 'Test02a'.

]

{ #category : 'experiments' }
MistralApiExperiments >> pharoManualTestForModeller_b [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeMistralModel.
	mistralModel
			system: (AI_CommentBuilding ollamaSystem03 replaceAll: String cr with: '<br>').
	prompt := 'What is an Unary Message in Pharo'.
	self runModelsWithPrompt: prompt saveToFile: 'Test02b'.
	
	
]

{ #category : 'experiments' }
MistralApiExperiments >> pharoManualTestForModeller_c [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeMistralModel.
	mistralModel
			system: 'In Pharo there three kinds of methods (functions).
			In Pharo all methods are sendt to an object.
			In Pharo every instance is an object.
			A unary method has the form "obj methodName". 
			An example of a unary method is "5 factorial", 
				that return the factorial of 5, which is 120.
			A binary method has the form "obj1 operator obj2.
			An example of a binary method is "55 + 5.
				plus "+" is the binary method, that on object 55 gets 5 as argument, and return 60.
			The keyword method is on an object, and takes 1 to several arguments.
				A keyword method has the form "obj1 devide: obj2 precision: obj3.'.
	prompt := 'What is an Unary Message in Pharo'.
	self runModelsWithPrompt: prompt saveToFile: 'Test02c'.
	
	
]

{ #category : 'experiments' }
MistralApiExperiments >> pharoManualTestForModeller_d [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeMistralModel.
	prompt := 'In Pharo there three kinds of methods (functions).
			In Pharo all methods are sendt to an object.
			In Pharo every instance is an object.
			A unary method has the form "obj methodName". 
			An example of a unary method is "5 factorial", 
				that return the factorial of 5, which is 120.
			A binary method has the form "obj1 operator obj2.
			An example of a binary method is "55 + 5.
				plus "+" is the binary method, that on object 55 gets 5 as argument, and return 60.
			The keyword method is on an object, and takes 1 to several arguments.
				A keyword method has the form "obj1 devide: obj2 precision: obj3.
			What is an Unary Message in Pharo'.
	self runModelsWithPrompt: prompt saveToFile: 'Test02d'.
	
	
]

{ #category : 'experiments' }
MistralApiExperiments >> pharoNumberIsReleasedEachYear [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeMistralModel.
	prompt := 'There are many Pharo models, Pharo8, Pharo9, etc. What is the highest you have heard about. Give an Pharo number. No explanation.'.
	self runModelsWithPrompt: prompt saveToFile: 'Test04a'.
	
	
	
]

{ #category : 'experiments' }
MistralApiExperiments >> pharoOperationsTest [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeMistralModel.
	prompt := 'In Pharo Smalltalk, operators are evaluated left to right, without precedence. What is the result of 2 + 3 * 4? Just give the result'.
	self runModelsWithPrompt: prompt saveToFile: 'Test05a'.
	
	
]

{ #category : 'experiments' }
MistralApiExperiments >> pharoWhatIsAnInstanceVariable [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeMistralModel.
	mistralModel
			system: (AI_CommentBuilding ollamaSystem03 replaceAll: String cr with: '<br>').
	prompt := 'What is an Instance Variable in Pharo'.
	self runModelsWithPrompt: prompt saveToFile: 'Test03'.
	
	
	
]

{ #category : 'experiments' }
MistralApiExperiments >> pharoWhatIsAnInstanceVariable_b [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeMistralModel.
	mistralModel
			system: (AI_CommentBuilding ollamaSystem03 replaceAll: String cr with: '<br>').
	prompt := 'What is an Instance Variable in Pharo. Give an example. No explanation.'.
	self runModelsWithPrompt: prompt saveToFile: 'Test03b'.
	
	
	
]

{ #category : 'experiments' }
MistralApiExperiments >> pharoWhatIsAnInstanceVariable_b2 [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeMistralModel.
	mistralModel
			system: (AI_CommentBuilding ollamaSystem03 replaceAll: String cr with: '<br>').
	prompt := 'What is an Instance Variable in Pharo. Give an example. No explanation.'.
	self runModelsWithPrompt: prompt saveToFile: 'Test03b2'.
	
	
	
]

{ #category : 'accessing' }
MistralApiExperiments >> presenter [

	^ presenter
]

{ #category : 'accessing' }
MistralApiExperiments >> presenter: anObject [

	presenter := anObject
]

{ #category : 'writing' }
MistralApiExperiments >> runModelsWithPrompt: prompt saveToFile: file [
	"I run the prompt on all the models. 
	As it takes time, progress is shown in my Presenter.
	To be able to see the result and its basics, I store it in file"
	lines := OrderedCollection new.
	lines add: {'model name'. 'milisecs'. 'prompt'. 'response'}.
	presenter := MistralApiExperimentsPresenter new.
	presenter experiments: self.
	presenter open.
	World doOneCycle.
	mistralProcess := [1 to: models size do: [ :modelIndex | | seconds counting |
			mistralModel model: (models at: modelIndex).
			1 to: 4 do: [ :experimentIndex | 
				counting := self oneCounterFor: modelIndex experimentIndex: experimentIndex.
				World doOneCycle.
				seconds := Time millisecondClockValue.
				experimentIndex = 1
					ifTrue: [ mistralModel getResponseForPrompt: '4+5. What is the result. just the number' ]
					ifFalse: [ mistralModel getResponseForPrompt: prompt].
				seconds := (Time millisecondClockValue - seconds).
				counting terminate.
				presenter model: modelIndex experimentIndex: experimentIndex seconds: seconds.
				experimentIndex = 1
					ifTrue: [ lines add: { (#('x' 'a' 'b' 'c') at: experimentIndex),
									':    ', (models at: modelIndex). 
								seconds asString. 'Loading model'. 'Loading model' } ]
					ifFalse: [lines add: { (#('x' 'a' 'b' 'c') at: experimentIndex),
									':    ', (models at: modelIndex). 
								seconds asString. prompt. mistralModel response }].
			]
		].
		self  writeAsHTML: lines toFile: file.
	] fork.
]

{ #category : 'writing' }
MistralApiExperiments >> tableOn: html on: list [
	"Add the table to html, of all the models in list"
 	html
		tag: #table
		attributes: #(style 'width:90%')
		do: [ html tag: #tr 
				do: [ list first
						do: [ :header | 
							html tag: #th with: header ].
						html  ].
			2 to: list size do: [ :id | 
					html
						tag: #tr
						do: [ 
							1 to: (list at: id) size do: [ :x |
								html tag: #td with: ((list at: id) at: x).
								
							]].] 
					] 
]

{ #category : 'writing' }
MistralApiExperiments >> writeAsHTML: list toFile: fileName [
	| out html path|
	
	out := ('mistral/', fileName, '.html') asFileReference.
	out deleteIfAbsent: [  ].
	path := out pathString.
	out := out writeStream .
	html := ZnHtmlOutputStream on: out.
	self 
		html: html
		title: (fileName)
		do: [self tableOn: html on: list ].
		
	html tag: #h3 with: 'Prompt'.
	html tag: #pre with: mistralModel promptPrefix.
	html tag: #h3 with: 'System'.
	html tag: #pre with: mistralModel system.
	html flush; close.
	WebBrowser openOn: ('file://', path) asZnUrl .
]
