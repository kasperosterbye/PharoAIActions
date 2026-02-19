Class {
	#name : 'AIATest04',
	#superclass : 'AIATestBuilder',
	#category : 'AIAExperiments-TestBuiler',
	#package : 'AIAExperiments',
	#tag : 'TestBuiler'
}

{ #category : 'test builder' }
AIATest04 >> hist2WhereToPlaceTestMethod [
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

{ #category : 'instance creation' }
AIATest04 >> historyBuilder [

	chatBuilder 
		user: 'The test must be written in Pharo14';
		user: 'Remember, variables in a method must be declared before the actual code';
		user: 'In Pharo/Smalltalk, arrays first elememnt is at index 1';
		user: 'If you need more information about specifics of Pharo14, use TOOL `evaluatePharoExpression`';
		user: '(TestResult new runCase: (`testClassName`` selector: ``#testMethodName`` )) errors size should return `0`, if not your test code is not working'.
	self hist2WhereToPlaceTestMethod.
		
	
	
]

{ #category : 'initialization' }
AIATest04 >> initialize [ 
	super initialize.
	
]
