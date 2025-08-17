"
## Class Comment for AIAGeminiTestGenerator

The `AIAGeminiTestGenerator` class is responsible for automatically generating test methods for existing Smalltalk methods using the Gemini AI model. It leverages the `AIACommentBuilding` class to interact with the AI and constructs test methods based on the source code and documentation of the method being tested. The generated test methods are then compiled and can be used to improve the test coverage of a project.

**Usage Example:**

```smalltalk
| generator sourceMethod testMethod |

""Assume you have a method named 'add:' in a class named 'Calculator'""
sourceMethod := Calculator>>#add:.

""Create an instance of the test generator""
generator := AIAGeminiTestGenerator new.

""Generate a test method for the 'add:' method""
testMethod := generator build: sourceMethod.

""Inspect the generated test method""
testMethod inspect.

""Example of building all tests for a class""
AIAGeminiTestGenerator buildAll: Calculator.
```

**Explanation:**

1.  We retrieve a compiled method from the system.
2.  We create an instance of `AIAGeminiTestGenerator`.
3.  We call the `build:` method, passing the source method as an argument. This triggers the AI-powered test generation process.
4.  The generated test method is returned as a string and can be inspected.
5.  The `buildAll:` method can be used to generate tests for all methods in a class.

**Note:** This example assumes that the `Calculator` class and its `add:` method already exist in the system. The generated test method will need to be manually added to the appropriate test class and compiled.
```

"
Class {
	#name : 'AIAGeminiTestGenerator',
	#superclass : 'AIATestGenerator',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'instance creation' }
AIAGeminiTestGenerator class >> buildAll: aClass [
	aClass methodDict values do: [ :method |
		self new build: method.
	 ]
]

{ #category : 'instance creation' }
AIAGeminiTestGenerator >> build: aMethod [
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
AIAGeminiTestGenerator >> buildFromErrorFor: aiTestClass [
	"The method attempts to fix and compile a test method that initially failed due to errors by generating a corrected version and retrying compilation."
	| method2 |
	method2 := 'There are some errors in the method. Can you suggest one without any errors. Just return the method, no markdown, but keep line shifts' q: [ testMethod  ].
	method2 := method2 copyReplaceAll: Character lf asString with: Character cr asString.
	[aiTestClass compile: method2 classified: 'AI generated test']
		on: Error
		do: [ Error signal: 'Something went wrong'].
]

{ #category : 'test builder' }
AIAGeminiTestGenerator >> buildTestForMethod: aMethod [
    "The method creates or finds a test class for a given method, ensuring it exists in the correct package and has the necessary structure for AI-generated tests."

    | testClass superClass newTestClassName shifter instanceVarName |
    
    "Identify the name of the new test class based on the method's class."
    newTestClassName := aMethod methodClass name , 'AITest'.
    
    "The name of the instance variable to hold the reference to the test class."
    instanceVarName := 'ref', aMethod methodClass name.
    
    "Try to find an existing test class."
    testClass := Smalltalk globals at: newTestClassName asSymbol ifAbsent: [ nil ].
    
    "If the test class does not exist, create a new one."
    testClass isNil
        ifTrue: [
            "Check if a super test class exists (e.g., AIDijkstraTest)."
            superClass := Smalltalk globals at: (aMethod methodClass name , 'Test') asSymbol ifAbsent: [ TestCase ].
            
            shifter := ShiftClassBuilder new.
            shifter
                superclassName: superClass name;
                name: newTestClassName asSymbol;
                slots: { instanceVarName asSymbol };
                package: 'AIATestExperiments'.
            
            testClass := shifter install.
            
            "Compile an initialize method to set up the instance variable."
            testClass compile: ('setUp' , String cr,
                                  'super setUp.' , String cr,
                                  instanceVarName , ' := ' , aMethod methodClass name , ' new.'
                                 ) classified: 'initialization'.
        ].
    
    ^ testClass
]

{ #category : 'accessing' }
AIAGeminiTestGenerator >> chatBuilder [

	^ chatBuilder
]

{ #category : 'instance creation' }
AIAGeminiTestGenerator >> cleanAIResponse: responseText [
    | lines |
    lines := responseText lines.
    
    "Remove markdown code fences"
    (lines first beginsWith: '```') ifTrue: [
        lines := lines allButFirst allButLast
    ].
    
    ^ String cr join: lines
]

{ #category : 'instance creation' }
AIAGeminiTestGenerator >> for: aMethod [
	"aMethod is the compiled method to which a test should be renerated."
	sourceMethod := aMethod.
	"testClass := sourceMethod methodClass packageName asString , '-Tests'."
	self generateTest.
	
	^ testMethod 
]

{ #category : 'instance creation' }
AIAGeminiTestGenerator >> generateTest [
	"The generateTest method creates a test method for a given source method using AI. It builds a test class, generates the test method, and compiles it. It handles timeouts and errors during compilation."
	self systemGenerator.
	self hist92WhatIsTheBasics.
	self hist1GeneratorMethods.
	self hist2WhereToPlaceTestMethod.
	self hist50WhatIsTheBasics.
	self hist51WhatIsTheBasics.
	self hist60ArrangeMethod.
	self hist62ArrangeMethod.
	self hist63CorrectNodeSetup.
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
AIAGeminiTestGenerator >> hist1GeneratorMethods [
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
AIAGeminiTestGenerator >> hist2WhereToPlaceTestMethod [
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
AIAGeminiTestGenerator >> hist3WhatIsTheBasics [
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test method is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'test builder' }
AIAGeminiTestGenerator >> hist50WhatIsTheBasics [
	chatBuilder user: ('For making a test for method {1} in class {2}, what does {1} return'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	chatBuilder assistant: ('In general, if there is no "^" syntax, the method return the object of the method. If there is a "^" the method returns the result of the expression after "^". In your case, if there is no "^", the return of {1} is an instance of {2}, otherwise you need to examine the expression after "^"'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	
]

{ #category : 'test builder' }
AIAGeminiTestGenerator >> hist51WhatIsTheBasics [
	chatBuilder user: 'Is this Pharo object {''aaa'' -> 77. ''bbb''->88 } an array or a dictionary'.
	chatBuilder assistant: 'The syntax {...} is always an array, not a dictionary. And ''aaa'' -> 77 is an association object. So {''aaa'' -> 77. ''bbb''->88 } is an array of associations.'.
	chatBuilder user: 'How do I convert an array of associations to an ordered dictionary, how do I do that'.
	chatBuilder assistant: 
	'If you have an arrays of associtions you can convert it to an ordered dictionary symply by sending it the method asOrderedDictionary. And if you do not know if it is already an ordered dictionary, the function asOrderedDictionary works also for something which is already an ordered dictionary'.
	
]

{ #category : 'test builder' }
AIAGeminiTestGenerator >> hist60ArrangeMethod [
	chatBuilder user: 'When writing a test, you need to set up the data that the method depends on. This is called the "Arrange" part of the test.
If the method you are testing depends on a collection (like a dictionary), you need to make sure the collection contains the data needed for the test to pass.'.
	chatBuilder assistant: 'Yes, I understand. I will add the necessary data to the collection in the "Arrange" part of the test to prevent the test from failing due to missing data.'
]

{ #category : 'test builder' }
AIAGeminiTestGenerator >> hist61ArrangeMethod [
	chatBuilder user: 'Are there some special rules I need to be aware of regarding the data used in a test'.
	chatBuilder assistant: 'When writing a test, you need to set up the data that the method depends on. This is called the "Arrange" part of the test.
If the method you are testing depends on a collection (like a dictionary), you need to make sure the collection contains the data needed for the test to pass.'
]

{ #category : 'instance creation' }
AIAGeminiTestGenerator >> hist62ArrangeMethod [
	chatBuilder user: 'When writing a test, you need to set up the data that the method depends on. This is called the "Arrange" part of the test.
If the method you are testing depends on a collection (like a dictionary), you need to make sure the collection contains the data needed for the test to pass.'.
	chatBuilder assistant: 'Yes, I understand. I will add the necessary data to the collection in the "Arrange" part of the test to prevent the test from failing due to missing data.'
]

{ #category : 'instance creation' }
AIAGeminiTestGenerator >> hist63CorrectNodeSetup [
	chatBuilder user: 'When adding nodes to the graph, you must use the public method, for example, "addNode: anObject". Do not access the internal instance variables like "nodeDictionary" directly.'.
	chatBuilder assistant: 'Yes, I understand. I will use the public methods, such as `addNode:`, to add nodes to the graph in the Arrange section of the test.'
]

{ #category : 'test builder' }
AIAGeminiTestGenerator >> hist90WhatIsTheBasics [
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'test builder' }
AIAGeminiTestGenerator >> hist92WhatIsTheBasics [
	"Records a user query about local variable rules and the AI's response regarding variable declaration placement in Pharo."
    chatBuilder user: 'Are there any rules for local variables'.
    chatBuilder assistant: 'In Pharo, all local variables (| ... |) must be declared in a single block at the top of the method. The variable declaration | pathDistance | is placed in the middle of the code, which is a syntax error that will stop the compiler.'.
]

{ #category : 'accessing' }
AIAGeminiTestGenerator >> history [
	| historyText |
	historyText := WriteStream on: ''.
	chatBuilder history allButFirst do: [ :item | 
		historyText << '## ' << item key << String cr
			<< item value << String cr << String cr
		 ].
	^ historyText contents
]

{ #category : 'initialization' }
AIAGeminiTestGenerator >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	
	AIACommentBuilding ailienApi: GeminiApi.
	chatBuilder := AIACommentBuilding ailienApi new.

	
]

{ #category : 'instance creation' }
AIAGeminiTestGenerator >> old1_generateTest [
	"The generateTest method creates a test method for a given source method using AI. It builds a test class, generates the test method, and compiles it. It handles timeouts and errors during compilation."
	self systemGenerator.
	self hist92WhatIsTheBasics.
	self hist1GeneratorMethods.
	self hist2WhereToPlaceTestMethod.
	self hist50WhatIsTheBasics.
	self hist51WhatIsTheBasics.
	self hist60ArrangeMethod.
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
AIAGeminiTestGenerator >> old_buildTestForMethod: method [
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

{ #category : 'test builder' }
AIAGeminiTestGenerator >> promptGenerator [
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
AIAGeminiTestGenerator >> repairResponseMethod [
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
AIAGeminiTestGenerator >> sourceClassFirstInstanceVariable [
	| testClassVariables |
	"(Smalltalk at: (self sourceClassStringName,'Test') asSymbol) instanceVariables first name."
	testClassVariables := (Smalltalk at: (self sourceClassStringName,'Test') asSymbol) instanceVariables.
	testClassVariables size = 0 
		ifTrue: [ ^ '' ]
		ifFalse: [^ testClassVariables first name.]
]

{ #category : 'accessing' }
AIAGeminiTestGenerator >> sourceClassStringName [
	^ sourceMethod  methodClass asString
]

{ #category : 'accessing' }
AIAGeminiTestGenerator >> sourceMethod [

	^ sourceMethod
]

{ #category : 'accessing' }
AIAGeminiTestGenerator >> sourceMethod: anObject [

	sourceMethod := anObject
]

{ #category : 'accessing' }
AIAGeminiTestGenerator >> sourceMethodStringName [
	^ sourceMethod selector asString
]

{ #category : 'instance creation' }
AIAGeminiTestGenerator >> systemGenerator [
	chatBuilder user: 'All background code and documentation is written in Markdown. This includes Pharo packages, classes, and methods.

<sourceCode>
', (AIASourceCodeBuilder new for: {
		sourceMethod methodClass class packageName asString.
		sourceMethod methodClass packageName asString , '-Tests' }), '
</sourceCode>

Please write a single test method in Smalltalk, as a complete test method without any class declaration, for a given method. The test method should be placed inside a ```smalltalk block.

Can you understand the background package information and the desired output format?'.
	
	chatBuilder assistant: 'Yes, it is quite clear and written in Markdown.
The package is a collection of classes, and in particular the slots method contains the instance variables of the class.

I will write a single Smalltalk test method without any class declaration inside a ```smalltalk block.

Here is an example of the desired format:
```smalltalk
testSomeMethod
	"This is a sample test method with an assert."
	self assert: true.'
]

{ #category : 'test builder' }
AIAGeminiTestGenerator >> systemGeneratorClasses [
	"Only called in timeout"
	self system: (AIASourceCodeBuilder new forClasses: { 
		sourceMethod methodClass class. 
		Smalltalk globals at: (AIAMethodComment name asString , 'Test') asSymbol  }).
]

{ #category : 'accessing' }
AIAGeminiTestGenerator >> testMethod [

	^ testMethod
]

{ #category : 'accessing' }
AIAGeminiTestGenerator >> testMethod: anObject [

	testMethod := anObject
]

{ #category : 'test builder' }
AIAGeminiTestGenerator >> testMethodName [
	^ 'test', ((self sourceMethodStringName keywords collect: [:kw | 
		(kw copyReplaceAll: ':' with: '') capitalized]) joinUsing: '')
]
