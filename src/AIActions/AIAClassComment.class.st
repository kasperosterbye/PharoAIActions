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
		'. Please respond according to the recommendations. Write the answer in MarkDown. Please response in ',
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
