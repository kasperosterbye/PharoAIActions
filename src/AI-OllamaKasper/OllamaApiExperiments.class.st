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
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
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
	|  prompt|
	self initializeOllamaModel.
	
	prompt := '2+3. What is the result'.

	self runModelsWithPrompt: prompt saveToFile: 'Test01'.
	
	
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
							'th, td {text-align:right } tr:nth-child(even){background-color: #f2f2f2}'].
				html
					tag: #body
					do: [ html tag: #h1 with: title.
						block value ] ]
]

{ #category : 'initialization' }
OllamaApiExperiments >> initializeOllamaModel [
	"I am called at the beginning of one of the experiments"
	models := OllamaApi modelNames " atAll: #(1 2 )".
	ollamaModel := OllamaApi new.
]

{ #category : 'accessing' }
OllamaApiExperiments >> ollamaProcess [

	^ ollamaProcess
]

{ #category : 'accessing' }
OllamaApiExperiments >> ollamaProcess: anObject [

	ollamaProcess := anObject
]

{ #category : 'experiments' }
OllamaApiExperiments >> pharoManualTestForModeller [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeOllamaModel.
	ollamaModel
			system: (AI_CommentBuilding ollamaSystem03 replaceAll: String cr with: '<br>').
	prompt := 'What is an Unary Message in Pharo'.
	self runModelsWithPrompt: prompt saveToFile: 'Test02b'.
	
	
]

{ #category : 'experiments' }
OllamaApiExperiments >> pharoWhatIsAnInstanceVariable [
	"Can the models produce a response for the prompt"
	| prompt|
	self initializeOllamaModel.
	ollamaModel
			system: (AI_CommentBuilding ollamaSystem03 replaceAll: String cr with: '<br>').
	prompt := 'What is an Instance Variable in Pharo'.
	self runModelsWithPrompt: prompt saveToFile: 'Test03'.
	
	
	
]

{ #category : 'writing' }
OllamaApiExperiments >> runModelsWithPrompt: promt saveToFile: file [
	"I run the prompt on all the models. 
	As it takes time, progress is shown in my Presenter.
	To be able to see the result and its basics, I store it in file"
	lines := OrderedCollection new.
	lines add: {'model name'. 'seconds'. 'prompt'. 'response'}.
	presenter := OllamaApiExperimentsPresenter new.
	presenter experiments: self.
	presenter open.
	ollamaProcess := [1 to: models size do: [ :index | | seconds counting |
			ollamaModel model: (models at: index).
			presenter set: index seconds: 0.
			counting := [  |fibbe| 
					fibbe := 0.
					[ 1 > 0 ] whileTrue: [
						(Delay forSeconds: 1) wait.
						fibbe := fibbe + 1.
						presenter set: index seconds: fibbe] ] fork.
			seconds := Time now asSeconds.
			ollamaModel getResponseForPrompt: promt.
			seconds := Time now asSeconds - seconds.
			counting terminate.
			presenter set: index seconds: seconds.
			lines add: { (models at: index). seconds asString. promt. ollamaModel response }
		]. 
		self  writeAsHTML: lines toFile: file.
	] fork .
]

{ #category : 'writing' }
OllamaApiExperiments >> runModelsWithPrompt_old: promt saveToFile: file [
	"I run the prompt on all the models. 
	As it takes time, progress is shown in my Presenter.
	To be able to see the result and its basics, I store it in file"
	lines := OrderedCollection new.
	lines add: {'modelName'. 'millis'. 'prompt'. 'response'}.
	models do: [ :modelName | | seconds |
			ollamaModel model: modelName.
			Transcript show: 'Running model: ' , modelName.
			World doOneCycle.
			seconds := Time now asSeconds.
			ollamaModel getResponseForPrompt: promt.
			seconds := Time now asSeconds - seconds.
			Transcript show: ' Seconds: ' , seconds asString; cr.
			World doOneCycle.
			lines add: { modelName. seconds asString. promt. ollamaModel response }
		].
	Transcript show: 'Done' ;cr.
	self  writeAsHTML: lines toFile: file.
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
	
	out := ('ollama/', fileName, '.html') asFileReference.
	out deleteIfAbsent: [  ].
	path := out pathString.
	out := out writeStream .
	html := ZnHtmlOutputStream on: out.
	self 
		html: html
		title: (fileName)
		do: [self tableOn: html on: list ].
		
	html tag: #h3 with: 'Prompt'.
	html tag: #pre with: ollamaModel promptPrefix.
	html tag: #h3 with: 'System'.
	html tag: #pre with: ollamaModel system.
	html flush; close.
	WebBrowser openOn: ('file://', path) asZnUrl .
]
