Class {
	#name : 'ApiToolBrowseImplementors',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
ApiToolBrowseImplementors >> evaluateTool [
	| desc desc1 |
	desc := 'Returns list of classes implementing a given selector.'.
	desc1 := 'Method selector to find implementors of'.

    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'initialization' }
ApiToolBrowseImplementors >> executeTool: args [

	| selector implementors |
	super executeTool: args.
	selector := args at: required.
	implementors := SystemNavigation default allImplementorsOf: selector asSymbol.
	implementors ifEmpty: [ ^ 'No implementors found' ].
	^ (implementors collect: [ :m | m methodClass name ]) joinUsing: ', '
]

{ #category : 'initialization' }
ApiToolBrowseImplementors >> initialize [
	name := 'browseImplementors'.
	required := 'selector'
]
