"
# AIAMethodComment

`AIAMethodComment` is a builder class responsible for generating and applying AI-generated method comments to Pharo methods. It extends the `AIACommentBuilding` framework to provide automated documentation for method implementations.

## Usage Example

```st
""Create a new method comment builder and generate a comment for a method""
builder := AIAMethodComment new.
builder aiaComment: SomeClass >> #exampleMethod.
builder response. ""Inspect the generated comment""
```

## Key Features

- Generates concise (140 character) method summaries using AI
- Handles both quoted and unquoted comment formats
- Validates responses to avoid markdown formatting issues
- Integrates with the broader `AIActions` framework for AI-assisted development

## Design Considerations

The class follows the builder pattern to:
1. Prepare the AI prompt with method context
2. Process the response to ensure proper formatting
3. Apply the comment to the method source

Future improvements may include:
- More sophisticated comment generation strategies
- Support for different comment styles
- Integration with code analysis tools

This class is part of the `AIActions` package and works in conjunction with other AI-assisted development tools in the Pharo ecosystem.
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
	self user: 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 140 chacters, and only letters.', 
			' Please response in ', AIACommentBuilding language.
	self getResponse.
	^ self 
]

{ #category : 'internals' }
AIAMethodComment >> aiaComment: aCompiledMethod [
	self system: (AIASourceCodeBuilder new forClass: aCompiledMethod methodClass).
	self user: 'This is a Pharo question. Give a comment for method ' , aCompiledMethod name.
	self user: 'Response should be 100 chacters, and only letters and spaces.'. 
	self user: 'Please response in ', AIACommentBuilding language.
	self getResponse.
	"If it halts, it is likely because there is markdown that it should not make"
	(self response beginsWith: '```') ifTrue:[ self halt]
]

{ #category : 'internals' }
AIAMethodComment >> comment_aiaComment: aCompiledMethod [
	self system: (AIASourceCodeBuilder new forClass: aCompiledMethod methodClass).
	self user: 'This is a Pharo question. Can your give a method comment for ' , 
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
AIAMethodComment >> new_aiaComment: aCompiledMethod [
	self system: (AIASourceCodeBuilder new forClass: aCompiledMethod methodClass).
	self user: 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Please a detailed comment with all aspects. Your answer must not contain code, and no description of which method it is for as that is part of the prompt.'.
	self getResponse.
	"If it halts, it is likely because there is markdown that it should not make"
	(self response beginsWith: '```') ifTrue:[ self halt]
]

{ #category : 'internals' }
AIAMethodComment >> old_aiaComment: aCompiledMethod [
	self system: (AIASourceCodeBuilder new forClass: aCompiledMethod methodClass).
	self user: 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 140 chacters, and only letters.', 
			' Please response in ', AIACommentBuilding language.
	self getResponse.
	"If it halts, it is likely because there is markdown that it should not make"
	(self response beginsWith: '```') ifTrue:[ self halt]
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
	self user: 'This is a Pharo question. Can your give a method comment for ' , 
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
