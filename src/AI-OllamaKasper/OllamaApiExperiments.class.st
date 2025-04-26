Class {
	#name : 'OllamaApiExperiments',
	#superclass : 'Object',
	#instVars : [
		'ollamaModel',
		'lines',
		'models'
	],
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

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
	models := OllamaApi modelNames " atAll: #(1 2 )".
	ollamaModel := OllamaApi new.
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
