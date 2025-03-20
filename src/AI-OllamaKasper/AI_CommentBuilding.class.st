Class {
	#name : 'AI_CommentBuilding',
	#superclass : 'Object',
	#instVars : [
		'classObj',
		'methodsToComment',
		'system',
		'prompt',
		'terminatePrompt'
	],
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'instance creation' }
AI_CommentBuilding class >> commentClass: cl [
	"Change class cl, so all its uncommented methods, gets a comment"
	^ self new initialize: cl
	
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> addComment: comment to: methodCode [
	"Assumes methodCode to be uncommented, returns methodCode with comment added"
	|  methodName rest |
	methodName := methodCode lines first.
	rest := methodCode lines allButFirst.
	^ Character cr join: { methodName. comment asComment. rest }
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> aiCommentedMethods [
	"for classObj and all its methods to comment, return an array of commented sourceCode"
	"for each method:
		list of responces add reference to Prompting.
		call the askPrompt
	when all prompt called, collect the response comments in comment array
	for each method, add comment, and store the results in the methodsToComment"
	| prompterArray commentedCode |
	prompterArray := Array new: methodsToComment size.
	commentedCode := Array new: methodsToComment size.
	1 to: methodsToComment size do: [ :nr |
		prompterArray at: nr put: (AI_OllamaPrompting newSystem: system promptPrefix: prompt ).
		(prompterArray at: nr) askPrompt: (methodsToComment at: nr) sourceCode
		 ].
	1 to: methodsToComment size do: [ :nr |
		commentedCode 
			at: nr 
			put: (self addComment: (prompterArray at: nr) getResponse to: (methodsToComment at: nr) sourceCode)
	].
	^ commentedCode
]

{ #category : 'adding' }
AI_CommentBuilding >> classObj [ ^ classObj
]

{ #category : 'adding' }
AI_CommentBuilding >> classObj: anObject [ classObj := anObject
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> containsComment: code [
	"Checks if the code has a comment - return true if it does, false if not"
	| ast |
	ast := RBParser parseMethod: code.

	^ ast allChildren anySatisfy: [:node | node isKindOf: RBComment].
]

{ #category : 'initialize' }
AI_CommentBuilding >> initialize: cl [
	classObj := cl.
	methodsToComment := classObj localMethods.
	self nonCommentedMethods.
	system := 'Give respose of maximum 100 characters. Never more than 100 characters, and less is good. 
					Absolutely no code example may be given in response. '.
	prompt := 'Write short commentfor the following Pharo/Smalltalk method. 
					Return only the comment, nothing more,', Character cr asString .
	
]

{ #category : 'adding' }
AI_CommentBuilding >> methodsToComment [ 
	^ methodsToComment
]

{ #category : 'adding' }
AI_CommentBuilding >> methodsToComment: anObject [ 
	methodsToComment := anObject
]

{ #category : 'adding' }
AI_CommentBuilding >> methodsToComments [
	^ methodsToComment 
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> nonCommentedMethods [
	"reduces methodsToComment to contain only non commented methods"
	| uncommentedMethods |
	uncommentedMethods := OrderedCollection new.
	methodsToComment do: [ :compiledMethod |
			(self containsComment: compiledMethod sourceCode)
				ifFalse: [ uncommentedMethods add: compiledMethod ]
		].
	^ methodsToComment := uncommentedMethods asArray .
	
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> old_promptForCommentTo: methodText [
	| commentBuilder comment commentedMethod|
	commentBuilder := AI_OllamaPrompting newSystem: system promptPrefix: prompt. 
	comment := commentBuilder promptAndResponse: methodText.
	commentedMethod := self addComment: comment to: methodText.
	^ commentedMethod 
	"self addCommentToMethod: methodText comment: comment"
]

{ #category : 'adding' }
AI_CommentBuilding >> prompt [ ^ prompt
]

{ #category : 'adding' }
AI_CommentBuilding >> prompt: anObject [ prompt := anObject
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> promptForCommentTo: methodText [
	| commentBuilder comment commentedMethod|
	commentBuilder := AI_OllamaPrompting newSystem: system promptPrefix: prompt. 
	comment := commentBuilder promptAndResponse: methodText.
	commentedMethod := self addComment: comment to: methodText.
	^ commentedMethod 
	"self addCommentToMethod: methodText comment: comment"
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> proposeCommentForMethod: aMethod [
	"Given aMethod without comment, return a comment to be added to it"
]

{ #category : 'adding' }
AI_CommentBuilding >> system [ ^ system
]

{ #category : 'adding' }
AI_CommentBuilding >> system: anObject [ system := anObject
]

{ #category : 'adding' }
AI_CommentBuilding >> terminatePrompt [ ^ terminatePrompt
]

{ #category : 'adding' }
AI_CommentBuilding >> terminatePrompt: anObject [ terminatePrompt := anObject
]
