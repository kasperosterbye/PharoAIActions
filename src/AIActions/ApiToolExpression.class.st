Class {
	#name : 'ApiToolExpression',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
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

	| expr |
	super executeTool: args.
	expr := args at: required.
	[ ^ (OpalCompiler new evaluate: expr) printString ]
		on: Error
		do: [ :ex | ^ 'Error: ' , ex messageText ]
]

{ #category : 'initialization' }
ApiToolExpression >> initialize [
	name := 'executePharoExpression'.
	required := 'expression'
]
