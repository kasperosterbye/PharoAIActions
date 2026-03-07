Class {
	#name : 'ApiToolExpression',
	#superclass : 'AilienApiTool',
	#category : 'AIAZipArchive-AIApiTools',
	#package : 'AIAZipArchive',
	#tag : 'AIApiTools'
}

{ #category : 'as yet unclassified' }
ApiToolExpression >> evaluateTool [
	| desc desc1 |
	desc := 'Evaluates Pharo Smalltalk expression. Returns printString of result. Handles arithmetic, object creation, collection operations, blocks etc.'.
	desc1 := 'Pharo expression to evaluate'.

    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'as yet unclassified' }
ApiToolExpression >> executeTool: args [
	"Evaluates the provided Pharo expression and returns its string representation handling any errors"

	| expr result |
	super executeTool: args.
	expr := args at: required.
	[  result := (expr includesSubstring: 'compile:') 
			ifTrue: [  'Sorry, I will not compile and make new methods' ]
			ifFalse: [(OpalCompiler new evaluate: expr) printString].
		]
		on: Error
		do: [ :ex | result := 'Error: ' , ex messageText ].
	
		Transcript << '>>> ' << result << String lf.
		^ result 
]

{ #category : 'initialization' }
ApiToolExpression >> initialize [
	name := 'executePharoExpression'.
	required := 'expression'
]
