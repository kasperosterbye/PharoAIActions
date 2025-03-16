Class {
	#name : 'AI_CommentBuilding',
	#superclass : 'Object',
	#instVars : [
		'className',
		'methodsToComment',
		'system',
		'prompt'
	],
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'as yet unclassified' }
AI_CommentBuilding >> commentedSource: sourceCode [
	| hasComment |
	hasComment := ('"' match:  sourceCode) and: 
              [( sourceCode findTokens: '"') size > 1].
	^ hasComment 
]

{ #category : 'as yet unclassified' }
AI_CommentBuilding >> unmethodedMethodsInClass: class [
	className := class .
	methodsToComment := Dictionary new.
	className methods do: [ :method |
			self commentedSource: method sourceCode
		]
	
]
