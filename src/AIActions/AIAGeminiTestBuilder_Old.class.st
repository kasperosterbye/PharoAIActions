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
	#name : 'AIAGeminiTestBuilder_Old',
	#superclass : 'AIATestBuilder',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'instance creation' }
AIAGeminiTestBuilder_Old class >> buildAll: aClass [
	"Generates test methods for all methods in a class using AIAGeminiTestGenerator"
	aClass methodDict values do: [ :method |
		self new build: method.
	 ]
]

{ #category : 'test builder' }
AIAGeminiTestBuilder_Old >> hist1GeneratorMethods [
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
AIAGeminiTestBuilder_Old >> hist2WhereToPlaceTestMethod [
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
AIAGeminiTestBuilder_Old >> hist3WhatIsTheBasics [
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test method is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'test builder' }
AIAGeminiTestBuilder_Old >> hist50WhatIsTheBasics [
	chatBuilder user: ('For making a test for method {1} in class {2}, what does {1} return'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	chatBuilder assistant: ('In general, if there is no "^" syntax, the method return the object of the method. If there is a "^" the method returns the result of the expression after "^". In your case, if there is no "^", the return of {1} is an instance of {2}, otherwise you need to examine the expression after "^"'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	
]

{ #category : 'test builder' }
AIAGeminiTestBuilder_Old >> hist51WhatIsTheBasics [
	chatBuilder user: 'Is this Pharo object {''aaa'' -> 77. ''bbb''->88 } an array or a dictionary'.
	chatBuilder assistant: 'The syntax {...} is always an array, not a dictionary. And ''aaa'' -> 77 is an association object. So {''aaa'' -> 77. ''bbb''->88 } is an array of associations.'.
	chatBuilder user: 'How do I convert an array of associations to an ordered dictionary, how do I do that'.
	chatBuilder assistant: 
	'If you have an arrays of associtions you can convert it to an ordered dictionary symply by sending it the method asOrderedDictionary. And if you do not know if it is already an ordered dictionary, the function asOrderedDictionary works also for something which is already an ordered dictionary'.
	
]

{ #category : 'test builder' }
AIAGeminiTestBuilder_Old >> hist60ArrangeMethod [
	chatBuilder user: 'When writing a test, you need to set up the data that the method depends on. This is called the "Arrange" part of the test.
If the method you are testing depends on a collection (like a dictionary), you need to make sure the collection contains the data needed for the test to pass.'.
	chatBuilder assistant: 'Yes, I understand. I will add the necessary data to the collection in the "Arrange" part of the test to prevent the test from failing due to missing data.'
]

{ #category : 'test builder' }
AIAGeminiTestBuilder_Old >> hist61ArrangeMethod [
	chatBuilder user: 'Are there some special rules I need to be aware of regarding the data used in a test'.
	chatBuilder assistant: 'When writing a test, you need to set up the data that the method depends on. This is called the "Arrange" part of the test.
If the method you are testing depends on a collection (like a dictionary), you need to make sure the collection contains the data needed for the test to pass.'
]

{ #category : 'instance creation' }
AIAGeminiTestBuilder_Old >> hist62ArrangeMethod [
	chatBuilder user: 'When writing a test, you need to set up the data that the method depends on. This is called the "Arrange" part of the test.
If the method you are testing depends on a collection (like a dictionary), you need to make sure the collection contains the data needed for the test to pass.'.
	chatBuilder assistant: 'Yes, I understand. I will add the necessary data to the collection in the "Arrange" part of the test to prevent the test from failing due to missing data.'
]

{ #category : 'instance creation' }
AIAGeminiTestBuilder_Old >> hist63CorrectNodeSetup [
	chatBuilder user: 'When adding nodes to the graph, you must use the public method, for example, "addNode: anObject". Do not access the internal instance variables like "nodeDictionary" directly.'.
	chatBuilder assistant: 'Yes, I understand. I will use the public methods, such as `addNode:`, to add nodes to the graph in the Arrange section of the test.'
]

{ #category : 'test builder' }
AIAGeminiTestBuilder_Old >> hist90WhatIsTheBasics [
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'test builder' }
AIAGeminiTestBuilder_Old >> hist92WhatIsTheBasics [
	"Records a user query about local variable rules and the AI's response regarding variable declaration placement in Pharo."
    chatBuilder user: 'Are there any rules for local variables'.
    chatBuilder assistant: 'In Pharo, all local variables (| ... |) must be declared in a single block at the top of the method. The variable declaration | pathDistance | is placed in the middle of the code, which is a syntax error that will stop the compiler.'.
]

{ #category : 'instance creation' }
AIAGeminiTestBuilder_Old >> historyBuilder [
	
	self hist92WhatIsTheBasics.
	self hist1GeneratorMethods.
	self hist2WhereToPlaceTestMethod.
	self hist50WhatIsTheBasics.
	self hist51WhatIsTheBasics.
	self hist60ArrangeMethod.
	self hist62ArrangeMethod.
	self hist63CorrectNodeSetup.
	self hist90WhatIsTheBasics.
]

{ #category : 'initialization' }
AIAGeminiTestBuilder_Old >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	"
	AIACommentBuilding ailienApi: GeminiApi.
	chatBuilder := AIACommentBuilding ailienApi new.
"
	
]
