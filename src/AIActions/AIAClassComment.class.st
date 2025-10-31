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

	history 
		system: (AIASourceCodeBuilder new forClass: aClass);
		background: 'When giving an example using the definition of a class, use: ' , 
			String cr, ShiftClassBuilder comment;
		user: 'This is a Pharo question. Can your give a class comment for ' , aClass asString;
		user: 'Use Markdown format in your response, and include a usage example suitable for the Playground. ';
		user: 'Prefer code that ends with an expression to be inspected using command-I. ';
		user: 'Return only the class comment (Markdown).';
		user: 'Please write the response in ' , AIACommentBuilding language.
	history getResponse
]

{ #category : 'accessing' }
AIAClassComment >> setComment: aClass [
	"Sets the class comment using AI-generated content, cleaning the response to remove markdown formatting and setting it as the class comment."
	| cleaned response first last|
	self aiaComment: aClass.
	"remove upto and included ```. Remove nothing if not found"
	response := self response.
	first := (response lines findFirst: [:each | each beginsWith: '```']) + 1.
	last := (response lines findLast: [:each | each beginsWith: '```']) - 1.
	last = -1 ifTrue: [ last := response lines size ].
	cleaned := (response lines
		copyFrom: first to: last)
		asStringWithCr.
	aClass comment: cleaned .
	
]
