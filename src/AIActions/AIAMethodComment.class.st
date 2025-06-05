"
This class implements AI based comment generations for methods. There are several levels.

1) If the method already have a comment (checks if the second line starts with "" ), then that comment is kept.
2) If no comment exist it will look at the senders of this method
* There is no senders. It can be either a method that should be removed, or an important one to be used on the outside. The comment should be added that ask the developer to solve the issue - if it is imporant, add usage to class side or in tests

* More than around 50% of the senders are in the same class. Ignore the other 50% as they are most likely unrelated, but just using the same name. Give the same class methods as input to the understanding of the method

* There number of senders from other classes is high, meaning that the implementation of the method is done in many classes. Assume the name of the class is widely used, and check if the method it self is implemented in all those classes as well.
	If they are, use these other classes as input to the AI comment generator
	If they are not, use the senders as input to the AI comment generator
"
Class {
	#name : 'AIAMethodComment',
	#superclass : 'AIACommentBuilding',
	#instVars : [
		'compiledMethod',
		'methodSource',
		'commentType'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'initialization' }
AIAMethodComment class >> for: method [
	"This method creates a new instance of AI_MethodComment"
	^ self new initialize: method 
]

{ #category : 'internals' }
AIAMethodComment >> commentSourceFor: aCompiledMethod [
	"The method commentSourceFor takes a compiled method, formats its class name and source code, and returns the formatted string."
	| sourceString |
	sourceString := WriteStream on: ''.
	sourceString << aCompiledMethod methodClass name << ' >> #'.
	sourceString << aCompiledMethod sourceCode << String cr << String cr.
	^ sourceString contents
]

{ #category : 'tests - accessing' }
AIAMethodComment >> compiledMethod [

	^ compiledMethod
]

{ #category : 'internals' }
AIAMethodComment >> existingComment: aCompiledMethod [
	aCompiledMethod comment ifNil: [^ ''].
	^ aCompiledMethod comment  	
]

{ #category : 'internals' }
AIAMethodComment >> getBlackComment: aCompiledMethod [
	| mistral |
	compiledMethod := aCompiledMethod.
	
	methodSource := (self commentSourceFor: compiledMethod) .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 250 chacters, and only letters. Please response in ',
		AIACommentBuilding language.
	mistral := MistralApi new.
	mistral system: (AIASourceCodeBuilder new forMethod: aCompiledMethod ).
	response := mistral getResponseForPrompt: prompt.
	^ response
]

{ #category : 'internals' }
AIAMethodComment >> getComment: aCompiledMethod [
	| mistral |
	compiledMethod := aCompiledMethod.
	
	methodSource := (self commentSourceFor: compiledMethod) .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 100 chacters, and only letters. Please response in ',
		AIACommentBuilding language.
	mistral := MistralApi new.
	mistral system: (AIASourceCodeBuilder new forMethod: aCompiledMethod ).
	response := mistral getResponseForPrompt: prompt.
	^ response
]

{ #category : 'internals' }
AIAMethodComment >> getWhiteComment [
	| mistral |
	
	methodSource := (self commentSourceFor: compiledMethod) .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		compiledMethod name, 
			'. Your response should be 140 chacters, and only letters. Please response in ',
		AIACommentBuilding language.
	mistral := MistralApi new.
	mistral system: (AIASourceCodeBuilder new forClass: compiledMethod methodClass).
	response := mistral getResponseForPrompt: prompt.
	^ response
]

{ #category : 'internals' }
AIAMethodComment >> getWhiteComment: aCompiledMethod [
	| mistral |
	compiledMethod := aCompiledMethod.
	
	methodSource := (self commentSourceFor: compiledMethod) .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 140 chacters, and only letters. Please response in ',
		AIACommentBuilding language.
	mistral := MistralApi new.
	mistral system: (AIASourceCodeBuilder new forClass: aCompiledMethod methodClass).
	response := mistral getResponseForPrompt: prompt.
	^ response
]

{ #category : 'initialization' }
AIAMethodComment >> initialize: method [
	super initialize.
	compiledMethod := method.
	methodSource := compiledMethod sourceCode.
	commentType := #blackComment
	
]

{ #category : 'tests - accessing' }
AIAMethodComment >> methodSource [

	^ methodSource
]

{ #category : 'internals' }
AIAMethodComment >> methodSourceAddComment: comment [
	"Adds a comment to the method source code."
	| sourceLines safeComment |
	safeComment := comment copyWithoutAll: '"'.
	sourceLines := compiledMethod sourceCode lines asOrderedCollection.
	sourceLines add: (String tab, '"' , comment, '"' ) afterIndex: 1.
	^ String cr join: sourceLines 
	
]

{ #category : 'internals' }
AIAMethodComment >> setComment: aCompiledMethod [
	
	aCompiledMethod comment ifNotNil: [ ^ nil ].
	self getComment: aCompiledMethod.
	compiledMethod methodClass
		compile: (self methodSourceAddComment: response)
		classified: compiledMethod protocol
]

{ #category : 'internals' }
AIAMethodComment >> setWhiteComment: aCompiledMethod [
	
	aCompiledMethod comment ifNotNil: [ ^ nil ].
	self getWhiteComment: aCompiledMethod.
	compiledMethod methodClass
		compile: (self methodSourceAddComment: response)
		classified: compiledMethod protocol
]
