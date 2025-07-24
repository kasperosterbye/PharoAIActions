"
## Class Comment for AIATestGenerator

"
Class {
	#name : 'AIATestGenerator',
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
AIATestGenerator class >> buildAll: aClass [
	aClass methodDict values do: [ :method |
		self new build: method
	 ]
]

{ #category : 'instance creation' }
AIATestGenerator >> build: aMethod [
	| aiTestClass |
	aiTestClass := self buildTestForMethod: aMethod.
	self for: aMethod.
	testMethod := self repairResponseMethod.
	[aiTestClass compile: testMethod classified: 'AI generated test']
		on: Error
		do: [ ].
]

{ #category : 'test builder' }
AIATestGenerator >> buildTestForMethod: method [
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
AIATestGenerator >> chatBuilder [

	^ chatBuilder
]

{ #category : 'instance creation' }
AIATestGenerator >> for: aMethod [
	"aMethod is the compiled method to which a test should be renerated."
	sourceMethod := aMethod.
	"testClass := sourceMethod methodClass packageName asString , '-Tests'."
	self generateTest.
	
	^ testMethod 
]

{ #category : 'instance creation' }
AIATestGenerator >> generateTest [
	self systemGenerator.
	self hist1GeneratorMethods.
	self hist2WhereToPlaceTestMethod.
	self hist3WhatIsTheBasics.
	self promptGenerator.
	chatBuilder jsonHistory .
	testMethod := chatBuilder response .
	(chatBuilder response = 'Data receive timed out.') ifTrue: [
		chatBuilder response: ''.
		self systemGeneratorClasses.
		chatBuilder getResponse.
		testMethod := chatBuilder response .
		 ]
]

{ #category : 'instance creation' }
AIATestGenerator >> generateTest_old [
	self systemGenerator.
	chatBuilder user: 'What are the important rules for me to follow when making pharo methods'.
	chatBuilder assistant: self aideGeneratorMethods.
	"chatBuilder user: 'What should I know about test method writing'.
	chatBuilder assistant: self promptGeneratorMethods."
	chatBuilder user: 'What are the main issues when I want to build a test method'.
	chatBuilder assistant: self aideBuildingTests.
	chatBuilder user: ('In Pharo, when I class {1}, what is its test class named' 
			format: {self sourceClassStringName}).
	chatBuilder assistant: ('For class {1} its test class is named {1}Test' 
			format: {self sourceClassStringName}).
	chatBuilder user: ('I want to write a test method for method {1} in class {2}. How do I do it' 
			format: {self sourceMethodStringName . self sourceClassStringName }).
	chatBuilder assistant: self aideInstanceVariables.
	chatBuilder user: self promptGenerator. 
	chatBuilder getResponse.
	testMethod := chatBuilder response .
	(chatBuilder response = 'Data receive timed out.') ifTrue: [
		chatBuilder response: ''.
		self systemGeneratorClasses.
		chatBuilder getResponse.
		testMethod := chatBuilder response .
		 ]
]

{ #category : 'test builder' }
AIATestGenerator >> hist1GeneratorMethods [
	chatBuilder user: 'I have heard that Pharo have different types of methods, what are they'.
	chatBuilder assistant:'
Important Coding Rule

When writing Pharo code or tests:
	•	Only use methods that are explicitly described in the provided context or documentation.
	•	If unsure whether a method exists, do not invent one.
	•	If no valid method is known, respond with:
“I cannot complete this without more information about the available methods.”


In Pharo  method names follow three distinct syntactic forms:
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
AIATestGenerator >> hist2WhereToPlaceTestMethod [
	chatBuilder user: 
		('I want to write a test method for {1} in class {2}. 
		In what test class do I place it, and what do I name the test method'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	chatBuilder assistant: ('There is an existing test class named {1} which is to be used. 
		The name of the test method is {2}'
		format: {self sourceClassStringName , 'AITest'. self testMethodName })
	
]

{ #category : 'test builder' }
AIATestGenerator >> hist3WhatIsTheBasics [
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'initialization' }
AIATestGenerator >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	chatBuilder := AIAChatBuilding new.
	
]

{ #category : 'test builder' }
AIATestGenerator >> promptGenerator [
	| methodName |
	methodName := sourceMethod name .
	chatBuilder user: ('Please build a test case for method "{1}".
	{3}.
	The test method might replace an existing test method. It will be places in 
{2}.
You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Do not redeclare variables like dinic that are already provided as instance variables. 
Insert comments in the test method you create.
Just return the test method. Do not explain.' 
	format: { sourceMethod name .  
				sourceMethod methodClass definitionString. 
				self hist2WhereToPlaceTestMethod }).
]

{ #category : 'test builder' }
AIATestGenerator >> promptGenerator_new [
	| prompt |
	prompt := 'Please build a test method for method "{1}" in class {2}.
The by you generated test code must follow the principles you mention to me earlier.
Insert comments in the test method you create.
Just return the test method. Do not explain.' 
	format: { self sourceMethodStringName . self sourceClassStringName }.
	self halt.
	chatBuilder user: prompt.
]

{ #category : 'test builder' }
AIATestGenerator >> promptGenerator_old [
	| methodName |
	methodName := sourceMethod name .
	chatBuilder prompt: ('Please build a test case for method "{1}".
	{3}.
	The test method might replace an existing test method. It will be places in 
{2}.
You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Do not redeclare variables like dinic that are already provided as instance variables. 
Insert comments in the test method you create.
Just return the test method. Do not explain.' 
	format: { sourceMethod name .  
				sourceMethod methodClass definitionString. 
				self promptGeneratorMethods }).
]

{ #category : 'test builder' }
AIATestGenerator >> repairResponseMethod [
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
AIATestGenerator >> sourceClassStringName [
	^ sourceMethod  methodClass asString
]

{ #category : 'accessing' }
AIATestGenerator >> sourceMethod [

	^ sourceMethod
]

{ #category : 'accessing' }
AIATestGenerator >> sourceMethod: anObject [

	sourceMethod := anObject
]

{ #category : 'accessing' }
AIATestGenerator >> sourceMethodStringName [
	^ sourceMethod selector asString
]

{ #category : 'test builder' }
AIATestGenerator >> systemGenerator [
	chatBuilder system: 
		'All background code and documentation is written in Markdown.
		This includes Pharo packages, classes, and methods.', String cr, 
	(AIASourceCodeBuilder new for: { 
		sourceMethod methodClass class packageName asString. 
		sourceMethod methodClass packageName asString , '-Tests' }).
]

{ #category : 'test builder' }
AIATestGenerator >> systemGeneratorClasses [
	"Only called in timeout"
	self system: (AIASourceCodeBuilder new forClasses: { 
		sourceMethod methodClass class. 
		Smalltalk globals at: (AIAMethodComment name asString , 'Test') asSymbol  }).
]

{ #category : 'accessing' }
AIATestGenerator >> testMethod [

	^ testMethod
]

{ #category : 'accessing' }
AIATestGenerator >> testMethod: anObject [

	testMethod := anObject
]

{ #category : 'test builder' }
AIATestGenerator >> testMethodName [
	^ 'test', ((self sourceMethodStringName keywords collect: [:kw | 
		(kw copyReplaceAll: ':' with: '') capitalized]) joinUsing: '')
]
