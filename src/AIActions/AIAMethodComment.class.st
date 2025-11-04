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
	history background: (AIASourceCodeBuilder new forClass: aCompiledMethod methodClass).
	history background: (AIASourceCodeBuilder new forMethod: aCompiledMethod ).
	history user: 'This is a Pharo question. Give a comment for method ' , aCompiledMethod name.
	 
	history responseType: 'The answer must only be the comment.'.
	history responseType: 'Please response in ', AIACommentBuilding language.
	history responseType: 'Response should be max 100 chacters, and not longer, and only letters and spaces, and no `"`'.
	history getResponse.
	"If it halts, it is likely because there is markdown that it should not make"
	(history response beginsWith: '```') ifTrue:[ self error]
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
