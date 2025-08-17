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
		self new build: method.
	 ]
]

{ #category : 'instance creation' }
AIATestGenerator >> build: aMethod [
	"The build method generates a test method for a given source method using AI. It creates or finds a test class, generates the test code, and compiles it. The method handles errors and provides feedback."
	| aiTestClass |
	aiTestClass := self buildTestForMethod: aMethod.
	self for: aMethod.
	testMethod := self repairResponseMethod.
	[ aiTestClass compile: testMethod classified: 'AI generated test']
		on: Error
		do: [ self buildFromErrorFor: aiTestClass].
	^ self history
]

{ #category : 'test builder' }
AIATestGenerator >> buildFromErrorFor: aiTestClass [
	"The method attempts to fix and compile a test method that initially failed due to errors by generating a corrected version and retrying compilation."
	| method2 |
	method2 := 'There are some errors in the method. Can you suggest one without any errors. In particular, no | variable | inside the code, only at the rop. Just return the method, no markdown, but keep line shifts' q: [ testMethod  ].
	method2 := method2 copyReplaceAll: Character lf asString with: Character cr asString.
	method2 := self cleanAIResponse: method2.
	[aiTestClass compile: method2 classified: 'AI generated test']
		on: Error
		do: [ aiTestClass 
				compile: method2 sourceCode lines first, String cr, (String cr join: method2 sourceCode lines allButFirst ) asComment 
				classified: 'AI generated test'].
]

{ #category : 'test builder' }
AIATestGenerator >> buildTestForMethod: aMethod [
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
AIATestGenerator >> chatBuilder [
	"The chatBuilder method returns the AI comment building instance used to generate test methods. It initializes with a new instance of AIACommentBuilding and ailienApi."

	^ chatBuilder
]

{ #category : 'instance creation' }
AIATestGenerator >> cleanAIResponse: responseText [
	"The cleanAIResponse method removes markdown code fences from AI responses, ensuring clean test method generation. It processes the response text to extract only the relevant code."
    | lines |
    lines := responseText lines.
    
    "Remove markdown code fences"
    (lines first beginsWith: '```') ifTrue: [
        lines := lines allButFirst allButLast
    ].
	 lines := String cr join: lines.
    ^ lines
]

{ #category : 'instance creation' }
AIATestGenerator >> for: aMethod [
	"aMethod is the compiled method to which a test should be renerated."
	sourceMethod := aMethod.
	self generateTest.
	
	^ testMethod 
]

{ #category : 'instance creation' }
AIATestGenerator >> generateTest [
	"The generateTest method uses AI to create test methods for source methods by combining system context and specific prompts to produce clean test code."
	self systemGenerator.
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

{ #category : 'accessing' }
AIATestGenerator >> history [
	"The history method returns a string containing all interactions with the AI, formatted with headers and line breaks for readability. It excludes the first item in the chat history."
	| historyText |
	historyText := WriteStream on: ''.
	chatBuilder history allButFirst do: [ :item | 
		historyText << '## ' << item key << String cr
			<< item value << String cr << String cr
		 ].
	^ historyText contents
]

{ #category : 'initialization' }
AIATestGenerator >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	chatBuilder := AIACommentBuilding ailienApi new.
	
]

{ #category : 'instance creation' }
AIATestGenerator >> new_generateTest [
	"The new_generateTest method generates test methods using AI by combining system context and specific prompts to produce clean test code. It handles timeouts and cleans AI responses."
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

{ #category : 'test builder' }
AIATestGenerator >> promptGenerator [
	"The promptGenerator method creates a user prompt for AI test generation, combining method name and class definition to guide AI in generating appropriate test cases."
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
Do not use Mock tests!
' 
	format: { sourceMethod name .  
				sourceMethod methodClass definitionString. }).
]

{ #category : 'test builder' }
AIATestGenerator >> repairResponseMethod [
	"Repairs AI-generated test method by ensuring proper formatting, naming conventions, and removing markdown fences. Handles method name capitalization and line breaks for Pharo compatibility."
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
AIATestGenerator >> sourceClassFirstInstanceVariable [
	"This method returns the first instance variable of the test class associated with the source method. It handles cases where the test class has no instance variables by returning an empty string."
	| testClassVariables |
	"(Smalltalk at: (self sourceClassStringName,'Test') asSymbol) instanceVariables first name."
	testClassVariables := (Smalltalk at: (self sourceClassStringName,'AITest') asSymbol) instanceVariables.
	testClassVariables size = 0 
		ifTrue: [ ^ '' ]
		ifFalse: [^ testClassVariables first name.]
]

{ #category : 'accessing' }
AIATestGenerator >> sourceClassStringName [
	"Returns the name of the class associated with the source method as a string. Used to identify the class context for test generation."
	^ sourceMethod  methodClass asString
]

{ #category : 'accessing' }
AIATestGenerator >> sourceMethod [
	"Returns the source method for which a test is being generated. Used to access method details like class and selector for test creation."

	^ sourceMethod
]

{ #category : 'accessing' }
AIATestGenerator >> sourceMethod: anObject [
	"The sourceMethod method assigns the method to be tested and initializes the AI chat builder for test generation. It sets up the context for AI to generate appropriate test cases."

	sourceMethod := anObject
]

{ #category : 'accessing' }
AIATestGenerator >> sourceMethodStringName [
	"The sourceMethodStringName method returns the selector of the source method as a string. It is used to identify the method for which a test is being generated."
	^ sourceMethod selector asString
]

{ #category : 'test builder' }
AIATestGenerator >> systemGenerator [
	"The systemGenerator method provides context about the system including packages classes and methods to ensure accurate test generation."
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
	"The testMethod method returns the generated test method for the source method. It is compiled into the test class and can be executed to verify the source method's functionality."

	^ testMethod
]

{ #category : 'accessing' }
AIATestGenerator >> testMethod: anObject [
	"Assigns the generated test method to the instance variable testMethod, storing it for later compilation and execution."

	testMethod := anObject
]

{ #category : 'test builder' }
AIATestGenerator >> testMethodName [
	"The testMethodName method constructs a test method name by capitalizing the source method's keywords and prefixing with 'test'. It ensures proper naming conventions for AI-generated test methods."
	^ 'test', ((self sourceMethodStringName keywords collect: [:kw | 
		(kw copyReplaceAll: ':' with: '') capitalized]) joinUsing: '')
]
