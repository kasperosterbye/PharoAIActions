Class {
	#name : 'OllamaApiExperiments01',
	#superclass : 'OllamaApi',
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'as yet unclassified' }
OllamaApiExperiments01 >> femForAlleModeller [
	"return a list of OrderedDictiontionaries, {modelName, prompt, response}"
	| lines models prompt|
	lines := OrderedCollection new.
	lines add: {'modelName'. 'prompt'. 'response'}.
	"Temporaty, l"
	models := OllamaApi modelNames atAll: #(10 12).
	prompt := '2+3. What is the result'.
	models do: [ :modelName | 
		model := modelName.
		promptPrefix := prompt.
		Transcript show: 'Running model: ' , modelName ;cr;flush.
		[self getResponseForPrompt:''] fork .
		lines add: { modelName. prompt. response }
		 ].
	^lines 
	
	
]
