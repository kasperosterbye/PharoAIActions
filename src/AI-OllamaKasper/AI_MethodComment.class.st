"
This class implements AI based comment generations for methods. There are several levels.

1) If the method already have a comment (checks if the second line starts with "" ), then that comment is kept.
2) If no comment exist it will look at the senders of this method
* There is no senders. It can be either a method that should be removed, or an important one to be used on the outside. The comment should be added that ask the developer to solve the issue - if it is imporant, add usage to class side or in tests

* More than around 50% of the senders are in the same class. Ignore the other 50% as they are most likely unrelated, but just using the same name. Give the same class methods as input to the understanding of the method

* There number of senders from other classes is high, meaning that the implementation of the method is done in many classes. Assume the name of the class is widely used, and check if the method it self is implemented in all those classes as well.
	If they are, use these other classes as input to the AI comment generator
	If they are not, use the senders as input to the AI comment generator
"
Class {
	#name : 'AI_MethodComment',
	#superclass : 'AI_CommentBuilding',
	#instVars : [
		'methodReference'
	],
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'as yet unclassified' }
AI_MethodComment >> commectSourceFor: aCompiledMethod [
	"I just return a string on the form Class >> method"
	| sourceString |
	sourceString := WriteStream on: ''.
	sourceString << aCompiledMethod methodClass name << ' >> '.
	sourceString << aCompiledMethod sourceCode << String cr << String cr.
	^ sourceString contents
]

{ #category : 'accessing' }
AI_MethodComment >> method: aCompiledMethod [
	"returns nil if the method alredy has a comment. Other it returns the sourceCode"
	| sourceCode senders|
	sourceCode := aCompiledMethod sourceCode lines.
	(sourceCode size >= 2 and: [sourceCode second trimLeft beginsWith: '"'])
    ifTrue: [ ^ aCompiledMethod sourceCode].
	senders := aCompiledMethod senders.
   senders size = 0 
		ifTrue: [ ^ nil "No uses it" ].
	"need a way to find all implementations of the same method name in other classes"
	self halt.
		
	
]
