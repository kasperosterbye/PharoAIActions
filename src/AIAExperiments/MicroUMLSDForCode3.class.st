"
# Class Comment for MicroUMLSDForCode

The `MicroUMLSDForCode` class is designed to construct abstract syntax trees (ASTs) from traces of method calls, specifically focusing on method calls within a specified package. This is particularly useful for generating sequence diagrams that illustrate the interactions between classes and methods within a given package.

## Key Features

- **AST Construction**: Constructs an abstract syntax tree from method call traces.
- **Package Filtering**: Filters method calls to include only those within a specified package.
- **Actor Management**: Manages actors (classes) involved in the method calls.
- **Message Handling**: Handles messages between actors, including return messages.
- **Trace Reduction**: Reduces duplicate traces to ensure each trace is unique.
- **Package Testing**: Tests if a package or class matches the specified package name criteria.

## Usage Example

Here is an example of how to use the `MicroUMLSDForCode` class to generate a sequence diagram from a block of code:

```st
| builder ast |
builder := MicroUMLSDForCode new.
ast := builder types: [
    | point |
    point := Point new.
    point x: 10.
    point y: 20.
    point x + point y
] inPackage: 'Kernel'.
ast inspect
```

In this example, the `types:inPackage:` method is used to construct an AST from a block of code, focusing on method calls within the 'Kernel' package. The resulting AST is then inspected to visualise the sequence diagram.

## Design Decisions

- **Scripting**: The code snippet should be usable for scripting (interactively).
- **Class Builder**: The code snippet must return a class builder.
- **Installation**: A class builder should offer methods to build and install the class.
- **Slot Management**: Manages class side slots and traits by converting all class information into an expected format.
- **API Alignment**: Future revisions should align APIs with class default values to reduce conversions.

This class is part of the 'AIAExperiments' package and is tagged with 'MicroUML'.
"
Class {
	#name : 'MicroUMLSDForCode3',
	#superclass : 'Object',
	#instVars : [
		'packageName'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'examples' }
MicroUMLSDForCode3 class >> example1 [
	<example>
	self new types: [ Exp1 exp1Method1: 7. 2 timesRepeat: [ Exp2 new exp2Method1: 17]  ] inPackage: 'AIAExperiments'.
]

{ #category : 'examples' }
MicroUMLSDForCode3 class >> example2 [
	<example>
	self new types: [ Microdown asRichText: '## Joe' ] inPackage: 'Microdown'
]

{ #category : 'examples' }
MicroUMLSDForCode3 class >> example3 [
	<example>
	self new types: [ AIASourceCode forClass: MicroUMLSDForCode  ] inPackage: 'AIActions'
]

{ #category : 'testing' }
MicroUMLSDForCode3 class >> isReturn: current [
	^ (InstructionStream on: current method pc: current pc) willReturn
]

{ #category : 'as yet unclassified' }
MicroUMLSDForCode3 class >> on: block inPackage: pack [
	self new types: block inPackage: pack
]

{ #category : 'as yet unclassified' }
MicroUMLSDForCode3 >> astFromCurrentList: currentList [
	| traces experiments next i |
	traces := OrderedCollection new.
	experiments := OrderedCollection new.
	i := 1.
	currentList do: [ :current |
		(self checkCurrent: current )
			ifTrue: [ 
				next := { current sender methodClass name. current method methodClass name. 
							 current method selector . current isReturn}  .
				(self checkAdd: next to: traces)
							ifTrue: [ 
								traces add: next. "self halt." 
								experiments add: (next , { current method selector, ' # ', i asString } )]
				 ].
			i := i + 1.
		 ].
	^ traces 
]

{ #category : 'experiments' }
MicroUMLSDForCode3 >> astFromTrace: traces [
	"Constructs an abstract syntax tree from a trace of method calls."

	| builder |
	builder := MicroUMLSDAstBuilder new.
	self buildActorsOf: traces on: builder.

	"builder & aTrace first first -> aTrace first second => aTrace first third."
	traces  do: [ :trace |
			self message: trace on: builder ].

	"builder & aTrace last second -> aTrace last first --> '***'."
	MicroUMLSequenceDiagram from: builder
]

{ #category : 'experiments' }
MicroUMLSDForCode3 >> buildActorName: name on: actors [
	"Builds an actor name from the given name and adds it to the actors collection if it is not already present and meets the package criteria."

	name = 'UndefinedObject' 
		ifTrue: [ (actors includes: name) ifFalse: [ actors add: name ] ]
		ifFalse: [
			(Smalltalk classNamed: name) package name = packageName ifTrue: [
				(actors includes: name) ifFalse: [ actors add: name ] ]]
]

{ #category : 'experiments' }
MicroUMLSDForCode3 >> buildActorsOf: aTrace on: aBuilder [
	"Builds actors from a trace of method calls and adds them to the builder."

	| actors |
	actors := OrderedCollection new.
	aTrace do: [ :each |
			(actors includes: each first) ifFalse: [ actors add: each first ].
			(actors includes: each second) ifFalse: [ actors add: each second ]].
	actors do: [ :actor | aBuilder , actor ].
]

{ #category : 'as yet unclassified' }
MicroUMLSDForCode3 >> checkAdd: next to: traces [
	traces reverseDo: [ :trac |
		next allButLast = trac allButLast
			ifTrue: [ ^ next fourth ~= trac fourth ].
	 ].
	^true
]

{ #category : 'as yet unclassified' }
MicroUMLSDForCode3 >> checkCurrent: current [
	"{ from. method class. method selector }"

	| sender receiver method res |
	sender := current sender.
	receiver := current method.
	method := current method.
	res := [
		       ([ method methodClass package name ] onErrorDo: [ '*' ]) = packageName and: [
				       ([ sender methodClass package name ] onErrorDo: [ '*' ]) = packageName or: [
					       ([ receiver methodClass package name ] onErrorDo: [ '*' ]) = packageName ] ] ] 
				onErrorDo: [ false ].
	^ res
]

{ #category : 'testing' }
MicroUMLSDForCode3 >> isReturn: current [
	^ (InstructionStream on: current method pc: current pc) willReturn
]

{ #category : 'experiments' }
MicroUMLSDForCode3 >> message: each on: builder [
	"Constructs a message in the builder based on the given trace entry, considering package criteria"

	"((Smalltalk classNamed: each first) package name = packageName )
		ifFalse: [ ^ self ]."
	
	each first = each second
		ifTrue: [
				each last
					ifFalse: [ builder & each first => each third ]
					ifTrue: [ builder & each first --> each third ] ]
		ifFalse: [
				each last
					ifFalse: [ builder & each first -> each second => each third ]
					ifTrue: [ builder & each second -> each first --> each third ] ].
]

{ #category : 'experiments' }
MicroUMLSDForCode3 >> types: aBlock inPackage: pName [
	|  currentList x |			
	packageName := pName.
	currentList := OrderedCollection new.
	thisContext runSimulated: aBlock  contextAtEachStep: [ :current |
			"currentList add: {current isReturn. current copy}."
			currentList add: current copy.
			].
	x := self astFromCurrentList: currentList.
	^ self astFromTrace: x.
]
