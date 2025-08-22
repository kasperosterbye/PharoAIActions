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
	^ self.
	
]

{ #category : 'accessing' }
AIAClassComment >> aiaComment_old: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self prompt: 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format, and include a usage example suitable for the Playground. ',
		'Prefer code that ends with an expression to be inspected using command-I. ',
		'When givin an example using the definition of a class, use: ', (ShiftClassBuilder comment),
		'Please write the response in ',
		AIACommentBuilding language.
	self getResponse.
	^ self.
	
]

{ #category : 'accessing' }
AIAClassComment >> old_aiaComment: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."
	"self system: (AIASourceCodeBuilder new forClass: aClass)."
	
	self prompt: 'This is a Pharo question. With this class definition ', (AIASourceCodeBuilder new forClass: aClass), ' 
	Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format, and include a usage example suitable for the Playground. ',
		'Prefer code that ends with an expression to be inspected using command-I. ',
		'When givin an example using the definition of a class, use: ', (ShiftClassBuilder comment),
		'Please write the response in ',
		AIACommentBuilding language.
	self getResponse.
	^ self.
	
]

{ #category : 'accessing' }
AIAClassComment >> setComment: aClass [
	"Builds a comment for aClass."
	self aiaComment: aClass.
	aClass comment: self response.
	^ self response 
	
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
