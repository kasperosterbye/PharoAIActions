Class {
	#name : 'ApiToolCompileMethod',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApiTool',
	#package : 'AIActions',
	#tag : 'AIApiTool'
}

{ #category : 'as yet unclassified' }
ApiToolCompileMethod >> evaluateTool [
	^ self evaluateToolDescription: 'Compiles (adds or replaces) a method in an existing Pharo class. Source must be full method source: selector pattern, optional comment, temporaries and body. Set classSide to true to define a class-side method (metaclass).'
		properties: (Dictionary newFrom: {
			'className' -> 'Name of the existing class (without "class" suffix)'.
			'source'    -> 'Complete method source code, e.g. "foo: x ^ x + 1"'.
			'protocol'  -> 'Method protocol/category, e.g. accessing (optional)'.
			'classSide' -> { 'boolean'. 'true to compile on the class side (metaclass), false for instance side' } })
		required: #('className' 'source')
]

{ #category : 'as yet unclassified' }
ApiToolCompileMethod >> executeTool: args [
	"Compiles the given source in the named class (instance or class side). Returns a confirmation or an error message."
	| class target source protocol selector |
	super executeTool: args.
	class := Smalltalk globals at: (args at: 'className') asSymbol ifAbsent: [ ^ 'Error: class not found' ].
	target := (args at: 'classSide' ifAbsent: [ false ]) == true
		ifTrue: [ class classSide ] ifFalse: [ class ].
	source := args at: 'source'.
	protocol := args at: 'protocol' ifAbsent: [ 'as yet unclassified' ].
	^ [ selector := target compile: source classified: protocol.
	    selector
			ifNil: [ 'Error: compilation failed (syntax error)' ]
			ifNotNil: [ target name , '>>#' , selector , ' compiled' ] ]
		on: Error do: [ :ex | 'Error: ' , ex messageText ]
]

{ #category : 'initialization' }
ApiToolCompileMethod >> initialize [
	name := 'compileMethod'.
	required := 'className'
]
