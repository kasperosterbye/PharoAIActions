Class {
	#name : 'AI_CommentBuilding',
	#superclass : 'Object',
	#instVars : [
		'classObj',
		'methodsToComment',
		'system',
		'prompt'
	],
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'instance creation' }
AI_CommentBuilding class >> commentClass: aClass [
	"Change class cl, so all its uncommented methods, gets a comment"
	^ self new initialize: aClass
	
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> addComment: comment to: methodSource [
	"Assumes methodCode to be uncommented, returns methodCode with comment added"
	|  methodName rest |
	methodName := methodSource lines first.
	rest := String cr join: methodSource lines allButFirst.
	^ Character cr join: { methodName. comment asComment. rest }
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> aiCommentedInstanceVariables [
	"for classObj and all its methods to comment, 
	return an array of instance variable and suggested comment about them"
	|  instanceVariables  commentBuilder response responses |
	system := self generateOllamaSystemMethods.
	prompt := "'Just answer with a single line.'"
	'## Task
You are an AI assistant specialized in Pharo/Smalltalk code commentary.

## Your goal
Given an instance variable name and the class name it belongs to:
- Describe its likely purpose in 50 characters or fewer.
- Use a **single line**.
- Do **not** mention the user, prompts, or interactions.
- Do **not** use quotes or formatting characters.
- Prefer action-focused or purpose-driven phrases.
- No generic or placeholder responses.

## Example
classObj : Holds the class being analyzed for comments.
methodsToComment : Tracks methods needing commentary.
system : Stores constraints for comment generation.
prompt : Used to shape the response style and tone.

## Now respond to:'.
	instanceVariables := classObj instVarNames.
	commentBuilder := AI_OllamaPrompting newSystem: system promptPrefix: prompt .
	responses := WriteStream on: ''.
	responses nextPutAll: '## instace variables ', String cr.
	instanceVariables do: [ :iv | | nrPrompt |
		nrPrompt := 'Can you describe the purpose of ', iv, 
			' in class ', classObj name asString, ' as a comment. Just give a comment with 50 characters.'.
		response := self cleanComment: (commentBuilder getResonceForPrompt: nrPrompt) .
		responses nextPutAll: (iv, ' : ', response , String cr)
	].
	^ responses contents.
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> aiCommentedMethods [
	"for classObj and all its methods to comment, return an array of commented sourceCode"

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
AI_CommentBuilding >> classObj [ 
	^ classObj
]

{ #category : 'adding' }
AI_CommentBuilding >> classObj: anObject [ 
	classObj := anObject
]

{ #category : 'as yet unclassified' }
AI_CommentBuilding >> cleanComment: aString [
	"Needs to be made into a string, without embedded comments"
	^ aString copyWithoutAll: '"'
	
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> containsComment: code [
	"Checks if the code has a comment - return true if it does, false if not"
	| ast |
	ast := RBParser parseMethod: code.

	^ ast allChildren anySatisfy: [:node | node isKindOf: RBComment].
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> generateOllamaSystem [
	| systemInformation |
	systemInformation := WriteStream on: ''.
	systemInformation nextPutAll: ( self generateOllamaSystemForInstanceVariables), String cr.
	systemInformation nextPutAll: ( self generateOllamaSystemMethods), String cr.
	systemInformation nextPutAll: AI_OllamaPharo ollamaSystem03, String cr.
	^ systemInformation contents.
	
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> generateOllamaSystemForInstanceVariables [
	| systemInformation |
	systemInformation := WriteStream on: ''.
	systemInformation nextPutAll: '## ', classObj name, ' Insance variables (Pharo)', String cr.
	classObj instVarNames do: [ :iv |
		systemInformation nextPutAll: iv, String cr.
	].
	^ systemInformation contents.
	
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> generateOllamaSystemMethods [
	| systemInformation |
	systemInformation := WriteStream on: ''.
	systemInformation nextPutAll: '## ' , classObj name, ' Methods (Pharo)', String cr.
	classObj localMethods do: [ :iv |
		systemInformation nextPutAll: '### method ', (iv selector), ' (Pharo)', String cr.
		systemInformation nextPutAll: iv sourceCode, String cr, String cr.
	].
	^ systemInformation contents
	
	
	
]

{ #category : 'initialize' }
AI_CommentBuilding >> initialize: aClass [
	classObj := aClass.
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

{ #category : 'comment analysis' }
AI_CommentBuilding >> parallelPrompter: listOfPrompts [
	"too complicated"
	"I expect listOfPrompts to be {system. promptPrefix. prompt}. "

	|  prompts responses |
	prompts := Array new: listOfPrompts size.
	responses := Array new: listOfPrompts size.
	1 to: listOfPrompts size do: [ :nr |
		prompts at: nr 
			put: (AI_OllamaPrompting 
				newSystem: ((listOfPrompts at: nr) at: 1) 
				promptPrefix: ((listOfPrompts at: nr) at: 2) ).
		(prompts at: nr) askPrompt:((listOfPrompts at: nr) at: 3) 
	].
	1 to: listOfPrompts size do: [ :nr |
		responses 
			at: nr 
			put: (self addComment: (responses at: nr) getResponse to: (methodsToComment at: nr) sourceCode)
	].
	^ 77
]

{ #category : 'adding' }
AI_CommentBuilding >> prompt [ 
	^ prompt
]

{ #category : 'adding' }
AI_CommentBuilding >> prompt: anObject [ 
	prompt := anObject
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> proposeCommentForMethod: aMethod [
	"Given aMethod without comment, return a comment to be added to it"
]

{ #category : 'adding' }
AI_CommentBuilding >> system [ 
	^ system
]

{ #category : 'adding' }
AI_CommentBuilding >> system: anObject [ 
	system := anObject
]
