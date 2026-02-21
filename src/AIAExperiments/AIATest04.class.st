Class {
	#name : 'AIATest04',
	#superclass : 'AIATestBuilder',
	#category : 'AIAExperiments-TestBuiler',
	#package : 'AIAExperiments',
	#tag : 'TestBuiler'
}

{ #category : 'test builder' }
AIATest04 >> hist2WhereToPlaceTestMethod [
	

	chatBuilder user: ('I want to write a test method for `{1}` in class `{2}`. 
In what test class do I place it, and what do I name the test method' format: {
				 self sourceMethodStringName.
				 self sourceClassStringName }).
	chatBuilder assistant: ('There is an existing test class named `{1}` which is to be used. 
The name of the test method is `{2}`' format: {
				 (self sourceClassStringName , 'AITest').
				 self testMethodName }) , String cr
		, ('In the setUp method of `{1}`, the instance variable `{2}` is initialized to an instance of `{3}`,'
			 , 'so you should not declare a local variable in the test method, but use `{2}` ' format: {
					 (self sourceClassStringName , 'AITest').
					 self sourceClassFirstInstanceVariable.
					 self sourceClassStringName })
]

{ #category : 'instance creation' }
AIATest04 >> historyBuilder [

	chatBuilder
		background: 'You are a TOOL using AI.';
		user: 'The test must be written in Pharo14';
		user: 'Instance variables/slots cannot be read via direct methods (e.g., no obj ivar). Always use obj instVarNamed: #ivarName to read and obj instVarNamed: #ivarName put: value to set; do not use instVarAt: (requires Integer index).';
		user: 'For assert: statements, always wrap the condition in parentheses to avoid left-to-right parsing errors, e.g., self assert: (response isKindOf: WriteStream) . Not self assert: response isKindOf: WriteStream .';
		responseType: 'You must use TOOL `executePharoExpression` to ensure that the methods you use actually exists'.
	self hist2WhereToPlaceTestMethod.
		
	
	
]

{ #category : 'initialization' }
AIATest04 >> initialize [ 
	super initialize.
	
]
