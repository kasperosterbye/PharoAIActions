"
Sofus has left
"
Class {
	#name : 'AI_ClassComment',
	#superclass : 'AI_CommentBuilding',
	#instVars : [
		'classSource'
	],
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'accessing - comment' }
AI_ClassComment class >> setComment: aComment [
	^ self new setComment: aComment 
]

{ #category : 'accessing' }
AI_ClassComment >> setComment: aClass [
	"Builds a comment for aClass."
	| mistral  |
	classSource := AI_PackagesAsOllamaSystem new forClass: aClass.
	
	prompt := 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Please respond according to the recommendations. Write the answer in MarkDown'.
	mistral := MistralApi new.
	mistral system: classSource.
	response := mistral getResponseForPrompt: prompt.
	aClass comment: response.
	^ response 
	
]
