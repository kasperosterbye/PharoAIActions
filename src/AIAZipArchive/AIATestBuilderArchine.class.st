Class {
	#name : 'AIATestBuilderArchine',
	#superclass : 'AIATestBuilder',
	#category : 'AIAZipArchive-Tests01',
	#package : 'AIAZipArchive',
	#tag : 'Tests01'
}

{ #category : 'instance creation' }
AIATestBuilderArchine >> xxx_backgroundGenerator [
	"The systemGenerator method provides context about the system including packages classes and methods to ensure accurate test generation."
	chatBuilder background: (AIASourceCode new forClass: sourceMethod methodClass class).
]

{ #category : 'instance creation' }
AIATestBuilderArchine >> xxx_buildTestChat [
	"Builds the chat context for AI test generation, combining system details, method info, and prompts to guide AI in creating accurate test cases."

	chatBuilder background: (AIASourceCode new forClass: sourceMethod methodClass class).
	self historyBuilder.
	chatBuilder user: self promptGenerator.
]

{ #category : 'instance creation' }
AIATestBuilderArchine >> xxx_buildTestChatHistoryFor: aMethod [
	"Builds the chat context for AI test generation, combining system details, method info, and prompts to guide AI in creating accurate test cases."

	sourceMethod := aMethod.
	self systemGenerator.
	self historyBuilder.
	self promptGenerator.
	^ chatBuilder chatHistory.
]

{ #category : 'compiling' }
AIATestBuilderArchine >> xxx_compileAndChechBuildedTest [
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
AIATestBuilderArchine >> xxx_fictiveTestMethod [
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
AIATestBuilderArchine >> xxx_for: aMethod [
	self buildTestChat.
	self generateTest.
	
	^ testMethod 
]

{ #category : 'instance creation' }
AIATestBuilderArchine >> xxx_generateTest [
	
	chatBuilder getResponse.
	testMethod := chatBuilder response.
	self repairResponseMethod.
	 
]

{ #category : 'instance creation' }
AIATestBuilderArchine >> xxx_rebuild [
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

{ #category : 'accessing' }
AIATestBuilderArchine >> xxx_sourceClassStringName [
	"Returns the name of the class associated with the source method as a string. Used to identify the class context for test generation."
	^ sourceMethod  methodClass asString
]

{ #category : 'accessing' }
AIATestBuilderArchine >> xxx_sourceMethodStringName [
	"The sourceMethodStringName method returns the selector of the source method as a string. It is used to identify the method for which a test is being generated."
	^ sourceMethod selector asString
]

{ #category : 'instance creation' }
AIATestBuilderArchine >> xxx_systemGenerator [
	"The systemGenerator method provides context about the system including packages classes and methods to ensure accurate test generation."
	chatBuilder system: 
		'All background code and documentation is written in Markdown.
		This includes Pharo packages, classes, and methods.', String cr, 
	(AIASourceCode new forClass: sourceMethod methodClass class).
]
