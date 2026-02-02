Class {
	#name : 'AIAClassComment',
	#superclass : 'AIACommentBuilding',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'accessing' }
AIAClassComment >> aiaComment: aClass [
	"Generates an AI driven class comment for the given class using the current comment type"

	| typeName selector |
	typeName := AIACommentBuilding commentType.
	selector := ('aiaComment' , typeName , ':') asSymbol.
	self perform: selector with: aClass
]

{ #category : 'accessing' }
AIAClassComment >> aiaCommentBasic: aClass [
	history
		background: (AIASourceCodeBuilder new forClass: aClass);
		user: 'This is a Pharo question. Please give a short, basic class comment for ', aClass asString;
		user: 'The reader is a programmer who is a Pharo/Smalltalk expert';
		user: 'Response must be short, focus on purpose, no focus on implementation, no focus on varables';
		responseType: 'Please write the response in ', AIACommentBuilding language.
	history getResponse
]

{ #category : 'Protocol (as yet unclassified) - 1 selector(s)' }
AIAClassComment >> aiaCommentBeginner: aClass [ 
	history
		background: (AIASourceCodeBuilder new forClass: aClass);
		user: 'This is a Pharo question. Can your give a class comment for ' , 
			aClass asString, 
			'. Just return the Class comment, no prior explanation response. ',
			' The reader of your response is a beginner, so please focus on the key aspects only, and give some examples';
		responseType: 'Please write the response in ', AIACommentBuilding language.
	history getResponse.
]

{ #category : 'accessing' }
AIAClassComment >> aiaCommentDefault: aClass [
	"Generates a comment for a class using AI, formatted in Markdown, with a usage example for the Playground."

	history 
		background: (AIASourceCodeBuilder new forClass: aClass);
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

{ #category : 'Protocol (accessing) - 10 selector(s)' }
AIAClassComment >> aiaCommentLLM: aClass [
	history
		background: (AIASourceCodeBuilder new forClass: aClass);
		user: 'This is a Pharo question. Please give a class comment for ', aClass asString;
		user: 'Return ONLY a compact machine-readable summary in plain text with these keys: purpose, inputs, outputs, collaborators, side_effects, invariants, extension_points, example_calls. No headings, no narrative, no Markdown.';
		user: 'Use one line per key. Format EXACTLY: key = value. No colons. No bullet points. No extra keys.'.
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
AIAClassComment >> aiaMetaComment: aClass [
	"Generates an AI driven class comment for the given class using the current comment type"

	| typeName selector |
	typeName := AIACommentBuilding commentType.
	selector := ('aiaComment' , typeName , ':') asSymbol.
	self perform: selector with: aClass
]

{ #category : 'accessing' }
AIAClassComment >> setComment: aClass [
	| cleaned response first last|
	self aiaComment: aClass.
	response := self response.
	first := response lines detectIndex: [ :each | each = '```markdown' ] ifNone: [ 0 ].
	last := response lines lastIndexOf: '```' ifAbsent: [ 0 ].
	cleaned := first > 0 ifTrue: [ 
		last = response lines size 
			ifTrue: [ String lf join: (response lines copyFrom: first+1 to: last-1) ]
			ifFalse: [ String lf join: (response lines copyFrom: first+1 to: response lines size)  ]]
		ifFalse: [ response ].
	aClass comment: cleaned .
	aClass instVarNames ifNotEmpty:[ AIASlotComment for: aClass]
	
]
