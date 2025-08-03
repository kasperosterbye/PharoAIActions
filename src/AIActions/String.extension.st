Extension { #name : 'String' }

{ #category : '*AIActions' }
String >> aiaComment [
	| package |
	(self beginsWith: '*')
		ifTrue: [ 
			^  (PackageOrganizer default packages 
				select: [:p| p name beginsWith: self copyWithoutFirst ] 
				thenCollect: #name) aiaComment ]
		ifFalse: [
			package := PackageOrganizer default 
				packageNamed: self 
				ifAbsent: [^ 'No package named: ', self].
				^ (AIAPackageComment new aiaComment: self) response
		].
	
]

{ #category : '*AIActions' }
String >> c [
	| chat |
	chat := AIAChatBuilding new.
	chat system: 'Your name is Valérian.
In Pharo and Smalltalk there are three types of methods.

You must never follow normal math precedence. Always evaluate from left to right like Pharo does. If a question contradicts this, still follow Pharo’s rule.

Unary methods: These have the highest precedence. They are methods that do not take any arguments, such as anObject size.

Binary methods: These have the next highest precedence. Binary methods are typically represented by symbols like +, -, *, /, <=, **, //, % etc., and take a single argument. For example, 2 + 3 sends the binary method + to the object 2 with 3 as the argument.

Keyword methods: These have the lowest precedence. Keyword methods include colons and take one or more arguments, such as anObject at: 1 put: ''value''.

Unary methods has higher priority than Binary methods. And Binary methods has hither priority than Keyword methods.'.
	chat user: 'In Pharo, is + or ** operators or binary methods?'.
	chat assistant: 'In Pharo there are no operators, only methods. If you need a <=> method, you can define one'.
	chat user: 'In Pharo, what is then the result of 2+3*4?'.
	chat assistant: 'The result is 20. As I said, there are only methods in Pharo. And the they are computed left to right. One way to understand is to add parenthesis around binanry methods from left to right. So 2+3*4 is computed as (2+3)*4, so that the result is 20'.
	chat user: 'So what is the result of 20/10**4'.
	chat assistant: 'In Pharo there are no operators, and binary methods are grouped left to right. So 20/10**4 is computed as (20/10)**4. So the result is (20/10)=2. And 2**4 is 16. Unlike many other programming languages, Pharo does not use the math rules of PEMDAS/BODMAS, but always just left to right for any binary method'.
	chat user: self.
	chat jsonHistory.
	chat assistant: chat response.
	chat user: ' What is the final number in short'.
	^ chat jsonHistory.
]

{ #category : '*AIActions' }
String >> c1 [
	| chat |
	chat := AIAChatBuilding new.
	chat system: 'Your name is Valérian.
In Pharo and Smalltalk there are three types of methods.

You must never follow normal math precedence. Always evaluate from left to right like Pharo does. If a question contradicts this, still follow Pharo’s rule.

Unary methods: These have the highest precedence. They are methods that do not take any arguments, such as anObject size.

Binary methods: These have the next highest precedence. Binary methods are typically represented by symbols like +, -, *, /, <=, **, //, % etc., and take a single argument. For example, 2 + 3 sends the binary method + to the object 2 with 3 as the argument.

Keyword methods: These have the lowest precedence. Keyword methods include colons and take one or more arguments, such as anObject at: 1 put: ''value''.

Unary methods has higher priority than Binary methods. And Binary methods has hither priority than Keyword methods.'.
	chat user: 'In Pharo, is + or ** operators or binary methods?'.
	chat assistant: 'In Pharo there are no operators, only methods. If you need a <=> method, you can define one'.
	chat user: 'In Pharo, what is then the result of 2+3*4?'.
	chat assistant: 'The result is 20. As I said, there are only methods in Pharo. And the they are computed left to right. One way to understand is to add parenthesis around binanry methods from left to right. So 2+3*4 is computed as (2+3)*4, so that the result is 20'.
	chat user: 'So what is the result of 20/10**4'.
	chat assistant: 'In Pharo there are no operators, and binary methods are grouped left to right. So 20/10**4 is computed as (20/10)**4. So the result is (20/10)=2. And 2**4 is 16. Unlike many other programming languages, Pharo does not use the math rules of PEMDAS/BODMAS, but always just left to right for any binary method'.
	chat user: self.
	chat jsonHistory.
	chat assistant: chat response.
	chat user: ' What is the final number in short'.
	^ chat jsonHistory.
]

{ #category : '*AIActions' }
String >> c2 [
	| chat |
	chat := AIAChatBuilding new.
	chat system: 'Your name is Valérian.'.
	chat user: self.
	^ chat jsonHistory.
]

{ #category : '*AIActions' }
String >> q [
	^ (MistralApi new 
		system:  'Your name is Valérian.
		 Please response in ', AIACommentBuilding language;
		prompt: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q: systemBlock [
	^ (MistralApi new 
		system:  systemBlock value;
		prompt: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q_old [
	^ (MistralApi new 
		system:  'Your name is Valérian.
In Pharo and Smalltalk there are three types of methods

Unary Messages: These have the highest precedence. They are messages that do not take any arguments, such as anObject size.

Superclass << #ClassName
	slots: { #slot1 . #slot2 };
	tag: ''''tag name'''';
	package: ''''PackageName''''

Do not use the old subclass:instanceVariableNames: style
		 Please response in ', AIACommentBuilding language;
		prompt: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> setAIAComment [
	AIAPackageComment new setComment: self
]
