"
# Class Comment for AIAMistralTestGenerator

The `AIAMistralTestGenerator` class is a specialized test generator that leverages AI (specifically the Mistral model) to automatically create test methods for existing Pharo methods. It integrates with the AI comment building system to generate comprehensive test cases that verify the functionality of source methods.

## Key Features

- **AI-Powered Test Generation**: Uses Mistral AI to analyze source methods and generate appropriate test cases
- **Context-Aware Generation**: Incorporates system context including packages, classes, and methods to ensure accurate test generation
- **Error Handling**: Includes mechanisms to handle and repair test methods that contain errors
- **Test Class Management**: Automatically creates or identifies appropriate test classes for generated tests
- **History Tracking**: Maintains a history of AI interactions for debugging and improvement purposes

## Usage Example

```st
""Example usage in the Playground""
| generator testMethod |

""Create a generator for a specific method""
generator := AIAMistralTestGenerator new build: (Point >> #x).

""Inspect the generated test method""
testMethod := generator testMethod.

""Inspect the complete interaction history""
generator history
```

## Design Decisions

1. **Fluid API**: Follows Pharo's fluid syntax for easy chaining of operations
2. **Separation of Concerns**: Distinguishes between test generation and compilation
3. **Error Resilience**: Includes mechanisms to handle and repair AI-generated test methods
4. **Context Awareness**: Incorporates system context to ensure accurate test generation
5. **History Tracking**: Maintains interaction history for debugging and improvement

## Implementation Notes

- The generator uses a combination of system context and specific prompts to produce clean test code
- It handles timeouts by falling back to simplified system context
- The generated test methods follow Pharo naming conventions and proper formatting
- The class maintains a history of all AI interactions for debugging purposes

## Future Improvements

- Integration with more advanced AI models for better test generation
- Enhanced error handling and repair mechanisms
- Support for more complex test scenarios and edge cases
- Improved integration with Pharo's testing framework

This class is particularly useful for developers who want to quickly generate test cases for existing methods without manually writing each test, while maintaining high quality and coverage standards.
"
Class {
	#name : 'AIAMistralTestBuilder',
	#superclass : 'AIATestBuilder',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'instance creation' }
AIAMistralTestBuilder class >> buildAll: aClass [
	"Builds test methods for all methods in a class using Mistral AI"
	aClass methodDict values do: [ :method |
		self new build: method.
	 ]
]

{ #category : 'test builder' }
AIAMistralTestBuilder >> hist1GeneratorMethods [
	"The hist1GeneratorMethods method provides context about Pharo method types unary binary and keyword to ensure accurate test generation."
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
AIAMistralTestBuilder >> hist2WhereToPlaceTestMethod [
	"The hist2WhereToPlaceTestMethod method provides context about test class placement and naming rules for AI generated test methods."
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
AIAMistralTestBuilder >> hist3WhatIsTheBasics [
	"The hist3WhatIsTheBasics method provides context about building test methods in Pharo including rules for using existing code and handling instance variables."
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test method is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'test builder' }
AIAMistralTestBuilder >> hist50WhatIsTheBasics [
	"The hist50WhatIsTheBasics method provides context about method return values in Pharo, explaining the difference between implicit and explicit returns using the caret symbol."
	chatBuilder user: ('For making a test for method {1} in class {2}, what does {1} return'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	chatBuilder assistant: ('In general, if there is no "^" syntax, the method return the object of the method. If there is a "^" the method returns the result of the expression after "^". In your case, if there is no "^", the return of {1} is an instance of {2}, otherwise you need to examine the expression after "^"'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	
]

{ #category : 'test builder' }
AIAMistralTestBuilder >> hist51WhatIsTheBasics [
	"The hist51WhatIsTheBasics method provides context about converting arrays of associations to ordered dictionaries in Pharo, explaining the asOrderedDictionary method."
	chatBuilder user: 'Is this Pharo object {''aaa'' -> 77. ''bbb''->88 } an array or a dictionary'.
	chatBuilder assistant: 'The syntax {...} is always an array, not a dictionary. And ''aaa'' -> 77 is an association object. So {''aaa'' -> 77. ''bbb''->88 } is an array of associations.'.
	chatBuilder user: 'How do I convert an array of associations to an ordered dictionary, how do I do that'.
	chatBuilder assistant: 
	'If you have an arrays of associtions you can convert it to an ordered dictionary symply by sending it the method asOrderedDictionary. And if you do not know if it is already an ordered dictionary, the function asOrderedDictionary works also for something which is already an ordered dictionary'.
	
]

{ #category : 'test builder' }
AIAMistralTestBuilder >> hist60ArrangeMethod [
	chatBuilder user: 'When writing a test, you need to set up the data that the method depends on. This is called the "Arrange" part of the test.
If the method you are testing depends on a collection (like a dictionary), you need to make sure the collection contains the data needed for the test to pass.'.
	chatBuilder assistant: 'Yes, I understand. I will add the necessary data to the collection in the "Arrange" part of the test to prevent the test from failing due to missing data.'
]

{ #category : 'test builder' }
AIAMistralTestBuilder >> hist61ArrangeMethod [
	chatBuilder user: 'Are there some special rules I need to be aware of regarding the data used in a test'.
	chatBuilder assistant: 'When writing a test, you need to set up the data that the method depends on. This is called the "Arrange" part of the test.
If the method you are testing depends on a collection (like a dictionary), you need to make sure the collection contains the data needed for the test to pass.'
]

{ #category : 'test builder' }
AIAMistralTestBuilder >> hist62ArrangeMethod [
	chatBuilder user: 'When writing a test, you need to set up the data that the method depends on. This is called the "Arrange" part of the test.
If the method you are testing depends on a collection (like a dictionary), you need to make sure the collection contains the data needed for the test to pass.'.
	chatBuilder assistant: 'Yes, I understand. I will add the necessary data to the collection in the "Arrange" part of the test to prevent the test from failing due to missing data.'
]

{ #category : 'test builder' }
AIAMistralTestBuilder >> hist63CorrectNodeSetup [
	chatBuilder user: 'When adding nodes to the graph, you must use the public method, for example, "addNode: anObject". Do not access the internal instance variables like "nodeDictionary" directly.'.
	chatBuilder assistant: 'Yes, I understand. I will use the public methods, such as `addNode:`, to add nodes to the graph in the Arrange section of the test.'
]

{ #category : 'test builder' }
AIAMistralTestBuilder >> hist70ReferenceToOrigin [
	chatBuilder user: 'A test method often need a reference to the original. How do I find the original class?'.
	chatBuilder assistant: ('You need to use the local variable of the test class {1}, which in this class is ref{1}. ' format: { self sourceClassStringName})
]

{ #category : 'test builder' }
AIAMistralTestBuilder >> hist90WhatIsTheBasics [
	"The hist90WhatIsTheBasics method provides context about building test methods in Pharo including rules for using existing code and handling instance variables."
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'test builder' }
AIAMistralTestBuilder >> hist92WhatIsTheBasics [
	"The hist92WhatIsTheBasics method provides context about local variable rules in Pharo methods ensuring proper syntax and declaration."
    chatBuilder user: 'Are there any rules for local variables'.
    chatBuilder assistant: 'In Pharo, all local variables (| ... |) must be declared in a single block at the top of the method. The variable declaration | pathDistance | is placed in the middle of the code, which is a syntax error that will stop the compiler.'.
]

{ #category : 'instance creation' }
AIAMistralTestBuilder >> historyBuilder [

	self hist92WhatIsTheBasics.
	self hist1GeneratorMethods.
	self hist2WhereToPlaceTestMethod.
	self hist3WhatIsTheBasics.
	self hist50WhatIsTheBasics.
	self hist51WhatIsTheBasics.
	self hist60ArrangeMethod.
	self hist62ArrangeMethod.
	self hist63CorrectNodeSetup.
	self hist70ReferenceToOrigin.
	self hist90WhatIsTheBasics.
	
]

{ #category : 'initialization' }
AIAMistralTestBuilder >> initialize [ 
	super initialize.
	
]
