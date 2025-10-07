"
Killroy test
"
Class {
	#name : 'AIAClassComment',
	#superclass : 'AIACommentBuilding',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'accessing' }
AIAClassComment >> aiaComment01: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self user: 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format in your response',
		' Please a detailed comment with all aspects. Your answer must not contain code, and no description of which class it is for as that is part of the prompt.'.
	self getResponse.
	
]

{ #category : 'accessing' }
AIAClassComment >> aiaComment02: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self user: 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format in your response',
		' The reader of your response is a beginner, so please focus on the key aspects only, and give some examples'.
	self getResponse.
	
]

{ #category : 'accessing' }
AIAClassComment >> aiaComment03: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self user: 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format in your response. ',
		'The reader is a Pharo expert, so no need to explain simple stuff. Give a short response, with focus on errors that might happen if not used right. Do not present an example'.
	self getResponse.
	
]

{ #category : 'accessing' }
AIAClassComment >> aiaComment04: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self user: 'This is a Pharo question. ' , 
		'. Use Markdown format in your response. ',
		'The reader is an LLM that will be asked to produce tests for each of its methods. Please make the response all the instructions for writing tests in Pharo for this specific class: ', 
		aClass asString.
	self getResponse.
	
]

{ #category : 'accessing' }
AIAClassComment >> aiaComment: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self user: 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format in your response',
		' Please a detailed comment with all aspects. Your answer must not contain code, and no description of which class it is for as that is part of the prompt.'.
	self getResponse.
	
]

{ #category : 'accessing' }
AIAClassComment >> new_aiaComment: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self user: 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format in your response',
		' Please a detailed comment with all aspects. Your answer must not contain code, and no description of which class it is for as that is part of the prompt.'.
	self getResponse.
	
]

{ #category : 'accessing' }
AIAClassComment >> old_aiaComment: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self user: 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format in your response, and include a usage example suitable for the Playground. ',
		'Prefer code that ends with an expression to be inspected using command-I. ',
		'When givin an example using the definition of a class, use: ', (ShiftClassBuilder comment),
		'Just response the comment.',
		'Please write the response in ',
		AIACommentBuilding language.
	self getResponse.
	
]

{ #category : 'accessing' }
AIAClassComment >> setComment: aClass [
	"Sets the class comment using AI-generated content, cleaning the response to remove markdown formatting and setting it as the class comment."
	| cleaned response |
	self aiaComment: aClass.
	"remove upto and included ```. Remove nothing if not found"
	response := self response.
	cleaned := (response lines
		copyFrom: ((response lines findFirst: [:each | each beginsWith: '```']) + 1)
		to: (response lines findLast: [:each | each beginsWith: '```']) - 1) 
		asStringWithCr.
	aClass comment: cleaned .
	
]

{ #category : 'accessing' }
AIAClassComment >> testCommentaiaComment: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	"self system: (AIASourceCodeBuilder new forClass: aClass)."
	
	self user: 'This is a Pharo question. With this class definition ', (AIASourceCodeBuilder new forClass: aClass), ' 
	Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format, and include a usage example suitable for the Playground. ',
		'Also explain how the class is typically used and what a test should validate. ',
		'Mention key methods or behaviors that are important to verify in a unit test. ',
		'Describe interactions or state changes that are critical for correct behavior. ',
		'Prefer code that ends with an expression to be inspected using command-I. ',
		'When givin an example using the definition of a class, use: ', (ShiftClassBuilder comment),
		'Please write the response in ',
		AIACommentBuilding language.
	self getResponse.
	^ self.
	
]
