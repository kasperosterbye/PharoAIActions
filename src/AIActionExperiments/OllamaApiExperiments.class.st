"
Fix this - it ended as nonsence...

I convert the result of some doing the experiement (system+prompt -> result) on multiple Ollama models.
"
Class {
	#name : 'OllamaApiExperiments',
	#superclass : 'Object',
	#instVars : [
		'ollamaModel',
		'lines',
		'models',
		'ollamaProcess',
		'presenter'
	],
	#category : 'AIActionExperiments',
	#package : 'AIActionExperiments'
}

{ #category : 'actions' }
OllamaApiExperiments >> cancelOllamaPrompt [
	"This method sends a user's input to an Ollama API and updates the chat history with the response."

	ollamaProcess ifNotNil: [
		ollamaProcess terminate.
	].
]

{ #category : 'experiments' }
OllamaApiExperiments >> fiveForAlleModeller [
	"Can the models calculate the prompt"
	self initializeOllamaModel.
	ollamaModel prompt: '2+3. What is the result'.
	self runModelsWithPrompt: ollamaModel prompt saveToFile: 'Test01'.
]

{ #category : 'experiments' }
OllamaApiExperiments >> fiveForAlleModeller_a [
	"Can the models calculate the prompt"
	| prompt|
	self initializeOllamaModel.
	prompt := '2+3. What is the result'.
	self runModelsWithPrompt: prompt saveToFile: 'Test01a'.
]

{ #category : 'experiments' }
OllamaApiExperiments >> fiveForAlleModeller_b [
	"Can the models calculate the prompt"
	| prompt|
	self initializeOllamaModel.
	prompt := '2+3. What is the result. just the number'.
	self runModelsWithPrompt: prompt saveToFile: 'Test01b'.
]

{ #category : 'writing' }
OllamaApiExperiments >> html: html title: title do: block [
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
OllamaApiExperiments >> initializeOllamaModel [
	"I am called at the beginning of one of the experiments"
	models := OllamaModelsApi modelNames "atAll: #(1 2 )".
	ollamaModel := OllamaModelsApi new.
]

{ #category : 'accessing' }
OllamaApiExperiments >> ollamaProcess [

	^ ollamaProcess
]

{ #category : 'accessing' }
OllamaApiExperiments >> ollamaProcess: anObject [

	ollamaProcess := anObject
]

{ #category : 'writing' }
OllamaApiExperiments >> oneCounterFor: modelIndex experimentIndex: experimentIndex [
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
OllamaApiExperiments >> pharoManualTestForModeller_a [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeOllamaModel.
	prompt := 'What is an Unary Message in Pharo'.
	self runModelsWithPrompt: prompt saveToFile: 'Test02a'.

]

{ #category : 'experiments' }
OllamaApiExperiments >> pharoManualTestForModeller_b [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeOllamaModel.
	ollamaModel
			system: (AIACommentBuilding ollamaSystem03 replaceAll: String cr with: '<br>').
	prompt := 'What is an Unary Message in Pharo'.
	self runModelsWithPrompt: prompt saveToFile: 'Test02b'.
	
	
]

{ #category : 'experiments' }
OllamaApiExperiments >> pharoManualTestForModeller_c [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeOllamaModel.
	ollamaModel
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
OllamaApiExperiments >> pharoManualTestForModeller_d [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeOllamaModel.
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
OllamaApiExperiments >> pharoWhatIsAnInstanceVariable [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeOllamaModel.
	ollamaModel
			system: (AIACommentBuilding ollamaSystem03 replaceAll: String cr with: '<br>').
	prompt := 'What is an Instance Variable in Pharo'.
	self runModelsWithPrompt: prompt saveToFile: 'Test03'.
	
	
	
]

{ #category : 'experiments' }
OllamaApiExperiments >> pharoWhatIsAnInstanceVariable_b [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeOllamaModel.
	ollamaModel
			system: (AIACommentBuilding ollamaSystem03 replaceAll: String cr with: '<br>').
	prompt := 'What is an Instance Variable in Pharo. Give an example. No explanation.'.
	self runModelsWithPrompt: prompt saveToFile: 'Test03b'.
	
	
	
]

{ #category : 'accessing' }
OllamaApiExperiments >> presenter [

	^ presenter
]

{ #category : 'accessing' }
OllamaApiExperiments >> presenter: anObject [

	presenter := anObject
]

{ #category : 'writing' }
OllamaApiExperiments >> runModelsWithPrompt: prompt saveToFile: file [
	"I run the prompt on all the models. 
	As it takes time, progress is shown in my Presenter.
	To be able to see the result and its basics, I store it in file"
	lines := OrderedCollection new.
	lines add: {'model name'. 'seconds'. 'prompt'. 'response'}.
	presenter := OllamaApiExperimentsPresenter new.
	presenter experiments: self.
	presenter open.
	World doOneCycle.
	ollamaProcess := [1 to: models size do: [ :modelIndex | | seconds counting |
			ollamaModel model: (models at: modelIndex).
			1 to: 4 do: [ :experimentIndex | 
				counting := self oneCounterFor: modelIndex experimentIndex: experimentIndex.
				World doOneCycle.
				seconds := Time now asSeconds.
				experimentIndex = 1
					ifTrue: [ ollamaModel getResponseForPrompt: '2+3. What is the result. just the number' ]
					ifFalse: [ ollamaModel getResponseForPrompt: prompt].
				seconds := Time now asSeconds - seconds.
				counting terminate.
				presenter model: modelIndex experimentIndex: experimentIndex seconds: seconds.
				experimentIndex = 1
					ifTrue: [ lines add: { (#('x' 'a' 'b' 'c') at: experimentIndex),
									':    ', (models at: modelIndex). 
								seconds asString. 'Loading model'. 'Loading model' } ]
					ifFalse: [lines add: { (#('x' 'a' 'b' 'c') at: experimentIndex),
									':    ', (models at: modelIndex). 
								seconds asString. prompt. ollamaModel response }].
			]
		].
		self  writeAsHTML: lines toFile: file.
	] fork.
]

{ #category : 'writing' }
OllamaApiExperiments >> runModelsWithPrompt_old: prompt saveToFile: file [
	"I run the prompt on all the models. 
	As it takes time, progress is shown in my Presenter.
	To be able to see the result and its basics, I store it in file"
	lines := OrderedCollection new.
	lines add: {'model name'. 'seconds'. 'prompt'. 'response'}.
	presenter := OllamaApiExperimentsPresenter new.
	presenter experiments: self.
	presenter open.
	World doOneCycle.
	ollamaProcess := [1 to: models size do: [ :modelIndex | | seconds counting |
			ollamaModel model: (models at: modelIndex).
			1 to: 3 do: [ :experimentIndex | 
				counting := self oneCounterFor: modelIndex experimentIndex: experimentIndex.
				World doOneCycle.
				seconds := Time now asSeconds.
				experimentIndex = 1
					ifTrue: [ ollamaModel getResponseForPrompt: '2+3. What is the result. just the number' ]
					ifFalse: [ ollamaModel getResponseForPrompt: prompt].
				seconds := Time now asSeconds - seconds.
				counting terminate.
				presenter model: modelIndex experimentIndex: experimentIndex seconds: seconds.
				experimentIndex = 1
					ifTrue: [ lines add: { (#('x' 'a' 'b') at: experimentIndex),':    ', (models at: modelIndex). 
								seconds asString. 'Loading model'. 'Loading model' } ]
					ifFalse: [lines add: { (#('x' 'a' 'b') at: experimentIndex),':    ', (models at: modelIndex). 
								seconds asString. prompt. ollamaModel response }].
			]
		].
		self  writeAsHTML: lines toFile: file.
	] fork.
]

{ #category : 'writing' }
OllamaApiExperiments >> tableOn: html on: list [
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
OllamaApiExperiments >> writeAsHTML: list toFile: fileName [
	| out html path|
	
	out := ('AIAExperiments/', fileName, '.html') asFileReference.
	out deleteIfAbsent: [  ].
	path := out pathString.
	out := out writeStream .
	html := ZnHtmlOutputStream on: out.
	self 
		html: html
		title: (fileName)
		do: [self tableOn: html on: list ].
		
	html tag: #h3 with: 'Prompt'.
	html tag: #pre with: ollamaModel prompt.
	html tag: #h3 with: 'System'.
	html tag: #pre with: ollamaModel system.
	html flush; close.
	WebBrowser openOn: ('file://', path) asZnUrl .
]
