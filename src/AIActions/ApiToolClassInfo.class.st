Class {
	#name : 'ApiToolClassInfo',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApiTools',
	#package : 'AIActions',
	#tag : 'AIApiTools'
}

{ #category : 'as yet unclassified' }
ApiToolClassInfo >> evaluateTool [
	| desc desc1 |
	desc := 'Returns class information, class comment, instance variables, and method selectors for a Pharo class.'.
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
