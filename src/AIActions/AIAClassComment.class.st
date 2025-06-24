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
	"Builds a comment for aClass."
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self prompt: 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format, and include a usage example suitable for the Playground. ',
		'Prefer code that ends with an expression to be inspected using ⌘I. ',
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
