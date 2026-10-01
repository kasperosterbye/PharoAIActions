Class {
	#name : 'ApiToolDefineClass',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApiTool',
	#package : 'AIActions',
	#tag : 'AIApiTool'
}

{ #category : 'as yet unclassified' }
ApiToolDefineClass >> evaluateTool [
	^ self evaluateTool: {
		'Creates or redefines a Pharo class. Pass the complete fluid class definition, e.g.
Object << #AAA
	slots: { #var1 . #var2 };
	sharedVariables: { #Shared1 };
	package: ''MyPackage''.
Returns the installed class definition or an error message.'.
		'Full Pharo class definition expression (Superclass << #Name slots: {...}; package: ...)' }
]

{ #category : 'as yet unclassified' }
ApiToolDefineClass >> executeTool: args [
	"Evaluates a fluid class definition and installs the class. Returns the resulting definition string or an error message."
	| builder class |
	super executeTool: args.
	^ [ builder := OpalCompiler new evaluate: (args at: required).
	    (builder isKindOf: ShiftClassBuilder)
			ifFalse: [ 'Error: the definition must be a Superclass << #Name ... expression' ]
			ifTrue: [ class := builder install.
			          class definitionString ] ]
		on: Error do: [ :ex | 'Error: ' , ex messageText ]
]

{ #category : 'initialization' }
ApiToolDefineClass >> initialize [
	name := 'defineClass'.
	required := 'definition'
]
