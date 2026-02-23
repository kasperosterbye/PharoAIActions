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

{ #category : 'instance creation' }
AIATestBuilder >> build: aMethod [
	| testGenCounter |
	sourceMethod := aMethod.
	self getOrBuildTestClass.
	
	testGenCounter := 1. 
	testColor := 'None'.
	[ testGenCounter <= 3 and: [ testColor ~= Color green ]  ]
		whileTrue: [
			Transcript << 'Test ' << testGenCounter asString 
					<< ' for ' << sourceMethod name << String lf.
			self generateTest.
			self compileAndChechBuildedTest.
			self halt. chatBuilder.
			testGenCounter := testGenCounter + 1.
			].
	^ self chatHistory .
]

{ #category : 'as yet unclassified' }
AIATestBuilder >> captureErrorFor: aSelector in: aTestClass [
    | result suite case |
    suite := TestSuite new.
    case := aTestClass selector: aSelector.
    suite addTest: case.
    result := suite run.
    
    result errors ifNotEmpty: [ :errors | 
        | ex |
        ex := errors first exception.
        ^ 'SYNTAX/RUNTIME ERROR: ', ex description, 
          ' at: ', (ex signalerContext method selector asString) ].
    ^ nil
]

{ #category : 'as yet unclassified' }
AIATestBuilder >> captureFailureFor: aSelector in: aTestClass [
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

{ #category : 'accessing' }
AIATestBuilder >> chatHistory [
	"Returns the chat history of the AI interaction, aiding debugging and refinement of test generation."

	^ chatBuilder chatHistory
]

{ #category : 'as yet unclassified' }
AIATestBuilder >> checkBuildedTest: testMethodName [
	"Run the test method using SUnit infrastructure"

	| result |
	result := TestResult new.
	result runCase: (self getOrBuildTestClass selector: testMethodName asSymbol).
	result passedCount > 0 ifTrue: [ testColor := Color green ].
	result failureCount > 0 ifTrue: [ testColor := Color yellow ].
	result errorCount > 0 ifTrue: [ testColor := Color red ]
]

{ #category : 'compiling' }
AIATestBuilder >> compileAndChechBuildedTest [
	| testMethodName  |
	testMethodName := self getOrBuildTestClass 
					compile: testMethod classified: 'AI generated test'. 
	self checkBuildedTest: testMethodName.
	
	^ self chatHistory
]

{ #category : 'instance creation' }
AIATestBuilder >> generateTest [
	
	chatBuilder background: (AIASourceCodeBuilder new forClass: sourceMethod methodClass class).
	self historyBuilder.
	chatBuilder user: self promptGenerator.
	
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

{ #category : 'as yet unclassified' }
AIATestBuilder >> joeSilly: testMethodName [
"Inside your build: method"
testColor = Color red ifTrue: [ 
    chatBuilder user: 'The test failed with a syntax error: ', 
        (self captureErrorFor: testMethodName in: self getOrBuildTestClass).
    chatBuilder user: 'Please fix the syntax and return the full corrected method.' ].

testColor = Color yellow ifTrue: [ 
    chatBuilder user: 'The test failed an assertion: ', 
        (self captureFailureFor: testMethodName in: self getOrBuildTestClass).
    chatBuilder user: 'Please adjust the logic and return the full corrected method.' ].
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
		collect: [:kw | (kw copyReplaceAll: ':' with: '') capitalized]) 
		joinUsing: ''.
	testName := 'test', name.
	^ testName
]
