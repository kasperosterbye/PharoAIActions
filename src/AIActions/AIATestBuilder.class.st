"
# Class Comment for AIATestBuilder

The `AIATestBuilder` class is responsible for generating automated test methods using AI assistance. It leverages the capabilities of AI models to create comprehensive test cases for existing methods, ensuring code quality and reliability.

## Key Features

- **AI-Powered Test Generation**: Utilises AI to analyse source code and generate appropriate test methods.
- **Context-Aware Prompts**: Combines system context, method information, and specific prompts to guide AI in creating accurate test cases.
- **Error Handling and Repair**: Automatically detects and repairs compilation errors in generated test methods.
- **Test Class Management**: Creates or retrieves test classes, compiles setup code, and handles instance variables.
- **Retry Mechanism**: Implements a retry mechanism to handle failures during test generation and compilation.

## Usage Example

```smalltalk
""Example of how to use AIATestBuilder in the Playground""
| builder testMethod sourceMethod |

""Assume we have a method to test""
sourceMethod := Object >> #asString.

""Create an instance of AIATestBuilder""
builder := AIATestBuilder new.

""Generate a test method for the source method""
testMethod := builder build: sourceMethod.

""Inspect the generated test method""
testMethod inspect.
```

## Design Decisions

- **Fluid Syntax**: The class is designed to support a fluid syntax for easy scripting and interactive use.
- **Separation of Concerns**: The builder separates the concerns of test generation, compilation, and execution.
- **Error Handling**: Implements robust error handling to manage failures during test generation and compilation.
- **Retry Mechanism**: Includes a retry mechanism to ensure the generation of valid test methods.
- **Test Class Management**: Handles the creation and management of test classes, including setup code and instance variables.

## Future Enhancements

- **Improved API Alignment**: Revisit the API to align with class default values and reduce unnecessary conversions.
- **Enhanced Context Awareness**: Further improve the context-aware prompts to enhance the accuracy of generated test methods.
- **Integration with CI/CD**: Explore integration with continuous integration and deployment pipelines for automated test generation.

This class is designed to be extended and customised for different AI models and testing frameworks, ensuring flexibility and adaptability to various project requirements.
"
Class {
	#name : 'AIATestBuilder',
	#superclass : 'AIABuilder',
	#instVars : [
		'chatBuilder',
		'sourceMethod',
		'testMethod',
		'testColor'
	],
	#classVars : [
		'AITestClass',
		'AITestClassPostfix'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'accessing' }
AIATestBuilder class >> aITestClassPostfix: anObject [

	AITestClassPostfix := anObject
]

{ #category : 'instance creation' }
AIATestBuilder class >> buildAll: aClass [
	"Builds test methods for all methods in a class using Mistral AI"
	| testResults |
	testResults := OrderedDictionary new.
	aClass methodDict values do: [ :method | | testBuilder |
		testBuilder:= self new.
		testBuilder build: method.
		testResults at: method selector put: testBuilder testColor 
	 ].
	^ testResults 
]

{ #category : 'builder' }
AIATestBuilder class >> buildTestClass: sourceClass [
	"Creates or retrieves a test class for a given method, compiling setup code and handling instance variables. Returns the test class."

    |  superClass newTestClassName shifter instanceVarName |
    "Identify the name of the new test class based on the method's class."
	 AITestClassPostfix ifNil: [ AITestClassPostfix := 'AITest' ].
	sourceClass isMeta 
		ifFalse: [ newTestClassName := sourceClass name asString, AITestClassPostfix .]
 		ifTrue: [ newTestClassName := sourceClass soleInstance name asString,
			'Class', AITestClassPostfix].
    
    "The name of the instance variable to hold the reference to the test class."
    instanceVarName := 'ref', (sourceClass) name asString.
	 sourceClass isMeta ifTrue: [ instanceVarName := instanceVarName allButLast: 6 ].
    
    "Try to find an existing test class."
    AITestClass := Smalltalk globals at: newTestClassName asSymbol ifAbsent: [ nil ].
    
    "If the test class does not exist, create a new one."
    AITestClass ifNil: [
            "Check if a super test class exists (e.g., AIDijkstraTest)."
            "superClass := Smalltalk globals at: (aMethod methodClass name , 'Test') asSymbol ifAbsent: [ TestCase ]".
				superClass := TestCase.
            
            shifter := ShiftClassBuilder new.
            shifter
                superclassName: superClass name;
                name: newTestClassName asSymbol;
                slots: { instanceVarName asSymbol };
                package: 'AIATestExperiments'.
            
            AITestClass := shifter install.
            
            "Compile an initialize method to set up the instance variable."
            AITestClass compile: ('setUp' , String cr,
                                  '	super setUp.' , String cr,
                                  '	', instanceVarName , ' := ' , sourceClass name asString , ' new.'
                                 ) classified: 'initialization'.
        ].
    
    ^ AITestClass
]

{ #category : 'instance creation' }
AIATestBuilder >> build: aMethod [
	"Builds a test for a given method, using AI to generate and validate the test code. Returns the chat history of the AI interaction."

	self for: aMethod.
	self compileAndChechBuildedTestOf: aMethod.
	^ self chatHistory 
]

{ #category : 'instance creation' }
AIATestBuilder >> buildTestChat [
	"Builds the chat context for AI test generation, combining system details, method info, and prompts to guide AI in creating accurate test cases."

	self systemGenerator.
	self historyBuilder.
	self promptGenerator.
]

{ #category : 'instance creation' }
AIATestBuilder >> buildTestChatHistoryFor: aMethod [
	"Builds the chat context for AI test generation, combining system details, method info, and prompts to guide AI in creating accurate test cases."

	sourceMethod := aMethod.
	self systemGenerator.
	self historyBuilder.
	self promptGenerator.
	^ chatBuilder chatHistory.
]

{ #category : 'accessing' }
AIATestBuilder >> chatBuilder [
	^ chatBuilder 
]

{ #category : 'accessing' }
AIATestBuilder >> chatHistory [
	"Returns the chat history of the AI interaction, aiding debugging and refinement of test generation."

	^ chatBuilder chatHistory
]

{ #category : 'instance creation' }
AIATestBuilder >> compileAndChechBuildedTestOf: aMethod [
	"Builds a test method for a given method, retrying up to a specified number of times if compilation or execution fails. Returns the chat history of the AI interaction."

	| testMethodName result |
	self repairResponseMethod.
	[
		testMethodName := AITestClass compile: testMethod classified: 'AI generated test'. "Run the test method using SUnit infrastructure"
		result := TestResult new.
		result runCase: (AITestClass selector: testMethodName asSymbol).
		result passedCount > 0 ifTrue: [ testColor := Color green ].
		result failureCount > 0 ifTrue: [ testColor := Color yellow ].
		result errorCount > 0 ifTrue: [ testColor := Color red ] ]
		on: Error
		do: [
				testMethodName := self fictiveTestMethod.
				testColor := Color black ].


	^ self chatHistory
]

{ #category : 'instance creation' }
AIATestBuilder >> fictiveTestMethod [
	"Creates a placeholder test method when AI test generation fails, preserving the original code as a comment."

	| header fictiveTest |
	header := 'test'
	          , ((self sourceMethodStringName keywords collect: [ :kw |
			            (kw copyReplaceAll: ':' with: '') capitalized ])
			           joinUsing: '').
	fictiveTest := header , String cr
	               , '	self fail: ''Test code could not be generated'' '
	               , String cr , String cr , testMethod asComment.
	^ AITestClass compile: fictiveTest classified: 'Failed generated test'
]

{ #category : 'instance creation' }
AIATestBuilder >> for: aMethod [
	"aMethod is the compiled method to which a test should be renerated."
	sourceMethod := aMethod.
	self class buildTestClass: aMethod methodClass.
	
	self buildTestChat.
	self generateTest.
	
	^ testMethod 
]

{ #category : 'instance creation' }
AIATestBuilder >> generateTest [
	"The generateTest method uses AI to create test methods for source methods by combining system context and specific prompts to produce clean test code."
	chatBuilder getResponse.
	testMethod := chatBuilder response.
	self repairResponseMethod.
	chatBuilder history last value: testMethod
	 
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
	chatBuilder := AileinProvider provider new.
	
]

{ #category : 'test builder' }
AIATestBuilder >> promptGenerator [
	"The promptGenerator method creates a user prompt for AI test generation, guiding AI in generating appropriate test cases.
"

	chatBuilder user: ('You must only use code that you know is existing in Pharo, never use figurative code.
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

{ #category : 'instance creation' }
AIATestBuilder >> rebuild [
	"The `rebuild:` method attempts to fix and recompile a failed test method, generating a corrected version and retrying compilation. "

	chatBuilder user:
		'The test method you generated contains one or more source code errors and could not be compiled by Pharo.'
		, String cr , String cr 
		, 'First, consider why the following code might not compile:'
		, String cr , String cr , testMethod , String cr , String cr
		", 'This was intended to be a test method for: '
		, sourceMethod name asString , '.' , String cr"
		, 'Wrap your next approach code in a fenced code block using ```smalltalk.'
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
			testMethod := lines findFirst: [ :line | line beginsWith: 'test' ] ]
	
]

{ #category : 'accessing' }
AIATestBuilder >> sourceClassFirstInstanceVariable [
	"This method returns the first instance variable of the test class associated with the source method. It handles cases where the test class has no instance variables by returning an empty string."
	| testClassVariables |
	"(Smalltalk at: (self sourceClassStringName,'Test') asSymbol) instanceVariables first name."
	testClassVariables := (Smalltalk at: (self sourceClassStringName, AITestClassPostfix ) asSymbol) instanceVariables.
	testClassVariables size = 0 
		ifTrue: [ ^ '' ]
		ifFalse: [^ testClassVariables first name.]
]

{ #category : 'accessing' }
AIATestBuilder >> sourceClassStringName [
	"Returns the name of the class associated with the source method as a string. Used to identify the class context for test generation."
	^ sourceMethod  methodClass asString
]

{ #category : 'accessing' }
AIATestBuilder >> sourceMethodStringName [
	"The sourceMethodStringName method returns the selector of the source method as a string. It is used to identify the method for which a test is being generated."
	^ sourceMethod selector asString
]

{ #category : 'instance creation' }
AIATestBuilder >> systemGenerator [
	"The systemGenerator method provides context about the system including packages classes and methods to ensure accurate test generation."
	chatBuilder system: 
		'All background code and documentation is written in Markdown.
		This includes Pharo packages, classes, and methods.', String cr, 
	(AIASourceCodeBuilder new for: { 
		sourceMethod methodClass class packageName asString. 
		sourceMethod methodClass packageName asString , '-Tests' }).
]

{ #category : 'accessing' }
AIATestBuilder >> testColor [
	^ testColor 
]

{ #category : 'test builder' }
AIATestBuilder >> testMethodName [
	"The testMethodName method constructs a test method name by capitalizing the source method's keywords and prefixing with 'test'. It ensures proper naming conventions for AI-generated test methods."
	^ 'test', ((self sourceMethodStringName keywords collect: [:kw | 
		(kw copyReplaceAll: ':' with: '') capitalized]) joinUsing: '')
]
