"
Killroy test
"
Class {
	#name : 'AIAClassComment',
	#superclass : 'AIACommentBuilding',
	#instVars : [
		'classSource'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'accessing' }
AIAClassComment >> existingComment: aClass [
	"Builds a comment for aClass."
	^ aClass comment 
	
]

{ #category : 'accessing' }
AIAClassComment >> getComment: aClass [
	"Builds a comment for aClass."
	| mistral  |
	classSource := AIASourceCodeBuilder new forClass: aClass.
	
	prompt := 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Please respond according to the recommendations. Write the answer in MarkDown. Please response in ',
		AIACommentBuilding language.
	mistral := MistralApi new.
	mistral system: classSource.
	response := mistral getResponseForPrompt: prompt.
	^ response 
	
]

{ #category : 'accessing' }
AIAClassComment >> setComment: aClass [
	"Builds a comment for aClass."
	self getComment: aClass.
	aClass comment: response.
	^ response 
	
]
