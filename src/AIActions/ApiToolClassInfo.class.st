Class {
	#name : 'ApiToolClassInfo',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
ApiToolClassInfo >> evaluateTool [
	| desc desc1 |
	desc := 'Returns class comment, instance variables, and method selectors for a Pharo class.'.
	desc1 := 'Name of the Pharo class'.

    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'initialization' }
ApiToolClassInfo >> executeTool: args [

	| className cls |
	super executeTool: args.
	className := args at: required.
	cls := Smalltalk globals at: className asSymbol ifAbsent: [ ^ 'Class not found' ].
	^ String streamContents: [ :s |
			  s << '## ' << className << String cr.
			  s << 'Slots: ' << (cls instVarNames joinUsing: ' ') << String cr.
			  s << 'Comment: ' << (cls comment ifEmpty: [ 'None' ]) ]
]

{ #category : 'initialization' }
ApiToolClassInfo >> initialize [
	name := 'getClassInfo'.
	required := 'className'
]
