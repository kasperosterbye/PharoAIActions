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
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> name.
            'description' -> desc.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'expression' -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> desc1
                    })
                }).
                'required' -> {required} 
            })
        })
    }
]

{ #category : 'initialization' }
ApiToolBrowseImplementors >> executeTool: args [
    | selector implementors |
self halt.
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
