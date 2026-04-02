Class {
	#name : 'MicroUMLSDFoo',
	#superclass : 'Object',
	#instVars : [
		'packageName',
		'fromPrev'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'experiments' }
MicroUMLSDFoo >> astFromTrace: aTrace [
	"Transforms a flat execution trace into a MicroUMLSDAstBuilder"

	| builder |
	builder := MicroUMLSDAstBuilder new.
	self buildActorsOf: aTrace on: builder.

	builder & aTrace first first -> aTrace first second => aTrace first third.
	2 to: aTrace size - 1 do: [ :index |
	(aTrace at: index) first ~= 'UndefinedObject' ifTrue: [ self message: (aTrace at: index) on: builder ] ].

	builder & aTrace last second -> aTrace last first --> ''.
	MicroUMLSequenceDiagram from: builder
]

{ #category : 'experiments' }
MicroUMLSDFoo >> buildActorName: name on: actors [

	| pName |
	pName := (Smalltalk classNamed: name) package name.
	pName = packageName or: [ pName = 'UndefinedObject' ].
	((pName = packageName) or: [ pName = 'UndefinedObject' ])
				ifTrue: [actors add: name ]
]

{ #category : 'experiments' }
MicroUMLSDFoo >> buildActorsOf: aTrace on: aBuilder [

	| actors |
	actors := OrderedCollection new.
	aTrace do: [ :each |
			self buildActorsOf: each first on: actors.
			self buildActorsOf: each second on: actors ].
	actors do: [ :actor | aBuilder , actor second ]
]

{ #category : 'experiments' }
MicroUMLSDFoo >> checkActorName: addition [

	| x |
	x := (Smalltalk classNamed: addition) package name.
	^ x = packageName or: [ x = 'UndefinedObject' ]
]

{ #category : 'experiments' }
MicroUMLSDFoo >> fooMessages: traces [
	| foo index line pName trace|
	foo := OrderedCollection new.
	foo add: traces first.
	index := 2.
	[ index < traces size ] whileTrue: [ 
		line := (traces at: index ).
		pName := (Smalltalk classNamed: line second) package name.
		(pName = packageName )
			ifTrue: [ foo add: line. index := index + 1 ]
			ifFalse: [ 
				trace := line.
				index := index + 1.
				[ index < traces size and: [ 
					line := (traces at: index ).
					pName := (Smalltalk classNamed: line second) package name.
					pName = packageName 
					 ] 
				] whileFalse: [ 
					index := index + 1 ].
				trace at: 3 put: ( (trace at: 3),' ... ', (line at: 3) ).
				foo add: {trace first. line second. trace third. line fourth.}
			]
	 ].
	^ foo
]

{ #category : 'experiments' }
MicroUMLSDFoo >> message: each on: builder [

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
MicroUMLSDFoo >> reduceDuplicateTraces: trace [
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
MicroUMLSDFoo >> removeNonPackageTraces: traces [
| reducedTraces |
	reducedTraces := OrderedCollection new.
	traces do: [ :trace |
		| pName1 pName2 |
		pName1 := (Smalltalk classNamed: trace first) package name.
		pName2 := (Smalltalk classNamed: trace second) package name.
		(pName1 = packageName or: [ pName2 = packageName ])
			ifTrue: [reducedTraces add: trace ]
			ifFalse: [ self halt. ] ].
	^ reducedTraces 
]

{ #category : 'experiments' }
MicroUMLSDFoo >> types: aBlock inPackage: pName [

	| traces |
	packageName := pName.
	traces := OrderedCollection new.
	thisContext sender runSimulated: aBlock contextAtEachStep: [ :current |
			| from to sel isReturn next |
			from := current sender methodClass.
			to := current method methodClass.
			sel := current selector.
			isReturn := (InstructionStream on: current method pc: current pc) willReturn.
			((from package name = packageName) or: [ to package name = packageName ]) ifTrue:[
			next := {from name. to name. sel. isReturn }.
			traces add: next ]].
	traces := self reduceDuplicateTraces: traces.
	"trace := self removeNonPackageTraces: trace."
	traces := self fooMessages: traces.
	^ self astFromTrace: traces
]
