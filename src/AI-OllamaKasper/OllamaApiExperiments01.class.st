Class {
	#name : 'OllamaApiExperiments01',
	#superclass : 'OllamaApi',
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'as yet unclassified' }
OllamaApiExperiments01 >> fiveForAlleModeller [
	"return a list of OrderedDictiontionaries, {modelName, prompt, response}"
	| lines models prompt|
	lines := OrderedCollection new.
	lines add: {'modelName'. 'prompt'. 'response'}.
	models := OllamaApi modelNames atAll: #(1 2).
	prompt := '2+3. What is the result'.
	models do: [ :modelName | |ollamaModel |
		ollamaModel := OllamaApi new.
		ollamaModel
			model: modelName.
		Transcript show: 'Running model: ' , modelName ;cr.
		World doOneCycle.
		ollamaModel getResponseForPrompt: prompt.
		lines add: { modelName. prompt. ollamaModel response }
	].
	self  writeAsHTML: lines toFile: 'Test02'.
	
	
]

{ #category : 'writing' }
OllamaApiExperiments01 >> html: html title: title do: block [
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

{ #category : 'writing' }
OllamaApiExperiments01 >> writeAsHTML: list toFile: fileName [
	| out html path|

	self halt.		
	out := ('ollama/', fileName, '.html') asFileReference.
	out deleteIfAbsent: [  ].
	path := out pathString.
	out := out writeStream .
	html := ZnHtmlOutputStream on: out.
	self html: html
		title: (fileName)
		do: [ html
				tag: #table
				attributes: #(style 'width:90%')
				do: [ html tag: #tr 
						do: [ list first
								do: [ :header | 
									html tag: #th with: header ].
								html  ].
						html << String cr.
					2 to: list size do: [ :id | 
							html
								tag: #tr
								do: [ 
									1 to: (list at: id) size do: [ :x |
										html tag: #td with: ((list at: id) at: x).							
									]].] 
							] ].
		html tag: #h3 with: 'Prompt'.
		html tag: #p with: promptPrefix.
		html tag: #h3 with: 'System'.
		html tag: #p with: system .
		html flush; close.
		WebBrowser openOn: ('file://', path) asZnUrl .
]
