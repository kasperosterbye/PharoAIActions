"
## Class Comment for AIATestGenerator

"
Class {
	#name : 'AIAMistralTestGenerator',
	#superclass : 'Object',
	#instVars : [
		'chatBuilder',
		'sourceMethod',
		'testMethod'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'instance creation' }
AIAMistralTestGenerator class >> buildAll: aClass [
	aClass methodDict values do: [ :method |
		self new build: method.
	 ]
]

{ #category : 'instance creation' }
AIAMistralTestGenerator >> build: aMethod [
	| aiTestClass |
	aiTestClass := self buildTestForMethod: aMethod.
	self for: aMethod.
	testMethod := self repairResponseMethod.
	[ aiTestClass compile: testMethod classified: 'AI generated test']
		on: Error
		do: [ self buildFromErrorFor: aiTestClass].
	^ self history
]

{ #category : 'as yet unclassified' }
AIAMistralTestGenerator >> buildFromErrorFor: aiTestClass [
	"The method attempts to fix and compile a test method that initially failed due to errors by generating a corrected version and retrying compilation."
	| method2 |
	method2 := 'There are some errors in the method. Can you suggest one without any errors. Just return the method, no markdown, but keep line shifts' q: [ testMethod  ].
	method2 := method2 copyReplaceAll: Character lf asString with: Character cr asString.
	[aiTestClass compile: method2 classified: 'AI generated test']
		on: Error
		do: [ self halt].
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> buildTestForMethod: method [
	| methodClass aiTestClass shifter|
	methodClass := method methodClass name.
	aiTestClass := (methodClass , 'AITest' ) asSymbol.
	Smalltalk globals at: (methodClass , 'Test') asSymbol 
		ifAbsent: [ self error: 'There should be a test class: ', methodClass , 'Test' ].
	^ Smalltalk globals at: aiTestClass 
	ifAbsent: [
		shifter := ShiftClassBuilder new.
		shifter 
			superclassName: (methodClass , 'Test') asSymbol;
			name: aiTestClass;
			slots: { "method methodClass name "};
			package: 'AIATestExperiments'.
		^ shifter install .
	]
]

{ #category : 'accessing' }
AIAMistralTestGenerator >> chatBuilder [

	^ chatBuilder
]

{ #category : 'instance creation' }
AIAMistralTestGenerator >> cleanAIResponse: responseText [
    | lines |
    lines := responseText lines.
    
    "Remove markdown code fences"
    (lines first beginsWith: '```') ifTrue: [
        lines := lines allButFirst allButLast
    ].
    
    ^ String cr join: lines
]

{ #category : 'instance creation' }
AIAMistralTestGenerator >> for: aMethod [
	"aMethod is the compiled method to which a test should be renerated."
	sourceMethod := aMethod.
	"testClass := sourceMethod methodClass packageName asString , '-Tests'."
	self generateTest.
	
	^ testMethod 
]

{ #category : 'instance creation' }
AIAMistralTestGenerator >> generateTest [
	self systemGenerator.
	self hist92WhatIsTheBasics.
	self hist1GeneratorMethods.
	self hist2WhereToPlaceTestMethod.
	self hist3WhatIsTheBasics.
	self hist50WhatIsTheBasics.
	self hist51WhatIsTheBasics.
	self hist90WhatIsTheBasics.
	self promptGenerator.
	chatBuilder getResponse.
	testMethod := self cleanAIResponse: chatBuilder response .
	(chatBuilder response = 'Data receive timed out.') ifTrue: [
		chatBuilder response: ''.
		self systemGeneratorClasses.
		chatBuilder getResponse.
		testMethod := chatBuilder response .
		 ]
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> hist1GeneratorMethods [
	chatBuilder user: 'I have heard that Pharo have different types of methods, what are they'.
	chatBuilder assistant:'
Important Coding Rule

When writing Pharo code or tests:
	•	Only use methods that are explicitly described in the provided context or documentation.
	•	If unsure whether a method exists, do not invent one.
	•	If no valid method is known, respond with:
“I cannot complete this without more information about the available methods.”


In Pharo, method names follow three distinct syntactic forms:
	1.	Unary methods – no arguments:
Example:

clock reset

Here, reset is a unary method.

	2.	Binary methods – typically symbolic, take one argument:
Example:

3 + 4

Here, + is a binary method. Other examples include &, =, or @.

	3.	Keyword methods – take one or more arguments, each labeled:
Example:

painter mix: red with: blue

Here, the full method name is mix:with: and it takes two arguments.

Notes:
	•	Method names in keyword form always end in colons.
	•	Method lookup uses the full name including colons.
	•	Special characters like + or & are valid binary selectors.'
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> hist2WhereToPlaceTestMethod [
	chatBuilder user: 
('I want to write a test method for {1} in class {2}. 
In what test class do I place it, and what do I name the test method'
format: {self sourceMethodStringName . self sourceClassStringName }).
	chatBuilder assistant: ('There is an existing test class named {1} which is to be used. 
The name of the test method is {2}'
		format: {self sourceClassStringName , 'AITest'. self testMethodName }), String cr, 
('In addition, the superclass {1} of {2} has an instance variable {3} that is set up to an instance of {4}, 
so you should not declare a local variable in the test method, but use {3}' 
			format:{self sourceClassStringName,'Test'. 
			self sourceClassStringName,'AITest'. 
			self sourceClassFirstInstanceVariable.
			self sourceClassStringName. }).
	
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> hist3WhatIsTheBasics [
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test method is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> hist50WhatIsTheBasics [
	chatBuilder user: ('For making a test for method {1} in class {2}, what does {1} return'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	chatBuilder assistant: ('In general, if there is no "^" syntax, the method return the object of the method. If there is a "^" the method returns the result of the expression after "^". In your case, if there is no "^", the return of {1} is an instance of {2}, otherwise you need to examine the expression after "^"'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> hist51WhatIsTheBasics [
	chatBuilder user: 'Is this Pharo object {''aaa'' -> 77. ''bbb''->88 } an array or a dictionary'.
	chatBuilder assistant: 'The syntax {...} is always an array, not a dictionary. And ''aaa'' -> 77 is an association object. So {''aaa'' -> 77. ''bbb''->88 } is an array of associations.'.
	chatBuilder user: 'How do I convert an array of associations to an ordered dictionary, how do I do that'.
	chatBuilder assistant: 
	'If you have an arrays of associtions you can convert it to an ordered dictionary symply by sending it the method asOrderedDictionary. And if you do not know if it is already an ordered dictionary, the function asOrderedDictionary works also for something which is already an ordered dictionary'.
	
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> hist90WhatIsTheBasics [
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> hist92WhatIsTheBasics [
    chatBuilder user: 'Are there any rules for local variables'.
    chatBuilder assistant: 'In Pharo, all local variables (| ... |) must be declared in a single block at the top of the method. The variable declaration | pathDistance | is placed in the middle of the code, which is a syntax error that will stop the compiler.'.
]

{ #category : 'accessing' }
AIAMistralTestGenerator >> history [
	| historyText |
	historyText := WriteStream on: ''.
	chatBuilder history allButFirst do: [ :item | 
		historyText << '## ' << item key << String cr
			<< item value << String cr << String cr
		 ].
	^ historyText contents
]

{ #category : 'initialization' }
AIAMistralTestGenerator >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	chatBuilder := AIACommentBuilding ailienApi new.
	
]

{ #category : 'instance creation' }
AIAMistralTestGenerator >> new_generateTest [
	self hist2WhereToPlaceTestMethod.
	self hist50WhatIsTheBasics.
	self promptGenerator.
	chatBuilder getResponse.
	testMethod := self cleanAIResponse: chatBuilder response .
	(chatBuilder response = 'Data receive timed out.') ifTrue: [
		chatBuilder response: ''.
		self systemGeneratorClasses.
		chatBuilder getResponse.
		testMethod := chatBuilder response .
		 ]
]

{ #category : 'instance creation' }
AIAMistralTestGenerator >> old_generateTest [
	self systemGenerator.
	self hist92WhatIsTheBasics.
	self hist1GeneratorMethods.
	self hist2WhereToPlaceTestMethod.
	self hist3WhatIsTheBasics.
	self hist50WhatIsTheBasics.
	self hist51WhatIsTheBasics.
	self hist90WhatIsTheBasics.
	self promptGenerator.
	chatBuilder getResponse.
	testMethod := self cleanAIResponse: chatBuilder response .
	(chatBuilder response = 'Data receive timed out.') ifTrue: [
		chatBuilder response: ''.
		self systemGeneratorClasses.
		chatBuilder getResponse.
		testMethod := chatBuilder response .
		 ]
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> old_systemGenerator [
	chatBuilder system: 
		'All background code and documentation is written in Markdown.
		This includes Pharo packages, classes, and methods.', String cr, 
	(AIASourceCodeBuilder new for: { 
		sourceMethod methodClass class packageName asString. 
		sourceMethod methodClass packageName asString , '-Tests' }).
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> promptGenerator [
	| methodName |
	methodName := sourceMethod name .
	chatBuilder user: ('You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Do not declare local variables that are already provided as instance variables. 
Insert comments in the test method you create.
Just return the test method. Do not explain.
Please build a test case for method "{1}".
The test method might replace an existing test method. It will be placed in 
{2}.
' 
	format: { sourceMethod name .  
				sourceMethod methodClass definitionString. }).
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> repairResponseMethod [
	| repaired testMethodName |
	"should update the method generated method name so first, and those after : is kapital letter"
	testMethodName := 'test', 
		((self sourceMethodStringName keywords collect: [:kw | 
			(kw copyReplaceAll: ':' with: '') capitalized]) 
		joinUsing: '').
	repaired := testMethod copyReplaceAll: Character lf asString with: Character cr asString.
	(repaired lines first beginsWith: '```')
		ifTrue: [ repaired := repaired lines allButFirst allButLast joinUsing: String cr ].
	repaired := String cr join: repaired lines allButFirst . 
	repaired := String cr join:  { testMethodName. repaired }.
	^ repaired 
]

{ #category : 'accessing' }
AIAMistralTestGenerator >> sourceClassFirstInstanceVariable [
	| testClassVariables |
	"(Smalltalk at: (self sourceClassStringName,'Test') asSymbol) instanceVariables first name."
	testClassVariables := (Smalltalk at: (self sourceClassStringName,'Test') asSymbol) instanceVariables.
	testClassVariables size = 0 
		ifTrue: [ ^ '' ]
		ifFalse: [^ testClassVariables first name.]
]

{ #category : 'accessing' }
AIAMistralTestGenerator >> sourceClassStringName [
	^ sourceMethod  methodClass asString
]

{ #category : 'accessing' }
AIAMistralTestGenerator >> sourceMethod [

	^ sourceMethod
]

{ #category : 'accessing' }
AIAMistralTestGenerator >> sourceMethod: anObject [

	sourceMethod := anObject
]

{ #category : 'accessing' }
AIAMistralTestGenerator >> sourceMethodStringName [
	^ sourceMethod selector asString
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> systemGenerator [
	chatBuilder system: 
		'All background code and documentation is written in Markdown.
		This includes Pharo packages, classes, and methods.', String cr, 
	(AIASourceCodeBuilder new for: { 
		sourceMethod methodClass class packageName asString. 
		sourceMethod methodClass packageName asString , '-Tests' }).
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> systemGeneratorClasses [
	"Only called in timeout"
	self system: (AIASourceCodeBuilder new forClasses: { 
		sourceMethod methodClass class. 
		Smalltalk globals at: (AIAMethodComment name asString , 'Test') asSymbol  }).
]

{ #category : 'accessing' }
AIAMistralTestGenerator >> testMethod [

	^ testMethod
]

{ #category : 'accessing' }
AIAMistralTestGenerator >> testMethod: anObject [

	testMethod := anObject
]

{ #category : 'test builder' }
AIAMistralTestGenerator >> testMethodName [
	^ 'test', ((self sourceMethodStringName keywords collect: [:kw | 
		(kw copyReplaceAll: ':' with: '') capitalized]) joinUsing: '')
]
