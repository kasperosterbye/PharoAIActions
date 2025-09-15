"
# AIAGeminiTestBuilder

A specialized test builder that generates AI-powered unit tests for Pharo methods using the Gemini AI model. This builder automates test creation by analyzing method behavior and generating appropriate test cases.

## Key Features

- Generates complete test methods for any Pharo method
- Handles different method types (unary, binary, keyword)
- Follows Pharo testing conventions and best practices
- Provides context about method behavior and expected results
- Maintains proper test class structure and naming conventions

## Usage Example

```smalltalk
""Example: Generate a test for a method in the system""
| builder testClass |
builder := AIAGeminiTestBuilder new.
builder for: (Point >> #x).  ""The method to test""
builder build.  ""Generate the test method""
testClass := builder sourceClassStringName, 'AITest' asClass.
testClass debug: builder testMethodName.  ""Inspect the generated test""
```

## Design Notes

1. Works with the existing AI builder infrastructure
2. Maintains proper test class structure and naming
3. Follows Pharo testing conventions (setUp, test methods)
4. Handles different method types appropriately
5. Provides context about method behavior to the AI

## Implementation Notes

- Uses the Gemini AI model for test generation
- Maintains proper test class structure
- Follows Pharo testing conventions
- Handles different method types appropriately
- Provides context about method behavior to the AI

This builder is part of the AI-powered testing framework in Pharo, enabling automated test generation for existing methods.
```

The example shows how to:
1. Create a new test builder instance
2. Specify the method to test
3. Generate the test method
4. Access the generated test class and method

The builder will automatically:
- Create or find the appropriate test class
- Generate a properly named test method
- Include all necessary setup and assertions
- Handle different method types appropriately
"
Class {
	#name : 'AIAGeminiTestBuilder',
	#superclass : 'AIATestBuilder',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist1GeneratorMethods [
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
AIAGeminiTestBuilder >> hist2WhereToPlaceTestMethod [
	"The hist2WhereToPlaceTestMethod method provides context about test class placement and naming rules for AI generated test methods."
	chatBuilder user: 
('I want to write a test method for `{1}` in class `{2}`. 
In what test class do I place it, and what do I name the test method'
format: {self sourceMethodStringName . self sourceClassStringName }).
	chatBuilder assistant: ('There is an existing test class named `{1}` which is to be used. 
The name of the test method is `{2}`'
		format: {self sourceClassStringName , 'AITest'. self testMethodName }), String cr, 
('In the setUp method of `{1}`, the instance variable `{2}` is initialized to an instance of `{3}`,', 
'so you should not declare a local variable in the test method, but use `{2}` ' 
			format:{
			self sourceClassStringName,'AITest'. 
			self sourceClassFirstInstanceVariable.
			self sourceClassStringName. }).
	
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist3WhatIsTheBasics [
	"The hist3WhatIsTheBasics method provides context about building test methods in Pharo including rules for using existing code and handling instance variables."
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test method is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist50WhatIsTheBasics [
	"The hist50WhatIsTheBasics method provides context about method return values in Pharo, explaining the difference between implicit and explicit returns using the caret symbol."
	chatBuilder user: ('For making a test for method {1} in class {2}, what does {1} return'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	chatBuilder assistant: ( 'In Pharo, if a method does not contain the `^` symbol, it implicitly returns the receiver (self), which in this case is an instance of FuzzyMatcher.
If the method includes a `^`, it returns the value of the expression following that symbol.
So for `{1}`, if there is no caret, it returns the `{2}` instance; if there is one, you’ll need to check what expression follows it.'
			format: {self sourceMethodStringName . self sourceClassStringName }).
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist51WhatIsTheBasics [
	"The hist51WhatIsTheBasics method provides context about converting arrays of associations to ordered dictionaries in Pharo, explaining the asOrderedDictionary method."
	chatBuilder user: 'Is this Pharo object {''aaa'' -> 77. ''bbb'' -> 88 } an array or a dictionary?'.
	chatBuilder assistant: 'The syntax `{...}` always creates an Array in Pharo. Each `''aaa'' -> 77` is an Association, so the result is an Array of Associations.'.
	chatBuilder user: 'How do I convert an array of associations to an ordered dictionary?'.
	chatBuilder assistant: 
'Send `asOrderedDictionary` to the array. It converts arrays of associations into an `OrderedDictionary`.  
For example: `{''a'' -> 1. ''b'' -> 2} asOrderedDictionary` gives an `OrderedDictionary` with keys ''a'' and ''b''.  
If the object is already an `OrderedDictionary`, calling `asOrderedDictionary` again has no effect.'.
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist60ArrangeMethod [
	"The hist60ArrangeMethod method explains the Arrange step of test writing in Pharo, focusing on preparing data dependencies."
	^ self.
	chatBuilder user: 'In Pharo, what does the "Arrange" step mean when writing a test method?'.
	chatBuilder assistant: 'The "Arrange" step is where you prepare any data the method depends on. 
This includes setting up objects, collections, or any other context needed before executing the method under test.'.

	chatBuilder user: 'What if the method depends on a dictionary or other collection?'.
	chatBuilder assistant: 'You should ensure the collection contains the exact data needed for the test to run correctly. 
Missing or incorrect setup can cause the test to fail even if the method itself works properly.'.
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist61ArrangeMethod [
	^ self.
	chatBuilder user: 'Are there some special rules I need to be aware of regarding the data used in a test'.
	chatBuilder assistant: 'When writing a test, you need to set up the data that the method depends on. This is called the "Arrange" part of the test.
If the method you are testing depends on a collection (like a dictionary), you need to make sure the collection contains the data needed for the test to pass.'
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist62ArrangeMethod [
	^ self.
	chatBuilder user: 'When writing a test, are there specific steps for setting up the data the method depends on?'.
	chatBuilder assistant: 'Yes. This step is called the "Arrange" part of the test. 
If the method depends on a collection (like a dictionary), you need to ensure it contains the necessary data for the test to succeed.'.
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist63CorrectNodeSetup [
	^ self.
	chatBuilder user: 'When adding nodes to the graph, you must use the public method, for example, "addNode: anObject". Do not access the internal instance variables like "nodeDictionary" directly.'.
	chatBuilder assistant: 'Yes, I understand. I will use the public methods, such as `addNode:`, to add nodes to the graph in the Arrange section of the test.'
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist70ReferenceToOrigin [
	^ self.
	chatBuilder user: 'A test method often need a reference to the original. How do I find the original class?'.
	chatBuilder assistant: ('You need to use the local variable of the test class {1}, which in this class is ref{1}. ' format: { self sourceClassStringName})
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist80VariableAssignment [
	^ self.
	chatBuilder user: 'Can I assign a value to the result of a method call in Pharo?'.
	chatBuilder assistant: 'No. In Pharo, you can only use `:=` to assign values to variables. A method call returns a value, but not a reference you can assign into. For example, writing `foo bar := 42` is invalid, because foo bar is an expression, not a variable.

If bar is meant to be a setter, you must call a method like `foo bar: 42`, and that requires the method `bar:` to be defined'
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist90WhatIsTheBasics [
	"The hist90WhatIsTheBasics method provides context about building test methods in Pharo including rules for using existing code and handling instance variables."
	chatBuilder user: 'What are the basics of building a test method, any rules for that'.
	chatBuilder assistant: 'You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Do not declare variables in the method that are already provided as instance variables.'
	
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist92WhatIsTheBasics [
	"The hist92WhatIsTheBasics method provides context about local variable rules in Pharo methods, ensuring proper syntax and declaration."
	chatBuilder user: 'Are there any rules for local variables in Pharo?'.
	chatBuilder assistant: 'Yes. In Pharo, all local variables must be declared in a single block at the top of the method using vertical bars, like `| pathDistance |`. 
Placing the declaration later in the code is a syntax error and will prevent the method from compiling.'.
]

{ #category : 'test builder' }
AIAGeminiTestBuilder >> hist93SourceMethodCommentAndCode [
	"The hist92WhatIsTheBasics method provides context about local variable rules in Pharo methods, ensuring proper syntax and declaration."
	chatBuilder user:( 'Are there anything in `{1}` I need to take into account' format: {self sourceMethodStringName}).
	chatBuilder assistant: ('You are supposed to write a test method of `{1}`, and take its comment: "{2}" into consideration.'
		format: { self sourceMethodStringName. sourceMethod comment })
]

{ #category : 'instance creation' }
AIAGeminiTestBuilder >> historyBuilder [

	self hist92WhatIsTheBasics.
	self hist80VariableAssignment.
	self hist1GeneratorMethods.
	self hist2WhereToPlaceTestMethod.
	self hist3WhatIsTheBasics.
	self hist50WhatIsTheBasics.
	self hist51WhatIsTheBasics.
	self hist70ReferenceToOrigin.
	self hist90WhatIsTheBasics.
	self hist92WhatIsTheBasics.
	self hist93SourceMethodCommentAndCode.
	
]

{ #category : 'initialization' }
AIAGeminiTestBuilder >> initialize [ 
	super initialize.
	
]
