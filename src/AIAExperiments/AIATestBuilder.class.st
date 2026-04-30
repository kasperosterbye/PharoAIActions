"
# Class Comment for AIATestBuilder

The `AIATestBuilder` class is designed to facilitate the automated generation of test methods for existing methods in Pharo classes using AI-driven tools. It leverages various AI models to create test cases, ensuring comprehensive test coverage and accuracy. The builder interacts with AI APIs to generate test methods, which are then compiled and checked for correctness.

## Key Features

- **AI-Driven Test Generation**: Utilises different AI models to generate test methods for specified methods in a class.
- **Test Compilation and Validation**: Compiles the generated test methods and checks their execution results to determine their validity.
- **Flexible AI Model Integration**: Supports multiple AI models, allowing for flexibility and the ability to switch between different AI providers.
- **Comprehensive Test Reporting**: Provides detailed feedback on the test generation process, including success, failure, or error statuses.

## Usage Example

```smalltalk
""Example of how to use AIATestBuilder to generate tests for a class method""

| testBuilder methodToTest testResults |

""Create an instance of AIATestBuilder""
testBuilder := AIATestBuilder new.

""Specify the method for which tests are to be generated""
methodToTest := Object >> #yourMethod.

""Build tests for the specified method""
testResults := testBuilder build: methodToTest.

""Inspect the test results""
testResults inspect.
```

This example demonstrates how to create an instance of `AIATestBuilder`, specify a method for which tests are to be generated, and then inspect the results of the test generation process.
"
Class {
	#name : 'AIATestBuilder',
	#superclass : 'Object',
	#instVars : [
		'chatBuilder',
		'sourceMethod',
		'testMethod',
		'testColor'
	],
	#category : 'AIAExperiments-TestBuiler',
	#package : 'AIAExperiments',
	#tag : 'TestBuiler'
}

{ #category : 'instance creation' }
AIATestBuilder class >> aiBuildList [
	^ {
		GrokApi newOnModel: 2.
		GrokApi newOnModel: 4.
		ClaudeApi newOnModel: 4.
		OpenAIApi newOnModel: 3.
		
	}
]

{ #category : 'instance creation' }
AIATestBuilder class >> buildAll: aClass [
	"Builds test methods for all methods in a class using Mistral AI"
	| testResults sortedMethods |
	testResults := OrderedDictionary new.
	sortedMethods := aClass methodDict values 
		sort: [ :a :b | a selector < b selector ].
	sortedMethods do: [ :method | | testBuilder |
		testBuilder:= self new.
		testBuilder build: method.
		testResults at: method selector put: testBuilder testColor 
	 ].
	^ testResults 
]

{ #category : 'instance creation' }
AIATestBuilder >> build: aMethod [
	| testGenCounter |
	sourceMethod := aMethod.
	self getOrBuildTestClass.
	
	testGenCounter := 1. 
	testColor := 'None'.
	[ testGenCounter <= (self class aiBuildList size) and: [ testColor ~= Color green ]  ]
		whileTrue: [
			Transcript << String lf << 'Test ' << testGenCounter asString 
					<< ' (' <<  (self class aiBuildList at: testGenCounter ) printString << ') '
					<< 'for ' << sourceMethod name << String lf.
			chatBuilder api: (self class aiBuildList at: testGenCounter ).
			testGenCounter = 1
				ifTrue: [ self generateTest10 ]
				ifFalse: [ self generateTest20 ].
				
			self compileAndChechBuildedTest.
			testGenCounter := testGenCounter + 1.
			].
	^ self chatHistory .
]

{ #category : 'accessing' }
AIATestBuilder >> chatHistory [
	"Returns the chat history of the AI interaction, aiding debugging and refinement of test generation."

	^ chatBuilder chatHistory
]

{ #category : 'as yet unclassified' }
AIATestBuilder >> checkBuildedTest: testMethodRef [
	"Run the test method using SUnit infrastructure"

	| result |
	testColor := Color red.
	result := TestResult new.
	result runCase: testMethodRef.
	result passedCount > 0 ifTrue: [ testColor := Color green ].
	result failureCount > 0 ifTrue: [ testColor := Color yellow ].
	result errorCount > 0 ifTrue: [ testColor := Color red ].
	
]

{ #category : 'compiling' }
AIATestBuilder >> compileAndChechBuildedTest [
	
	[ | testMethodName testMethodRef|
		testMethodName := self getOrBuildTestClass 
					compile: testMethod classified: 'AI generated test'. 
					
		testMethodRef := self getOrBuildTestClass selector: testMethodName asSymbol.
		self checkBuildedTest: testMethodRef]
	on: Error
	do: [ testColor := Color red ].
	
	^ self chatHistory
]

{ #category : 'instance creation' }
AIATestBuilder >> generateTest [
	
	chatBuilder background: (AIASourceCode new forClass: sourceMethod methodClass class).
	self historyBuilder.
	chatBuilder user: self promptGenerator.
	
	chatBuilder getResponse.
	testMethod := chatBuilder response.
	self repairResponseMethod.
	 
]

{ #category : 'instance creation' }
AIATestBuilder >> generateTest10 [
	
	chatBuilder background: (AIASourceCode new forClass: sourceMethod methodClass class).
	self historyBuilder.
	chatBuilder user: self promptGenerator.
	
	chatBuilder getResponse.
	testMethod := chatBuilder response.
	self repairResponseMethod.
	 
]

{ #category : 'instance creation' }
AIATestBuilder >> generateTest20 [
	
	chatBuilder user: 'The previous generated test class did not work. Please try again'.
	
	chatBuilder getResponse.
	testMethod := chatBuilder response.
	self repairResponseMethod.
	 
]

{ #category : 'instance creation' }
AIATestBuilder >> getOrBuildTestClass [
	^ AIATestClassBuilder ensureTestClass: sourceMethod methodClass.
]

{ #category : 'instance creation' }
AIATestBuilder >> historyBuilder [
	"The historyBuilder method constructs the chat history for AI test generation, combining system details, method information, and prompts to guide AI in creating accurate test cases."
	self subclassResponsibility 
]

{ #category : 'initialization' }
AIATestBuilder >> initialize [ 
	"Initializes the AI test builder with a new AI chat builder instance, setting up the foundation for AI-driven test generation."
	super initialize.
	chatBuilder := AIAHistory new.
	
]

{ #category : 'test builder' }
AIATestBuilder >> promptGenerator [
	^ ('You must only use code that you know is existing in Pharo14, never use figurative code, but use the TOOL `evaluatePharoExpression` to find information.
The setUp method of any test methos is called before the test is executed.
Do not declare local variables that are already provided as instance variables. 
Insert comments in the test method you create.
Just return the test method. Do not explain.
Please build a test case for this method 

```smalltalk
{1}
```

Do not use Mock tests!
Remember, key `candidates` not found in `Dictionary`
Remember, all variables of a method are declares together, not spread in the test method.
Please wrap the method in a fenced code block using ```smalltalk.”
' 
	format: { sourceMethod sourceCode }).
]

{ #category : 'test builder' }
AIATestBuilder >> repairResponseMethod [
	"Repairs AI-generated test method by extracting code between fenced blocks and ensuring proper formatting for compilation."

	| startIndex endIndex raw lines |
	"Look for ```smalltalk and the closing fence"
	startIndex := testMethod findString: '```smalltalk'.
	endIndex := testMethod findString: '```' startingAt: startIndex + 1.
	(startIndex = 0 or: [ endIndex = 0 ]) ifFalse: [
			raw := testMethod
				       copyFrom: startIndex + '```smalltalk' size + 1
				       to: endIndex - 1.

			"Standardize line endings"
			testMethod := raw
				              copyReplaceAll: Character lf asString
				              with: Character cr asString ].
	lines := testMethod lines.
	startIndex := lines findFirst: [ :line | line beginsWith: 'test' ].
	startIndex > 1 ifTrue: [
		self halt.
			testMethod := lines findFirst: [ :line | line beginsWith: 'test' ] ]
	
]

{ #category : 'accessing' }
AIATestBuilder >> sourceClassFirstInstanceVariable [
	^ self getOrBuildTestClass slots first name
]

{ #category : 'accessing' }
AIATestBuilder >> testColor [
	^ testColor 
]

{ #category : 'test builder' }
AIATestBuilder >> testMethodName [
	"The testMethodName method constructs a test method name by capitalizing the source method's keywords and prefixing with 'test'. It ensures proper naming conventions for AI-generated test methods."
	| name testName|
	name := (sourceMethod selector asString keywords 
		collect: [:kw | (kw copyReplaceAll: ':' with: 'Arg') capitalized]) 
		joinUsing: ''.
	testName := 'test', name.
	^ testName
]

{ #category : 'as yet unclassified' }
AIATestBuilder >> xxx_captureErrorFor: aSelector in: aTestClass [
    | result suite case |
self halt.
    suite := TestSuite new.
    case := aTestClass selector: aSelector.
    suite addTest: case.
    result := suite run.
    result errors ifNotEmpty: [ :errors | 
        | ex |

self halt.
        ex := errors first exception.
        ^ 'SYNTAX/RUNTIME ERROR: ', ex description, 
          ' at: ', (ex signalerContext method selector asString) ].
    ^ nil


]

{ #category : 'as yet unclassified' }
AIATestBuilder >> xxx_captureFailureFor: aSelector in: aTestClass [
    | result suite case |
    suite := TestSuite new.
    case := aTestClass selector: aSelector.
    suite addTest: case.
    result := suite run.

    result failures ifNotEmpty: [ :failures |
        | signal |
        signal := failures first exception.
        ^ 'LOGIC FAILURE: ', signal messageText ].
    ^ nil
]
