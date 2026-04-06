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
	#name : 'MicroUMLSDForCode',
	#superclass : 'Object',
	#instVars : [
		'packageName'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'examples' }
MicroUMLSDForCode class >> example1 [
	<example>
	self  new types: [ Exp1 fibbe: 7  ] inPackage: 'AIAExperiments'.
]

{ #category : 'examples' }
MicroUMLSDForCode class >> example2 [
	<example>
	self  new types: [ Microdown asRichText: '## Joe' ] inPackage: 'Microdown'
]

{ #category : 'examples' }
MicroUMLSDForCode class >> example3 [
	<example>
	self  new types: [ AIASourceCode forClass: MicroUMLSDForCode  ] inPackage: 'AIActions'
]

{ #category : 'experiments' }
MicroUMLSDForCode >> astFromTrace: aTrace [
	"Constructs an abstract syntax tree from a trace of method calls."

	| builder |
	builder := MicroUMLSDAstBuilder new.
	self buildActorsOf: aTrace on: builder.

	builder & aTrace first first -> aTrace first second => aTrace first third.
	2 to: aTrace size - 1 do: [ :index |
		(aTrace at: index) first ~= 'UndefinedObject' ifTrue: [ 
			self message: (aTrace at: index) on: builder ] ].

	builder & aTrace last second -> aTrace last first --> ''.
	MicroUMLSequenceDiagram from: builder
]

{ #category : 'experiments' }
MicroUMLSDForCode >> buildActorName: name on: actors [
	"Builds an actor name from the given name and adds it to the actors collection if it is not already present and meets the package criteria."

	name = 'UndefinedObject' 
		ifTrue: [ (actors includes: name) ifFalse: [ actors add: name ] ]
		ifFalse: [
			(Smalltalk classNamed: name) package name = packageName ifTrue: [
				(actors includes: name) ifFalse: [ actors add: name ] ]]
]

{ #category : 'experiments' }
MicroUMLSDForCode >> buildActorsOf: aTrace on: aBuilder [
	"Builds actors from a trace of method calls and adds them to the builder."

	| actors |
	actors := OrderedCollection new.
	aTrace do: [ :each |
			self buildActorName: each first on: actors.
			self buildActorName: each second on: actors ].
	actors do: [ :actor | aBuilder , actor ]
]

{ #category : 'experiments' }
MicroUMLSDForCode >> checkUndefinedObjectOrPackage: item [
	^item = 'UndefinedObject' or: [ (Smalltalk classNamed: item) package name = packageName ]

]

{ #category : 'experiments' }
MicroUMLSDForCode >> connectMessages: traces [
	"Connects messages in a trace by linking them based on package criteria"
	| connections index line pName trace|
	connections := OrderedCollection new.
	connections add: traces first.
	index := 2.
	[ index < traces size ] whileTrue: [
		line := (traces at: index ).
		pName := (Smalltalk classNamed: line second) package name.
		(pName = packageName )
			ifTrue: [ connections add: line ]
			ifFalse: [ 
				trace := line.
				index := index + 1.
				[ index < traces size and: [ 
					line := (traces at: index ).
					pName := (Smalltalk classNamed: line second) package name.
					pName = packageName 
					 ] 
				] whileFalse: [ 
					index := index + 1.
					index >= traces size ifTrue: [ ^ connections ] ].
				trace at: 3 put: ( (trace at: 3),' ... ', (line at: 3) ).
				connections add: {trace first. line second. trace third. line fourth.}.
			].
			index := index + 1.
	 ].
	^ connections
]

{ #category : 'experiments' }
MicroUMLSDForCode >> message: each on: builder [
	"Constructs a message in the builder based on the given trace entry, considering package criteria"

	((Smalltalk classNamed: each first) package name = packageName )
		ifFalse: [ ^ self ].
	each first = each second
		ifTrue: [
				each last
					ifFalse: [ builder & each first => each third ]
					ifTrue: [ builder & each first --> '' ] ]
		ifFalse: [
				each last
					ifFalse: [ builder & each first -> each second => each third ]
					ifTrue: [ builder & each second -> each first --> '' ] ]
]

{ #category : 'removing' }
MicroUMLSDForCode >> old_removeNonPackageTraces: traces [
	"Removes traces not belonging to the specified package"

	| reducedTraces |
	reducedTraces := OrderedCollection new.
	reducedTraces add: traces first.
	(traces copyFrom: 2 to: traces size - 1) do: [ :trace |
			(Smalltalk classNamed: trace first) package name = packageName
				ifTrue: [ reducedTraces add: trace ]
				ifFalse: [ ] ].
	(traces last first = 'UndefinedObject' or: [ (Smalltalk classNamed: traces last first) package name = packageName ])
		ifTrue: [
			reducedTraces add: traces last].
	^ reducedTraces
]

{ #category : 'removing' }
MicroUMLSDForCode >> reduceDuplicateTraces: trace [
	"Removes duplicate traces from a collection, ensuring each trace is unique."
	| reducedTraces |
	reducedTraces := OrderedCollection new.
	reducedTraces add: trace first.
	2 to: trace size do: [ :index |
		((trace at: index ) ~= reducedTraces last) ifTrue: [ 
			reducedTraces add: (trace at: index)
			 ]
		 ].
	^ reducedTraces 
]

{ #category : 'removing' }
MicroUMLSDForCode >> removeNonPackageTraces: traces [
	"Removes traces not belonging to the specified package"

	| reducedTraces |
	reducedTraces := OrderedCollection new.
	traces do: [ :trace |
			(( self checkUndefinedObjectOrPackage: trace first) 
				and: [ self checkUndefinedObjectOrPackage: trace second ])
				ifTrue: [ reducedTraces add: trace ]].
	^ reducedTraces
]

{ #category : 'tests' }
MicroUMLSDForCode >> testClassPackage: package [
	"Determines if a package matches the specified package name criteria."
	package = 'UndefinedObject' 
		ifTrue: [ ^ true ].
	packageName isString 
		ifTrue: [ ^ packageName = package ].
	packageName isArray 
		ifTrue: [  ^ packageName includes: package ].
	packageName first = $* 
		ifTrue: [ ^ package beginsWith: (packageName allButFirst ) ].
	^ false
]

{ #category : 'tests' }
MicroUMLSDForCode >> testPackage: packOrClass [
	"Determines if a package or class matches the specified package name criteria."
	| package |
	package := packOrClass isString 
		ifTrue: [ packOrClass ] 
		ifFalse: [ (Smalltalk classNamed: packOrClass) package name.].
	package = 'UndefinedObject' 
		ifTrue: [ ^ true ].
	packageName isString 
		ifTrue: [ ^ packageName = package ].
	packageName isArray 
		ifTrue: [  ^ packageName includes: package ].
	packageName first = $* 
		ifTrue: [ ^ package beginsWith: (packageName allButFirst ) ].
	^ false
]

{ #category : 'experiments' }
MicroUMLSDForCode >> types: aBlock inPackage: pName [
	"Constructs an abstract syntax tree from a block of code, focusing on method calls within a specified package."

	| traces |
	packageName := pName.
	traces := OrderedCollection new.
	thisContext sender runSimulated: aBlock contextAtEachStep: [ :current |
			| from to sel isReturn next |
			from := current sender methodClass.
			to := current method methodClass.
			sel := current selector.
			isReturn := (InstructionStream on: current method pc: current pc) willReturn.
			"((from package name = packageName) or: [ to package name = packageName ]) ifTrue:["
			((self testClassPackage: from package name ) 
				or: [ self testClassPackage: to package name]) 
				ifTrue:[
					next := {from name. to name. sel. isReturn }.
					traces add: next ]].
	traces := self reduceDuplicateTraces: traces.
	traces := self connectMessages: traces.
	traces := self removeNonPackageTraces: traces.
	^ self astFromTrace: traces
]
