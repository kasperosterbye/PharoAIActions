Class {
	#name : 'OllamaModelsApiTest',
	#superclass : 'TestCase',
	#instVars : [
		'ollamaModelsApi'
	],
	#category : 'AIActions-Tests-AIAPI-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIAPI-Tests'
}

{ #category : 'running' }
OllamaModelsApiTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	

	ollamaModelsApi := OllamaModelsApi new.
]
