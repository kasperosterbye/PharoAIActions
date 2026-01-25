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
ApiToolClassInfo >> executeTool: args [
	| cls |
    cls := Smalltalk globals at: args asSymbol ifAbsent: [ ^ 'Class not found' ].
    ^ String streamContents: [ :s |
        s << '## ' << args << String cr.
        s << 'Slots: ' << (cls instVarNames joinUsing: ' ') << String cr.
        s << 'Comment: ' << (cls comment ifEmpty: [ 'None' ]) ]
]

{ #category : 'initialization' }
ApiToolClassInfo >> initialize [
	name := 'getClassInfo'.
	required := 'className'
]
