"
# AIAClassComment

`AIAClassComment` is a specialized builder class designed to generate AI-driven class comments in Pharo. It extends the `AIACommentBuilding` framework to provide targeted, context-aware documentation for classes, leveraging AI to produce comments at varying levels of detail (basic, beginner, detailed, expert, test-guide).

## Design Intent

The primary purpose of `AIAClassComment` is to automate the creation of high-quality class comments by interacting with an AI model. It encapsulates the logic for constructing prompts, processing responses, and formatting the output in Markdown. The class is designed to be extensible, allowing for customisation of comment styles and languages.

## Key Features

- **Multi-Level Comment Generation**: Supports different comment types (basic, beginner, detailed, expert, test-guide) to cater to diverse audiences.
- **AI Integration**: Uses `AIAHistory` to manage conversation history with the AI model, ensuring context-aware responses.
- **Markdown Formatting**: All comments are generated in Markdown, ensuring readability and compatibility with Pharo's documentation tools.
- **Error Handling**: Robust error handling in `response` and `getResponse` methods to manage API failures gracefully.

## Usage Example

```smalltalk
""AIAClassComment example: Generate an expert-level comment for a class""
AIAClassComment new
    aiaCommentExpert: AIAClassComment;
    inspect
```

## Extension Points

- **Custom Prompts**: The `system:` and `user:` methods can be overridden to tailor prompts for specific use cases.
- **Response Processing**: The `response` method can be extended to include post-processing of AI responses.
- **Language Support**: The `language:` class method allows for easy switching of comment languages.

## Known Trade-offs

- **AI Dependency**: The quality of comments depends on the underlying AI model and its training data.
- **Response Time**: Generating comments may take time, especially for complex classes.
- **Determinism**: AI-generated content is non-deterministic, meaning repeated calls may produce slightly different results.

This class is part of the `AIActions` package and is intended for use in development environments where automated documentation is valuable.
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

	| typeName selector |
	typeName := AIACommentBuilding commentType.
	selector := ('aiaComment' , typeName , ':') asSymbol.
	self perform: selector with: aClass
]

{ #category : 'accessing' }
AIAClassComment >> aiaCommentBasic: aClass [
	"Generates a basic AI-driven class comment for aClass, following the same
	style and structure as #aiaComment:."

	history
		background: (AIASourceCodeBuilder new forClass: aClass);
		user: 'This is a Pharo question. Please give a short, basic class comment for ', aClass asString;
		responseType: 'The answer must only be the class comment text.';
		responseType: 'Please write the response in ', AIACommentBuilding language.
	history getResponse
]

{ #category : 'Protocol (as yet unclassified) - 1 selector(s)' }
AIAClassComment >> aiaCommentBeginner: aClass [ 
	self system: (AIASourceCodeBuilder new forClass: aClass).
	
	self user: 'This is a Pharo question. Can your give a class comment for ' , 
		aClass asString, 
		'. Use Markdown format in your response',
		' The reader of your response is a beginner, so please focus on the key aspects only, and give some examples'.
	self getResponse.
]

{ #category : 'accessing' }
AIAClassComment >> aiaCommentDefault: aClass [
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
AIAClassComment >> aiaCommentDetailed: aClass [
	history
		background: (AIASourceCodeBuilder new forClass: aClass);
		user: 'This is a Pharo question. Please write a DETAILED, '
			, 'expert‑level class comment for ', aClass asString, '.';
		user: 'Use Markdown. Include: (1) purpose and role in the system, '
			, '(2) main collaborators or dependencies, '
			, '(3) important invariants or design constraints, '
			, '(4) one or two illustrative usage examples.';
		user: 'Focus on how and when to use the class, not on Smalltalk '
			, 'syntax basics.';
		responseType: 'Return ONLY the class comment text in Markdown.';
		responseType: 'Please write the response in ', AIACommentBuilding language.
	history getResponse
]

{ #category : 'accessing' }
AIAClassComment >> aiaCommentExpert: aClass [

	history
		background: (AIASourceCodeBuilder new forClass: aClass);
		user: 'This is a Pharo question. Please write an EXPERT-LEVEL '
			, 'class comment for ', aClass asString, '.';
		user: 'Assume the reader already understands Pharo, collections, '
			, 'and common design patterns.';
		user: 'Use Markdown. Emphasise design intent, invariants, '
			, 'extension points, and known trade-offs. Include a brief '
			, 'usage example only if it clarifies a subtle point.';
		responseType: 'Return ONLY the class comment text in Markdown.';
		responseType: 'Please write the response in ', AIACommentBuilding language.
	history getResponse
]

{ #category : 'accessing' }
AIAClassComment >> aiaCommentLLM: aClass [

	history
		background: (AIASourceCodeBuilder new forClass: aClass);
		user: 'This is a Pharo question. Please give a class comment for ', aClass asString;
		user: 'The reader of the response is a LLM, so be short, precise and nonrepeating'.
	history getResponse
]

{ #category : 'accessing' }
AIAClassComment >> aiaCommentTestGuide: aClass [
	"Generates a test‑oriented AI class comment for aClass, in the same
	style as #aiaComment:."

	history
		background: (AIASourceCodeBuilder new forClass: aClass);
		user: 'This is a Pharo question. Please write a TEST-GUIDE style '
			, 'class comment for ', aClass asString, '.';
		user: 'The audience is someone writing unit tests for this class.';
		user: 'Use Markdown. Focus on: (1) observable behaviour to test, '
			, '(2) important edge cases, (3) typical fixtures or setup, '
			, '(4) examples of good test scenarios.';
		user: 'Do not explain basic Pharo or SUnit syntax.';
		responseType: 'Return ONLY the class comment text in Markdown.';
		responseType: 'Please write the response in British English.'.
	history getResponse
]

{ #category : 'accessing' }
AIAClassComment >> setComment: aClass [
	| cleaned response first last|
	self aiaComment: aClass.
	response := self response.
	first := 1. last := response lines size.
	(response lines first includesSubstring: '```markdown') 
		ifTrue: [first := 2. last := last - 1].
	cleaned := (response lines
		copyFrom: first to: last)
		asStringWithCr.
	aClass comment: cleaned .
	AIASlotComment for: aClass.
	
]
