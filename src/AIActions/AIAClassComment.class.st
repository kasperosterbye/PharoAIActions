"
# Class: AIAClassComment

## Summary
I am responsible for generating and managing class comments for Pharo classes using AI-generated content.

## Responsibilities
- I build and set class comments for given classes.
- I retrieve existing class comments.
- I generate new class comments using AI models like Mistral.

## Collaborators
- **AIASourceCodeBuilder**: I use this to obtain the source code of a class.
- **MistralApi**: I interact with this to generate AI-based class comments.

## Public API and Key Messages

- `setComment: aClass`: Sets a new AI-generated comment for the given class.
- `getComment: aClass`: Generates a new AI-based comment for the given class.
- `existingComment: aClass`: Retrieves the existing comment of the given class.

## Example
```smalltalk
| commentBuilder |
commentBuilder := AIAClassComment new.
commentBuilder setComment: MyClass.
```

## Internal Representation and Key Implementation Points
- **Instance Variables**:
  - `classSource`: Holds the source code of the class for which the comment is being generated.

- **Key Implementation Points**:
  - The `getComment:` method constructs a prompt for the Mistral API, which is then used to generate a class comment.
  - The `setComment:` method sets the generated comment to the class.
  - The `existingComment:` method simply returns the current comment of the class.
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
AIAClassComment >> getComment_dansk: aClass [
	"Builds a comment for aClass."
	| mistral  |
	classSource := AIASourceCodeBuilder new forClass: aClass.
	
	prompt := 'Dette er et spørgsmål om en Pharo klasse kommentar for ', aClass asString, 
		'. Vær venlig at svare svare i følge anbefalingerne. Skriv svaret i MarkDown. Svaret skal være på Dansk'.
	mistral := MistralApi new.
	mistral system: classSource.
	response := mistral getResponseForPrompt: prompt.
	^ response 
	
]

{ #category : 'accessing' }
AIAClassComment >> getComment_old: aClass [
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
