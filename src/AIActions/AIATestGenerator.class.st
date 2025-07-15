"
## Class Comment for AIATestGenerator

The `AIATestGenerator` class is designed to facilitate the automated generation of test cases for methods within a Pharo system. It leverages AI to generate test methods and integrates seamlessly with the Pharo environment, providing a streamlined process for test creation and management.

### Key Features:
- **AI-Driven Test Generation**: Utilises an AI process to generate test cases based on the source method.
- **Progress Monitoring**: Displays progress and handles interruptions during the AI response retrieval process.
- **Fluid Syntax Support**: Can be used to create and manipulate classes using a fluid syntax, making it suitable for scripting and interactive use.
- **Class Comparison**: Capable of comparing old and new class configurations to determine necessary changes.
- **Extensibility**: Can be extended with different builder enhancers, such as `ShDefaultBuilderEnhancer`.

### Usage Example:

To use the `AIATestGenerator` in the Playground, follow these steps:

1. **Define a Source Method**: Create a method for which you want to generate a test case.
2. **Generate the Test**: Use the `AIATestGenerator` to generate the test method.

```smalltalk
| sourceMethod testGenerator testMethod |

""Define a source method""
sourceMethod := Object >> #exampleMethod.

""Create an instance of AIATestGenerator""
testGenerator := AIATestGenerator for: sourceMethod.

""Generate the test method""
testMethod := testGenerator generateTest.

""Inspect the generated test method""
testMethod
```

### Design Decisions:
- **Scripting and Interactivity**: The class builder should support scripting and return a class builder that can be inspected.
- **Build and Install**: The class builder offers `build` and `install` methods to create and install classes, respectively.
- **Class Information Management**: The `fillFromClass:` method converts class information into a format expected by the class builder.
- **API Alignment**: Future revisions aim to align the class builder API with default class values and reduce unnecessary conversions.

By following these guidelines, `AIATestGenerator` provides a robust and flexible solution for automated test case generation in Pharo.
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
	The test method will be places in 
TestCase << #{2}Test
	slots: \{ #log . #logBuilder };
	tag: ''Log'';
	package: ''{2}-Tests''
You must only use code that you know is existing in Pharo, never use figurative code.
The setUp method of any test methos is called before the test is executed.
Just return the test method. Do not explain.' 
	format: { sourceMethod name .  sourceMethod methodClass name. self promptGeneratorMethods }).
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
AIATestGenerator >> systemGenerator [
	self system: (AIASourceCodeBuilder new for: { 
		sourceMethod methodClass class packageName asString. 
		sourceMethod methodClass packageName asString , '-Tests' }).
]

{ #category : 'as yet unclassified' }
AIATestGenerator >> systemGeneratorClasses [
	self system: (AIASourceCodeBuilder new forClasses: { 
		sourceMethod methodClass class. 
		Smalltalk globals at: (AIAMethodComment name asString , 'Test') asSymbol  }).
]
