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
AIAMethodComment >> aiaBlackComment: aCompiledMethod [ 
	self system: (AIASourceCodeBuilder new forMethod: aCompiledMethod ).
	self prompt: 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 140 chacters, and only letters.', 
			' Please response in ', AIACommentBuilding language.
	self getResponse.
	^ self 
]

{ #category : 'internals' }
AIAMethodComment >> aiaComment: aCompiledMethod [
	self system: (AIASourceCodeBuilder new forClass: aCompiledMethod methodClass).
	self prompt: 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 140 chacters, and only letters.', 
			' Please response in ', AIACommentBuilding language.
	self getResponse
]

{ #category : 'internals' }
AIAMethodComment >> comment_aiaComment: aCompiledMethod [
	self system: (AIASourceCodeBuilder new forClass: aCompiledMethod methodClass).
	self prompt: 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 140 chacters, and only letters.', 
			' Please response in ', AIACommentBuilding language.
	self getResponse
]

{ #category : 'internals' }
AIAMethodComment >> methodSource: compiledMethod addComment: comment [
	"This method adds a comment to the source code of a compiled method, ensuring proper formatting and escaping of special characters. It handles both quoted and unquoted comments, maintaining the method's structure while integrating the new comment."
	| sourceLines safeComment |
	safeComment := comment copyWithoutAll: '"'.
	sourceLines := compiledMethod sourceCode lines asOrderedCollection.
	((comment beginsWith: '"') and: [comment endsWith: '"'])
		ifTrue: [ sourceLines add: (String tab, comment ) afterIndex: 1 ]
		ifFalse: [ sourceLines add: (String tab, '"' , comment, '"' ) afterIndex: 1].
	^ String cr join: sourceLines 
	
]

{ #category : 'internals' }
AIAMethodComment >> setBlackComment: aCompiledMethod [
	
	aCompiledMethod comment ifNotNil: [ ^ nil ].
	self aiaBlackComment: aCompiledMethod.
	aCompiledMethod methodClass
		compile: (self methodSource: aCompiledMethod addComment: self response)
		classified: aCompiledMethod protocol
]

{ #category : 'internals' }
AIAMethodComment >> setComment: aCompiledMethod [
	
	aCompiledMethod comment ifNotNil: [ ^ nil ].
	self aiaComment: aCompiledMethod.
	aCompiledMethod methodClass
		compile: (self methodSource: aCompiledMethod addComment: self response)
		classified: aCompiledMethod protocol
]

{ #category : 'internals' }
AIAMethodComment >> testSupportComment_aiaComment: aCompiledMethod [
	self system: (AIASourceCodeBuilder new forClass: aCompiledMethod methodClass).
	self prompt: 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should only be letters. 
			It usage is to understand how to write a test for it.
			Explain the purpose of the method in terms of user-visible behavior or UI changes, not just internal logic.
			Include edge cases or assumptions that a test should verify (e.g., what if input is invalid or at a boundary?).
			If the method mutates state, describe exactly what changes and what should be observable after calling it.
			', 
			' Please response in ', AIACommentBuilding language.
	self getResponse
]
