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
	desc := 'Evaluates Pharo Smalltalk expression. Returns printString of result. Handles arithmetic, object creation, collection operations.'.
	desc1 := 'Pharo expression to evaluate'.
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

{ #category : 'as yet unclassified' }
ApiToolExpression >> executeTool: args [
	| expr |
	expr := args at: required.
    [ ^ (OpalCompiler new evaluate: expr) printString ]
        on: Error
        do: [ :ex | ^ 'Error: ', ex messageText ]

]

{ #category : 'initialization' }
ApiToolExpression >> initialize [
	name := 'evaluatePharoExpression'.
	required := 'expression'
]
