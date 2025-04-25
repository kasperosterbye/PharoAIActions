Class {
	#name : 'OllamaApiExperiments',
	#superclass : 'Object',
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'as yet unclassified' }
OllamaApiExperiments >> fiveForAlleModeller [
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
OllamaApiExperiments >> html: html title: title do: block [
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
OllamaApiExperiments >> writeAsHTML: list toFile: fileName [
	| out html path|
	
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
								do: [ :header | html tag: #th attributes: #('text-align' right) with: header ].
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
		html flush; close.
		WebBrowser openOn: ('file://', path) asZnUrl .
]

{ #category : 'writing' }
OllamaApiExperiments >> writeResultHTML [
	| rente forbrug saldo out inflation html path|
	rente := 0.04.
	inflation := 0.01.
	forbrug := 525000.
	"saldo := depotStart."
	
	out := 'fremskrivning.html' asFileReference.
	out deleteIfAbsent: [  ].
	path := out pathString.
	out := out writeStream .
	html := ZnHtmlOutputStream on: out.
	self html: html
		title: ('Fremskrivning', ' Forbrug: ', forbrug  , ' Rente: ', (rente * 100) , '%')
		do: [ html
				tag: #table
				attributes: #(style 'width:500px')
				do: [ html tag: #tr 
						do: [ #('år' 'Malene' 'Kasper' 'Engang' ' Netto ' 'Forbrug' ' Saldo')
								do: [ :header | html tag: #th attributes: #('text-align' right) with: header ].
								html  ].
						html << String cr.
					2025 to: 2063 do: [ :år | | netto engangs |
							html
								tag: #tr
								do: [ 
									html tag: #td with: år printString.
									html
										tag: #td
										with: (self ) asInteger asStringWithCommas.
									html
										tag: #td
										with: (self ) asInteger asStringWithCommas.
									engangs := (self ) asInteger.
									html
										tag: #td
										with:  engangs asStringWithCommas.
									netto := (self ) asInteger + engangs.
									html tag: #td with: netto asStringWithCommas.
									saldo := saldo + netto - forbrug.
									html tag: #td with: forbrug .
									forbrug := forbrug + (forbrug*inflation).
									saldo := saldo * (1 + rente).
									saldo := saldo asInteger.
									html tag: #td with: saldo asStringWithCommas ].
							html << String cr ] 
							
							] ].
		html flush; close.
		WebBrowser openOn: ('file://', path) asZnUrl .
]

{ #category : 'writing' }
OllamaApiExperiments >> writeResultHTML: list [
	| rente forbrug saldo out inflation html path|
	
	out := 'fremskrivning.html' asFileReference.
	out deleteIfAbsent: [  ].
	path := out pathString.
	out := out writeStream .
	html := ZnHtmlOutputStream on: out.
	self html: html
		title: ('Fremskrivning', ' Forbrug: ', forbrug  , ' Rente: ', (rente * 100) , '%')
		do: [ html
				tag: #table
				attributes: #(style 'width:500px')
				do: [ html tag: #tr 
						do: [ #('år' 'Malene' 'Kasper' 'Engang' ' Netto ' 'Forbrug' ' Saldo')
								do: [ :header | html tag: #th attributes: #('text-align' right) with: header ].
								html  ].
						html << String cr.
					2025 to: 2063 do: [ :år | | netto engangs |
							html
								tag: #tr
								do: [ 
									html tag: #td with: år printString.
									html
										tag: #td
										with: (self ) asInteger asStringWithCommas.
									html
										tag: #td
										with: (self ) asInteger asStringWithCommas.
									engangs := (self ) asInteger.
									html
										tag: #td
										with:  engangs asStringWithCommas.
									netto := (self ) asInteger + engangs.
									html tag: #td with: netto asStringWithCommas.
									saldo := saldo + netto - forbrug.
									html tag: #td with: forbrug .
									forbrug := forbrug + (forbrug*inflation).
									saldo := saldo * (1 + rente).
									saldo := saldo asInteger.
									html tag: #td with: saldo asStringWithCommas ].
							html << String cr ] 
							
							] ].
		html flush; close.
		WebBrowser openOn: ('file://', path) asZnUrl .
]

{ #category : 'writing' }
OllamaApiExperiments >> writeResultHTML_OLD [ 
	"| rente forbrug saldo out inflation html path|
	rente := 0.04.
	inflation := 0.01.
	forbrug := 525000.
	saldo := depotStart.
	
	out := 'fremskrivning.html' asFileReference.
	out deleteIfAbsent: [  ].
	path := out pathString.
	out := out writeStream .
	html := ZnHtmlOutputStream on: out.
	self html: html
		title: ('Fremskrivning', ' Forbrug: ', forbrug kFormat , ' Rente: ', (rente * 100) kFormat, '%')
		do: [ html
				tag: #table
				attributes: #(style 'width:500px')
				do: [ html tag: #tr 
						do: [ #('år' 'Malene' 'Kasper' 'Engang' ' Netto ' 'Forbrug' ' Saldo')
								do: [ :header | html tag: #th attributes: #('text-align' right) with: header ].
								html  ].
						html << String cr.
					2025 to: 2063 do: [ :år | | netto engangs |
							html
								tag: #tr
								do: [ 
									html tag: #td with: år printString.
									html
										tag: #td
										with: (self maleneUdbetaltÅr: år) asInteger asStringWithCommas.
									html
										tag: #td
										with: (self kasperUdbetaltÅr: år) asInteger asStringWithCommas.
									engangs := (self beggeEngangsÅr: år) asInteger.
									html
										tag: #td
										with:  engangs asStringWithCommas.
									netto := (self beggeUdbetaltÅrEfterSkat: år) asInteger + engangs.
									html tag: #td with: netto asStringWithCommas.
									saldo := saldo + netto - forbrug.
									html tag: #td with: forbrug kFormat.
									forbrug := forbrug + (forbrug*inflation).
									saldo := saldo * (1 + rente).
									saldo := saldo asInteger.
									html tag: #td with: saldo asStringWithCommas ].
							html << String cr ] 
							
							] ].
		html flush; close.
		WebBrowser openOn: ('file://', path) asZnUrl ".
]
