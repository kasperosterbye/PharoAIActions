Class {
	#name : 'ApiToolClassInfo',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApiTool',
	#package : 'AIActions',
	#tag : 'AIApiTool'
}

{ #category : 'as yet unclassified' }
ApiToolClassInfo >> evaluateTool [
	| desc desc1 |
	desc := 'Returns structured documentation for a Pharo class: class comment, instance variables, and all method selectors with comments.'.
	desc1 := 'Name of the Pharo class'.

    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'initialization' }
ApiToolClassInfo >> executeTool: args [

	| className cls |
	super executeTool: args.
	className := args at: required.
	cls := Smalltalk globals at: className asSymbol ifAbsent: [ ^ 'Class not found' ].
	^ AIASourceCodeBuilder new forClass: cls.
]

{ #category : 'initialization' }
ApiToolClassInfo >> initialize [
	name := 'getClassInfo'.
	required := 'className'
]
