Class {
	#name : 'MicroUMLSDForCodeRaw',
	#superclass : 'Object',
	#instVars : [
		'packageName'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'examples' }
MicroUMLSDForCodeRaw class >> example1 [
	<example>
	self new types: [ Exp1 exp1Method1: 7. 2 timesRepeat: [ Exp2 new exp2Method1: 17]  ] inPackage: 'AIAExperiments'.
]

{ #category : 'examples' }
MicroUMLSDForCodeRaw class >> example2 [
	<example>
	self new types: [ Microdown asRichText: '## Joe' ] inPackage: 'Microdown'
]

{ #category : 'examples' }
MicroUMLSDForCodeRaw class >> example3 [
	<example>
	self new types: [ AIASourceCode forClass: MicroUMLSDForCode  ] inPackage: 'AIActions'
]

{ #category : 'examples' }
MicroUMLSDForCodeRaw class >> example4 [
	<example>
	self new types: [ Exp3 new exp3Method2 ] inPackage: 'AIActions'
]

{ #category : 'examples' }
MicroUMLSDForCodeRaw class >> example5 [
	<example>
	self new rawTypes: [ 'abcd' last] inPackage: ''
]

{ #category : 'as yet unclassified' }
MicroUMLSDForCodeRaw class >> on: block inPackage: pack [
	self new types: block inPackage: pack
]

{ #category : 'internals' }
MicroUMLSDForCodeRaw >> ast50CurrentList: currentList [

	| traces  next message |
	traces := OrderedCollection new.
	currentList do: [ :current |
			message := current method selector, 
				' pc: ', current pc asString ,
				' s: ', current stackPtr asString,
				' c/n: ', (current closure ifNotNil: [ '[block]' ] ifNil: [ 'nil' ]).
			next := {
				        current sender methodClass name.
				        current method methodClass name.
				        message.
				        current isReturn }.
			traces add: next. "self halt." ].
	^ traces
]

{ #category : 'internals' }
MicroUMLSDForCodeRaw >> ast60RawTrace: traces [
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

{ #category : 'internals' }
MicroUMLSDForCodeRaw >> buildActorsOf: aTrace on: aBuilder [
	"Builds actors from a trace of method calls and adds them to the builder."

	| actors |
	actors := OrderedCollection new.
	aTrace do: [ :each |
			(actors includes: each first) ifFalse: [ actors add: each first ].
			(actors includes: each second) ifFalse: [ actors add: each second ]].
	actors do: [ :actor | aBuilder , actor ].
]

{ #category : 'internals' }
MicroUMLSDForCodeRaw >> checkAdd: next to: traces [
	traces reverseDo: [ :trac |
		next allButLast = trac allButLast
			ifTrue: [ ^ next fourth ~= trac fourth ].
	 ].
	^true
]

{ #category : 'internals' }
MicroUMLSDForCodeRaw >> checkCurrent: current [
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

{ #category : 'internals' }
MicroUMLSDForCodeRaw >> message: each on: builder [
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

{ #category : 'external' }
MicroUMLSDForCodeRaw >> rawTypes: aBlock inPackage: pName [
	|  currentList x |			
	packageName := pName.
	currentList := OrderedCollection new.
	thisContext runSimulated: aBlock contextAtEachStep: [ :current |
			currentList add: current copy.
			].
	x := self ast50CurrentList: currentList.
	^ self ast60RawTrace: x.
]
