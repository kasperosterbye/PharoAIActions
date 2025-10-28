Class {
	#name : 'AIATest02',
	#superclass : 'AIATestBuilder',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'test builder' }
AIATest02 >> hist1GeneratorMethods [
	"The hist1GeneratorMethods method provides context about Pharo method types unary binary and keyword to ensure accurate test generation."
	chatBuilder user: 'I have heard that Pharo have different types of methods, what are they'.
	chatBuilder assistant:'
Important Coding Rule

When writing Pharo code or tests:
	•	Only use methods that are explicitly described in the provided context or documentation.
	•	If unsure whether a method exists, do not invent one.
	•	If no valid method is known, respond with:
“I cannot complete this without more information about the available methods.”


In Pharo, method names follow three distinct syntactic forms:
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

{ #category : 'test builder' }
AIATest02 >> hist50WhatIsTheBasics [
	"The hist50WhatIsTheBasics method provides context about method return values in Pharo, explaining the difference between implicit and explicit returns using the caret symbol."
	chatBuilder user: ('For making a test for method {1} in class {2}, what does {1} return'
			format: {self sourceMethodStringName . self sourceClassStringName }).
	chatBuilder assistant: ( 'In Pharo, if a method does not contain the `^` symbol, it implicitly returns the receiver (self), which in this case is an instance of FuzzyMatcher.
If the method includes a `^`, it returns the value of the expression following that symbol.
So for `{1}`, if there is no caret, it returns the `{2}` instance; if there is one, you’ll need to check what expression follows it.'
			format: {self sourceMethodStringName . self sourceClassStringName }).
]

{ #category : 'test builder' }
AIATest02 >> hist70ReferenceToOrigin [
	^ self.
	chatBuilder user: 'A test method often need a reference to the original. How do I find the original class?'.
	chatBuilder assistant: ('You need to use the local variable of the test class {1}, which in this class is ref{1}. ' format: { self sourceClassStringName})
]

{ #category : 'test builder' }
AIATest02 >> hist92WhatIsTheBasics [
	"The hist92WhatIsTheBasics method provides context about local variable rules in Pharo methods, ensuring proper syntax and declaration."
	chatBuilder user: 'Are there any rules for local variables in Pharo?'.
	chatBuilder assistant: 'Yes. In Pharo, all local variables must be declared in a single block at the top of the method using vertical bars, like `| pathDistance |`. 
Placing the declaration later in the code is a syntax error and will prevent the method from compiling.'.
]

{ #category : 'test builder' }
AIATest02 >> hist94SourceMethodCommentAndCode [
	
	chatBuilder user:( 'What should I test in `{1} given its comment and implementation?' format: {self sourceMethodStringName}).
	chatBuilder assistant: ('You are supposed to write a test method of `{1}`, and take its comment: "{2}" into consideration.'
		format: { self sourceMethodStringName. sourceMethod comment })
]

{ #category : 'instance creation' }
AIATest02 >> historyBuilder [

	self hist92WhatIsTheBasics.
	self hist1GeneratorMethods.
	self hist50WhatIsTheBasics.
	self hist70ReferenceToOrigin.
	self hist94SourceMethodCommentAndCode.
	
]

{ #category : 'initialization' }
AIATest02 >> initialize [ 
	super initialize.
	
]
