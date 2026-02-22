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
			testGenCounter := testGenCounter + 1.
			].
	^ self chatHistory .
]

{ #category : 'accessing' }
AIATestBuilder >> chatBuilder [
	"Accesses the AI chat builder instance for test generation support."
	^ chatBuilder 
]

{ #category : 'accessing' }
AIATestBuilder >> chatHistory [
	"Returns the chat history of the AI interaction, aiding debugging and refinement of test generation."

	^ chatBuilder chatHistory
]

{ #category : 'compiling' }
AIATestBuilder >> compileAndChechBuildedTest [
	| testMethodName result |
	[ 
		testMethodName := self getOrBuildTestClass 
					compile: testMethod classified: 'AI generated test'. 
		"Run the test method using SUnit infrastructure"
		result := TestResult new.
		result runCase: (self getOrBuildTestClass selector: testMethodName asSymbol).
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
	"Creates a placeholder test method when AI generation fails and compiles it into the test class."

	| fictiveTest |
	self halt.
	fictiveTest := WriteStream on: ''.
	fictiveTest << 'test'
	      << ((self sourceMethodStringName keywords collect: [ :kw |
			            (kw copyReplaceAll: ':' with: '') capitalized ])
			           joinUsing: '')
			<< String cr
	      << '	self fail: ''Test code could not be generated'' '
	      << String cr << String cr 
			<< testMethod asComment.
	^ self getOrBuildTestClass 
			compile: fictiveTest contents
			classified: 'Failed generated test'
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
	| testClassName  |
	testClassName := AIATestClassBuilder ensureTestClass: sourceMethod  methodClass.
	^ testClassName instanceVariables first name
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

{ #category : 'instance creation' }
AIATestBuilder >> xxx_backgroundGenerator [
	"The systemGenerator method provides context about the system including packages classes and methods to ensure accurate test generation."
	chatBuilder background: (AIASourceCodeBuilder new forClass: sourceMethod methodClass class).
]

{ #category : 'instance creation' }
AIATestBuilder >> xxx_buildTestChat [
	"Builds the chat context for AI test generation, combining system details, method info, and prompts to guide AI in creating accurate test cases."

	chatBuilder background: (AIASourceCodeBuilder new forClass: sourceMethod methodClass class).
	self historyBuilder.
	chatBuilder user: self promptGenerator.
]

{ #category : 'instance creation' }
AIATestBuilder >> xxx_buildTestChatHistoryFor: aMethod [
	"Builds the chat context for AI test generation, combining system details, method info, and prompts to guide AI in creating accurate test cases."

	sourceMethod := aMethod.
	self systemGenerator.
	self historyBuilder.
	self promptGenerator.
	^ chatBuilder chatHistory.
]

{ #category : 'instance creation' }
AIATestBuilder >> xxx_fictiveTestMethod [
	"Creates a placeholder test method when AI generation fails and compiles it into the test class."

	| header fictiveTest | 
	header := 'test'
	          , ((self sourceMethodStringName keywords collect: [ :kw |
			            (kw copyReplaceAll: ':' with: '') capitalized ])
			           joinUsing: '').
	fictiveTest := header , String cr
	               , '	self fail: ''Test code could not be generated'' '
	               , String cr , String cr , testMethod asComment.
	^ self getOrBuildTestClass compile: fictiveTest classified: 'Failed generated test'
]

{ #category : 'instance creation' }
AIATestBuilder >> xxx_for: aMethod [
	self buildTestChat.
	self generateTest.
	
	^ testMethod 
]

{ #category : 'instance creation' }
AIATestBuilder >> xxx_generateTest [
	
	chatBuilder getResponse.
	testMethod := chatBuilder response.
	self repairResponseMethod.
	 
]

{ #category : 'instance creation' }
AIATestBuilder >> xxx_rebuild [
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

{ #category : 'instance creation' }
AIATestBuilder >> xxx_systemGenerator [
	"The systemGenerator method provides context about the system including packages classes and methods to ensure accurate test generation."
	chatBuilder system: 
		'All background code and documentation is written in Markdown.
		This includes Pharo packages, classes, and methods.', String cr, 
	(AIASourceCodeBuilder new forClass: sourceMethod methodClass class).
]
