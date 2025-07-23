"
## Class Comment for AIATestGenerator

"
Class {
	#name : 'AIATestGenerator',
	#superclass : 'AIACommentBuilding',
	#instVars : [
		'sourceMethod',
		'testMethod',
		'testClass'
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
	testMethod := self repainResponseMethod.
	[aiTestClass compile: testMethod classified: 'AI generated test']
		on: Error
		do: [ ].
]

{ #category : 'as yet unclassified' }
AIATestGenerator >> buildTestForMethod: method [
	| methodClass aiTestClass shifter|
	methodClass := method methodClass name.
	aiTestClass := (methodClass , 'AITest' ) asSymbol.
	Smalltalk globals at: (methodClass , 'Test') asSymbol 
		ifAbsent: [ self error: 'There should be a test class: ', methodClass , 'Test' ].
	^ Smalltalk globals at: aiTestClass 
	ifAbsent: [  
		shifter := ShiftClassBuilder new.
		"Object << #Foo-AITest slots: { #refToActualClassObject  }; package: 'AIATestExperiments'"
		shifter 
			superclassName: (methodClass , 'Test') asSymbol;
			name: aiTestClass;
			slots: { "method methodClass name "};
			package: 'AIATestExperiments'.
		^ shifter install .
	]
]

{ #category : 'instance creation' }
AIATestGenerator >> build_old: aMethod [
	| aiTestClass |
	aiTestClass := self buildTestForMethod: aMethod.
	self for: aMethod.
	testMethod := self repainResponseMethod.
	aiTestClass compile: testMethod classified: 'AI generated test'.
]

{ #category : 'instance creation' }
AIATestGenerator >> for: aMethod [
	"aMethod is the compiled method to which a test should be renerated."
	sourceMethod := aMethod.
	testClass := sourceMethod methodClass packageName asString , '-Tests'.
	self generateTest.
	
	^ testMethod 
]

{ #category : 'instance creation' }
AIATestGenerator >> generateTest [
	"generate a test for sourceMethod"
	self systemGenerator.
	self promptGenerator.
	self getResponse.
	testMethod := self response .
	(self response = 'Data receive timed out.') ifTrue: [
		aiaApi response: ''.
		self systemGeneratorClasses.
		self getResponse.
		testMethod := self response .
		 ]
]

{ #category : 'as yet unclassified' }
AIATestGenerator >> promptGenerator [
	self prompt: ('Please build a test case for method "{1}".
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

{ #category : 'as yet unclassified' }
AIATestGenerator >> promptGeneratorMethods [
	^'
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

{ #category : 'as yet unclassified' }
AIATestGenerator >> promptGeneratorMethods_old [
	^'
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

{ #category : 'as yet unclassified' }
AIATestGenerator >> promptGenerator_new [
	self prompt: ('Please build a test case for method "{1}".
	It will be places in {2}.
Just return the test method. Do not explain.' 
	format: { sourceMethod name .  
				sourceMethod methodClass definitionString. 
				self promptGeneratorMethods }).
]

{ #category : 'as yet unclassified' }
AIATestGenerator >> promptGenerator_old [
	self prompt: ('Please build a test case for method "{1}".
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

{ #category : 'as yet unclassified' }
AIATestGenerator >> repainResponseMethod [
	| repaired testMethodName |
	"should update the method generated method name so first, and those after : is kapital letter"
	testMethodName := 'test', (sourceMethod selector asString copyReplaceAll: ':' with: '').
	repaired := testMethod copyReplaceAll: Character lf asString with: Character cr asString.
	(repaired lines first beginsWith: '```')
		ifTrue: [ repaired := String cr join: repaired lines allButFirst allButLast ].
	repaired := String cr join: repaired lines allButFirst . 
	repaired := String cr join:  { testMethodName. repaired }.
	^ repaired 
]

{ #category : 'as yet unclassified' }
AIATestGenerator >> systemGenerator [
	self system: 
		'All background code and documentation is written in Markdown.
		This includes Pharo packages, classes, and methods.', String cr, 
	(AIASourceCodeBuilder new for: { 
		sourceMethod methodClass class packageName asString. 
		sourceMethod methodClass packageName asString , '-Tests' }).
]

{ #category : 'as yet unclassified' }
AIATestGenerator >> systemGeneratorClasses [
	self system: (AIASourceCodeBuilder new forClasses: { 
		sourceMethod methodClass class. 
		Smalltalk globals at: (AIAMethodComment name asString , 'Test') asSymbol  }).
]

{ #category : 'as yet unclassified' }
AIATestGenerator >> systemGenerator_old [
	self system: 
		'All background code and documentation is written in Markdown.
		This includes Pharo packages, classes, and methods.', String cr, 
	(AIASourceCodeBuilder new for: { 
		sourceMethod methodClass class packageName asString. 
		sourceMethod methodClass packageName asString , '-Tests' }).
]
