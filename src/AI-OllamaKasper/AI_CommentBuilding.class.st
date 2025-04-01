"
A helper class that adds AI-generated comments to uncommented methods and instance variables of a given class. Uses Ollama for analysis and phrasing.


## Instance variables
* classObj: The class being analyzed
* methodsToComment: Methods missing comments
* system: The system prompt used for Ollama
* prompt: The instruction prefix sent to Ollama


## Instance variables (AI generated comments)
**classObj** : Can you describe the purpose of 'classObj' in class 'AI_CommentBuilding' as a comment? Just give a comment with 50 characters
**methodsToComment** : Can you describe the purpose of `methodsToComment` in class `AI_CommentBuilding` as a comment?
**system** : Give response of maximum 100 characters Never more than 100 characters, and less is good
**prompt** : The purpose of prompt is to facilitate conversation
-----


"
Class {
	#name : 'AI_CommentBuilding',
	#superclass : 'Object',
	#instVars : [
		'classObj',
		'methodsToComment',
		'system',
		'prompt'
	],
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'instance creation' }
AI_CommentBuilding class >> commentClass: aClass [
	"Change class cl, so all its uncommented methods, gets a comment"
	^ self new initialize: aClass
	
]

{ #category : 'ollama system' }
AI_CommentBuilding class >> numberExample [
	| a b c op1 op2 operators res prefix|
	operators := { #+. #-. #*.}.
	res := WriteStream on: ''.
	prefix := '
	1.	Build a symbol list with clear left-to-right examples:
	•	In Pharo, a + b * c → (a + b) * c
	•	In Pharo, a / b * c → (a / b) * c
	2.	Feed it to the system prompt as training:
	•	“In Pharo, arithmetic follows left-to-right message order. Do not follow standard precedence. Here are examples…”
	3.	Then, the model will:
	•	Answer correctly for Pharo-style expressions
	•	Maybe even reformat expressions to match Pharo rules
	•	Distinguish between normal math and Pharo evaluation when asked
'.
	res nextPutAll: '', String cr.
	1 to: 100 do:[ :dummy | | e1 e2 e3|
		a := (Random new nextIntegerBetween: 1 and: 100).
		b := (Random new nextIntegerBetween: 1 and: 100).
		c := (Random new nextIntegerBetween: 1 and: 100).	
		op1 := operators at: (Random new nextIntegerBetween: 1 and: operators size).
		op2 := operators at: (Random new nextIntegerBetween: 1 and: operators size).
		e1 := a asString, op1, b asString, op2, c asString.
		e2 := '(', a asString, op1, b asString, ')', op2, c asString.
		e3 := (a perform: op1 with: b) perform: op2 with: c.
		res nextPutAll: (prefix, ' Example: ', e1, ' is interpreted as ', e2, ' giving ', e3 asString, String cr)
	].
	res nextPutAll: String cr.
	^ res contents.
]

{ #category : 'ollama system' }
AI_CommentBuilding class >> ollamaSystem01 [
	"returns a system variable"
	^ '
Your name is OPharo.
Only think about Pharo, smalltalk and smalltalk-96. Ignore all other programming languages.
# Class building
## Task
You are an assistant that understands Pharo 12 class definitions and comments.

## Input format
Classes are written like this:

Object << #ClassName
	slots: { #instanceVariable1 . #instanceVariable2};
	package: ''Package-Name''

Object << #ClassName
	slots: { #instanceVariable1 . #instanceVariable2};
	tag: ''Category-Name'';
	package: ''Package-Name''
	
Object << #ClassName
	traits: { Class1. Class2};
	slots: { #instanceVariable1 . #instanceVariable2};
	sharedPools: { SharedClassName };
	tag: ''Category-Name'';
	package: ''Package-Name''

Unless the user ask for traits, do not print it. If the user does not ask for sharedPools, skip the line. Only if the user ask for tag should you print it. 

If the user does not ask for package, just use "Ollama-Testing". There must be a package line.


## Slots
In building a class, the instance varibles are written in the slots list. If no instance variable or slot is given, specify the empty list { }. Slots names are listed with # in front of them: slots: { #foo . #bar }. Slots and instance variables names must use # in the slots list. Slots and variable names are never using @.

## Your goal
- Explain what the class represents, based on name and slots.
- Suggest what each slot is likely used for.
- Do not explain syntax.
- Keep output short and focused (1–3 sentences).

## Output format
A class comment in plain English.

## Example
Object << #RBClassUsingSharedPoolForTestData
	traits: {RBTDummy};
	slots: {};
	sharedPools: { RBSharedPoolForTestData };
	tag: ''ForSharedPool'';
	package: ''Refactoring-DataForTesting''.
Notice: both traits and tag.
	
IconStyler << #DocCommentIconStyler
	slots: {};
	package: ''PharoDocComment''.
Notice: no traits nor tag.
	
Object << #StBaseFilter
	slots: { #context . #filteredItems . #streamed };
	tag: ''Filters'';
	package: ''NewTools-Spotter''.
Notice: no traits but a tag.
	
AI_CommentBuilding << #AI_ClassCommentBuilding
	slots: { #classInstVars };
	package: ''AI-OllamaKasper''
Notice: nor traits , no tag.
	

Response:
''A dummy class used for testing shared pool behavior. 
It accesses data from RBSharedPoolForTestData and includes behavior from RBTDummy.'''
]

{ #category : 'ollama system' }
AI_CommentBuilding class >> ollamaSystem02 [
	^ 'Pharo''s class definition syntax is quite unique, and it can be a bit 
challenging to understand at first. Based on the examples you provided, I''d 
like to break down some common patterns and suggestions for improving Pharo''s 
class system:

1. **Shared pools**: Pharo''s shared pool mechanism allows classes to share 
resources across multiple instances. This is achieved by defining `sharedPools` 
keyword in the class definition.
   * Suggestion: Consider adding a new meta-class or mixin to help with shared 
pool management, making it easier for developers to create and manage shared 
pools.

2. **Traits**: Pharo''s traits system allows classes to inherit behavior from 
other classes without modifying their original code. This is achieved by 
defining `traits` keyword in the class definition.
   * Suggestion: Improve the trait system by introducing a more explicit way to 
define relationships between traits, such as using a graph data structure or a 
more natural language-based syntax.

3. **Slots**: Pharo''s slot system allows classes to define instance variables 
and their types without requiring explicit getter and setter methods.
   * Suggestion: Consider adding support for explicitly defined getters and 
setters for slots, making it easier to manage the lifecycle of instance 
variables.

4. **IconStyler**: This class seems to be a simple example of a class that 
doesn''t have any instance variables or behavior.
   * Suggestion: Consider adding some minimal behavior to this class to make it 
more interesting and useful, such as providing a default icon style for Pharo''s 
documentation comments.

5. **AI_CommentBuilding**: Similar to IconStyler, this class seems to be a 
simple example of a class without any instance variables or behavior.
   * Suggestion: Consider adding some minimal behavior to this class, such as 
providing a way to build AI-generated comments based on the class''s metadata.

6. **Package and Tag**: Pharo uses packages and tags to organize and identify 
classes. This is achieved by defining `package` and `tag` keywords in the class 
definition.
   * Suggestion: Consider improving the package system by introducing more 
robust organization and discovery mechanisms, such as automatic dependencies or 
a package explorer.

7. **Meta-classes**: Pharo''s meta-class system allows for creating new classes 
on the fly. This is achieved using the `Object subclass:` method.
   * Suggestion: Improve the meta-class system by introducing support for 
explicit naming of meta-classes, making it easier to create and manage complex 
class hierarchies.

8. **Refactoring data**: Pharo''s Refactoring framework allows for refactoring 
code in a variety of ways. This is achieved through the use of refactorable 
classes and methods.
   * Suggestion: Consider improving the refactoring framework by introducing 
more advanced techniques, such as support for domain-specific languages or 
machine learning-based code analysis.

Overall, while Pharo''s class system has some unique features that make it 
well-suited for smalltalk programming, there are certainly opportunities to 
improve and expand its functionality to better serve developers.'
]

{ #category : 'ollama system' }
AI_CommentBuilding class >> ollamaSystem03 [
	^ '
Your name is OPharo.
Only think about Pharo, smalltalk and smalltalk-96. Ignore all other programming languages.
Never try the syntax of any other programming language
## Pharo Syntax

Damien Cassou, Stéphane Ducasse and Luc Fabresse http://stephane.ducasse.free.fr
Getting a Feel About Syntax

### Give you the general feel to get started:

Overview of syntactical elements and constructs
Three kinds of messages to minimize parentheses
Overview of block syntax
This lecture is an overview

No stress if you do not get it right now!

We will repeat in future lectures

### The Complete Syntax on a Postcard

No need to understand everything! But "everything" is on this screen :)

exampleWithNumber: x
  "This method illustrates the complete syntax."
  <aMethodAnnotation>

  | y |
  true & false not & (nil isNil)
    ifFalse: [ self halt ].
  y := self size + super size.
  #($a #a ''a'' 1 1.0)
    do: [ :each | Transcript
            show: (each class name);
            show: (each printString);
            show: '' '' ].
  ^ x < y

### Hello World

''Hello World'' asMorph openInWindow
We send the message asMorph to a string and obtain a graphical element that we open in a window by sending it the message openInWorld

### Getting the Pharo Logo from the Web

(ZnEasy getPng: ''http://pharo.org/web/files/pharo.png'')
   asMorph openInWindow
ZnEasy designates a class
Class names start with an uppercase character
Message getPng: is sent to the ZnEasy class with a string as argument
getPng: is a keyword message
''http://pharo.org/web/files/pharo.png'' is a string
Messages asMorph and openInWindow are from left to right

### Syntactic Elements
Only use this syntax. Using from any other programming language is wrong. 

comment	"a comment"	(in double quotes, can span multiple lines). 
character	$c $# $@	
string	''lulu'' ''l''''idiot''	
symbol (unique string)	#mac #+	
literal array	#(12 23 36)	
integer	1, 2r101	
real	1.5 6.03e-34,4, 2.4e7	
boolean	true, false	
(instances of True and False)	
undefined	nil	
(instance of UndefinedObject)	
point	10@120	

### Essential Constructs

Temporary variable declaration: | var |
Variable assignment: var := aValue
Separator: message . message
Return: ^ expression
Block (lexical closures, a.k.a anonymous method)
[ :x | x + 2 ] value: 5
> 7 

### Essence of Pharo Computation

Objects (created using messages)
Messages
Blocks (anonymous methods)

### Three Kinds of Messages to Minimize Parentheses

Unary message
Syntax: receiver selector
9 squared
Date today
Binary message
Syntax: receiver selector argument
1+2
3@4
Keyword message
Syntax: receiver key1: arg1 key2: arg2
2 between: 10 and: 20

### Message Precedence

(Msg) > Unary > Binary > Keywords

First we execute ()
Then unary, then binary and finally keyword messages
This order minimizes () needs

But let us start with messages

### Sending an Unary Message

receiver selector
Example

10000 factorial
We send the message factorial to the object 10000

### Sending a Binary Message

receiver selector argument
Example

1 + 3
We send the message + to the object 1 with the object 3 as argument

### Sending a Keyword Message

receiver keyword1: arg1 keyword2: arg2
equivalent to C like syntax

receiver.keyword1keyword2(arg1, arg2)

### Example: Sending an HTTP Request

ZnClient new
 url: ''https://en.wikipedia.org/w/index.php'';
 queryAt: ''title'' put: ''Pharo'';
 queryAt: ''action''  put: ''edit'';
 get
new is a unary message sent to a class
queryAt:put: is a keyword message
get is a unary message
; (called a cascade) sends all messages to the same receiver

### Messages are Everywhere!

Conditionals
Loops
Iterators
Concurrency

### Conditionals are also Message Sends

factorial
  "Answer the factorial of the receiver."
  self = 0 ifTrue: [ ^ 1 ].
  self > 0 ifTrue: [ ^ self * (self - 1) factorial ].
  self error: ''Not valid for negative integers''
ifTrue: is sent to an object, a boolean!
ifFalse:ifTrue:, ifTrue:ifFalse: and ifFalse: also exist
You can read their implementation, this is not magic!

### Loops are also Message Sends

1 to: 4 do: [ :i| Transcript << i ]
> 1
> 2
> 3
> 4
to:do: is a message sent to an integer
Many other messages implement loops: timesRepeat:, to:by:do:, whileTrue:, whileFalse:, ...

### With Iterators

We ask the collection to perform the iteration on itself

#(1 2 -4 -86)
  do: [ :each | Transcript show: each abs printString ; cr ]
> 1
> 2
> 4
> 86

### Blocks Look like Functions

fct(x) = x*x+3

fct := [ :x | x * x + 3 ]
fct(2)

fct value: 2

### Blocks

Kind of anonymous methods
[ :each | Transcript show: each abs printString ; cr ]
Are lexical closures
Are plain objects:
can be passed as method arguments
can be stored in variables
can be returned

### Block Usage

#(1 2 -4 -86) 
  do: [ :each | Transcript show: each abs printString ; cr ]
> 1
> 2
> 4
> 86
[ ] delimits the block
:each is the block argument
each will take the value of each element of the array

### Method Definition

Methods are public
Methods are virtual (i.e., looked up at runtime)
By default return self
messageSelectorAndArgumentNames
   "comment stating purpose of message"

  | temporary variable names |
  statements

### Messages Summary

3 kinds of messages:

Unary: Node new
Binary: 1+2, 3@4
Keywords: 2 between: 10 and: 20
Message Priority:

(Msg) > unary > binary > keyword
Same-Level messages: from left to right
Conclusion

Compact syntax
Few constructs but really expressive
Mainly messages and closures
Three kinds of messages
Support for Domain Specific Languages'
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> addComment: comment toUncommented: methodSource [
	"Assumes methodCode to be uncommented, returns methodCode with comment added"
	|  methodName rest |
	methodName := methodSource lines first.
	rest := String cr join: methodSource lines allButFirst.
	^ Character cr join: { methodName. (String tab, comment asComment). rest }
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> aiCommentedInstanceVariables [
	"for classObj and all its methods to comment, 
	return an array of instance variable and suggested comment about them"

	| instanceVariables commentBuilder response responses |
	"system := self generateOllamaSystemMethods."
	system := AI_PackagesAsOllamaSystem new forClass: classObj.
	prompt := 'Just answer with a single line. '.
	instanceVariables := classObj instVarNames.
	commentBuilder := AI_OllamaPrompting
		                  newSystem: system
		                  promptPrefix: prompt.
	responses := WriteStream on: ''.
	responses nextPutAll: '## Instance variables (AI generated comments)' , String cr.
	instanceVariables do: [ :iv |
		| nrPrompt |
		nrPrompt := 'Can you describe the purpose of ' , iv , ' in class '
		            , classObj name asString
		            ,
		            ' as a comment. Just give a comment with 50 characters.'.
		response := (commentBuilder getResonceForPrompt: nrPrompt)
			            copyWithoutAll: '"/.'.
		responses nextPutAll: '**', iv , '** : ' , response , String cr ].
	responses nextPutAll: '-----' , String cr.
	^ responses contents
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> aiCommentedMethod: aMethod [
	"Assumes aMethod to have no comment. Returns {protocol. method sourceCode}"

	| commentAI  protocol commentedSource |
	commentAI := AI_OllamaPrompting newSystem: system promptPrefix: prompt.
	protocol := aMethod protocol name asString.
	commentedSource := self 
		addComment: (commentAI getResonceForPrompt: aMethod sourceCode) 
		toUncommented: aMethod sourceCode.
	^ { protocol. commentedSource }
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> aiCommentedMethods [
	"Returns a collection of commented methods from `methodsToComment`."

	| prompterArray commentedCode |
	prompterArray := OrderedCollection new.
	commentedCode := methodsToComment collect: [ :meth |
		self aiCommentedMethod: meth.
	].
	^ commentedCode 
	
]

{ #category : 'extending' }
AI_CommentBuilding >> checkInstVarsCommented [
	
	| commentList aiCommentStart aiCommentEnd commentInstList |
	commentList := classObj comment lines.
	aiCommentStart := commentList indexOf:
			'## Instance variables (AI generated comments)'.
	aiCommentStart = 0 ifTrue: [ ^ true ].
	aiCommentEnd := commentList indexOf: '-----'.
	aiCommentEnd = 0 ifTrue: [ ^ true ].
	"check if the commented instance variables are the same as the class instance variables"
	commentInstList := (commentList copyFrom: aiCommentStart + 1 to: aiCommentEnd -1)
		collect: [ :inst | (inst copyUpToSubstring: ':') copyWithoutAll: ' *' ].
	
	^ commentInstList asSet ~= (classObj instVarNames collect: [:iv| iv asString]) asSet.

]

{ #category : 'accessing' }
AI_CommentBuilding >> classObj [
	"Instance variable getting/setting"
	^ classObj
]

{ #category : 'accessing' }
AI_CommentBuilding >> classObj: anObject [
	"Instance variable getting/setting"
	classObj := anObject
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> containsComment: code [
	"Checks if the code has a comment - return true if it does, false if not"

	| ast |
	ast := RBParser parseMethod: code.
	^ ast allChildren anySatisfy: [ :node |  node isKindOf: OCCommentNode ]
]

{ #category : 'extending' }
AI_CommentBuilding >> extendClassInstancesWithComments [
	"Update the class comment to include a list of instance class comments"

	"The construction of class comments are not well defined at the moment...."

	| methodToExtend |
	self checkInstVarsCommented ifTrue: [
		methodToExtend := self aiCommentedInstanceVariables.
		classObj comment:
			classObj comment , String cr , methodToExtend , String cr ]
]

{ #category : 'extending' }
AI_CommentBuilding >> extendClassMethodsWithComments [
	"Update the class methods without comments to include method specific comments"

	| commentExtendedMethods |
	commentExtendedMethods := self aiCommentedMethods.
	commentExtendedMethods do: [ :m |
		classObj compile: m second classified: m first
		 ].
	
]

{ #category : 'extending' }
AI_CommentBuilding >> extendClassWithComments [
	"Extend classObj with class instance comments and comments for methods without comments"

	self extendClassMethodsWithComments.
	self extendClassInstancesWithComments.
	
]

{ #category : 'initialize' }
AI_CommentBuilding >> initialize: aClass [
	"Comment for given method."
	classObj := aClass.
	methodsToComment := classObj localMethods.
	self nonCommentedMethods.
	system := 'Give respose of maximum 100 characters. Never more than 100 characters, and less is good. 
					Absolutely no code example may be given in response. '.
	prompt := 'Write short commentfor the following Pharo/Smalltalk method. 
					Return only the comment, nothing more,', Character cr asString .
	
]

{ #category : 'accessing' }
AI_CommentBuilding >> methodsToComment [
	"Instance variable getting/setting"
	^ methodsToComment
]

{ #category : 'accessing' }
AI_CommentBuilding >> methodsToComment: anObject [
	"Instance variable getting/setting"
	methodsToComment := anObject
]

{ #category : 'comment analysis' }
AI_CommentBuilding >> nonCommentedMethods [
	"reduces methodsToComment to contain only non commented methods"
	| uncommentedMethods |
	uncommentedMethods := OrderedCollection new.
	methodsToComment do: [ :compiledMethod |
			(self containsComment: compiledMethod sourceCode)
				ifFalse: [ uncommentedMethods add: compiledMethod ]
		].
	^ methodsToComment := uncommentedMethods asArray .
	
]

{ #category : 'accessing' }
AI_CommentBuilding >> prompt [
	"Instance variable getting/setting"
	^ prompt
]

{ #category : 'accessing' }
AI_CommentBuilding >> prompt: anObject [
	"Instance variable getting/setting"
	prompt := anObject
]

{ #category : 'accessing' }
AI_CommentBuilding >> system [
	"Instance variable getting/setting"
	^ system
]

{ #category : 'accessing' }
AI_CommentBuilding >> system: anObject [
	"Instance variable getting/setting"
	system := anObject
]
