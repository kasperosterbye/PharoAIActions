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
AIAClassComment >> aiaComment: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self prompt: 'This is a Pharo question. Can your give a class comment for ' , 
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
	
	self prompt: 'This is a Pharo question. With this class definition ', (AIASourceCodeBuilder new forClass: aClass), ' 
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
