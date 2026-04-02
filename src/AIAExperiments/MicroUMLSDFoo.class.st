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
		(aTrace at: index) first ~= 'UndefinedObject' ifTrue: [ 
			self message: (aTrace at: index) on: builder ] ].

	builder & aTrace last second -> aTrace last first --> ''.
	MicroUMLSequenceDiagram from: builder
]

{ #category : 'experiments' }
MicroUMLSDFoo >> buildActorName: name on: actors [

	name = 'UndefinedObject' 
		ifTrue: [ (actors includes: name) ifFalse: [ actors add: name ] ]
		ifFalse: [
			(Smalltalk classNamed: name) package name = packageName ifTrue: [
				(actors includes: name) ifFalse: [ actors add: name ] ]]
]

{ #category : 'experiments' }
MicroUMLSDFoo >> buildActorsOf: aTrace on: aBuilder [

	| actors |
	actors := OrderedCollection new.
	aTrace do: [ :each |
			self buildActorName: each first on: actors.
			self buildActorName: each second on: actors ].
	actors do: [ :actor | aBuilder , actor ]
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
			ifTrue: [ foo add: line ]
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
					index >= traces size ifTrue: [ ^ foo ] ].
				trace at: 3 put: ( (trace at: 3),' ... ', (line at: 3) ).
				foo add: {trace first. line second. trace third. line fourth.}.
			].
			index := index + 1.
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
	traces := self fooMessages: traces.
	traces := self removeNonPackageTraces: traces.
	^ self astFromTrace: traces
]
