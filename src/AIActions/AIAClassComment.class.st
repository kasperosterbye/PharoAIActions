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

{ #category : 'accessing - comment' }
AIAClassComment class >> pharo11classCommentOutline [
	"This seems to have been omitted in Pharo12 and later. But can be build using Mistral"
	^ 'Class: MyClass
                                                                                                    
Please comment me using the following template inspired by Class Responsibility Collaborator (CRC) design:

For the Class part:  State a one line summary. For example, "I represent a paragraph of text".

For the Responsibility part: Three sentences about my main responsibilities - what I do, what I know.

For the Collaborators Part: State my main collaborators and one line about how I interact with them.

Public API and Key Messages

•	message one
•	message two
•	(for bonus points) how to create instances.


One simple example is simply gorgeous.

Internal Representation and Key Implementation Points.

Implementation Points'
]

{ #category : 'accessing - comment' }
AIAClassComment class >> setComment: aComment [
	"Sets a comment for a new instance of AI_ClassComment."
	^ self new setComment: aComment 
]

{ #category : 'accessing' }
AIAClassComment >> getComment: aClass [
	"Builds a comment for aClass."
	| mistral  |
	classSource := AIASourceCodeBuilder new forClass: aClass.
	
	prompt := 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Please respond according to the recommendations. Write the answer in MarkDown'.
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
