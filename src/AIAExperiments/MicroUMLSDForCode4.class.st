Class {
	#name : 'MicroUMLSDForCode4',
	#superclass : 'Object',
	#instVars : [
		'packageName'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'examples' }
MicroUMLSDForCode4 class >> example1 [
	<example>
	self new types: [ Exp1 exp1Method1: 7. 2 timesRepeat: [ Exp2 new exp2Method1: 17]  ] inPackage: 'AIAExperiments'.
]

{ #category : 'examples' }
MicroUMLSDForCode4 class >> example2 [
	<example>
	self new types: [ Microdown asRichText: '## Joe' ] inPackage: 'Microdown'
]

{ #category : 'examples' }
MicroUMLSDForCode4 class >> example3 [
	<example>
	self new types: [ AIASourceCode forClass: MicroUMLSDForCode  ] inPackage: 'AIActions'
]

{ #category : 'examples' }
MicroUMLSDForCode4 class >> example4 [
	<example>
	self new types: [ Exp3 new exp3Method2 ] inPackage: 'AIActions'
]

{ #category : 'as yet unclassified' }
MicroUMLSDForCode4 class >> on: block inPackage: pack [
	self new types: block inPackage: pack
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast10CurrentList: currentList [
	| traces experiments next i |
	traces := OrderedCollection new.
	experiments := OrderedCollection new.
	i := 1.
	currentList do: [ :current |
		(self ast12Current: current )
			ifTrue: [ 
				next := { current sender methodClass name. current method methodClass name. 
							 current method selector . current isReturn}  .
				(self ast15Add: next to: traces)
							ifTrue: [ 
								traces add: next. "self halt." 
								experiments add: (next , { current method selector, ' # ', i asString } )]
				 ].
			i := i + 1.
		 ].
	^ traces 
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast12Current: current [
	| sender  method res |
	sender := current sender.
	method := current method.
	res := [
		       ([ method methodClass package name ] onErrorDo: [ '*' ]) = packageName" and: [
				       ([ sender methodClass package name ] onErrorDo: [ '*' ]) = packageName or: [
					       ([ receiver methodClass package name ] onErrorDo: [ '*' ]) = packageName ] ]" ] 
				onErrorDo: [ false ].
	^ true
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast15Add: next to: traces [
	"Determines whether a trace entry should be added by checking it is not a duplicate with the same return flag"
	traces reverseDo: [ :trac |
		next allButLast = trac allButLast
			ifTrue: [ ^ next fourth ~= trac fourth ].
	 ].
	^true
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast20Trace: traces [
	"Constructs an abstract syntax tree from a trace of method calls."

	| builder |
	builder := MicroUMLSDAstBuilder new.
	self ast23ActorsOf: traces on: builder.

	"builder & aTrace first first -> aTrace first second => aTrace first third."
	traces  do: [ :trace |
			self ast26Message: trace on: builder ].

	"builder & aTrace last second -> aTrace last first --> '***'."
	MicroUMLSequenceDiagram from: builder
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast23ActorsOf: aTrace on: aBuilder [
	"Builds actors from a trace of method calls and adds them to the builder."

	| actors |
	actors := OrderedCollection new.
	aTrace do: [ :each |
			(actors includes: each first) ifFalse: [ actors add: each first ].
			(actors includes: each second) ifFalse: [ actors add: each second ]].
	actors do: [ :actor | aBuilder , actor ].
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast26Message: each on: builder [
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

{ #category : 'internals' }
MicroUMLSDForCode4 >> old_ast10CurrentList: currentList [
	| traces experiments next i |
	traces := OrderedCollection new.
	experiments := OrderedCollection new.
	i := 1.
	currentList do: [ :current |
		(self ast12Current: current )
			ifTrue: [ 
				next := { current sender methodClass name. current method methodClass name. 
							 current method selector . current isReturn}  .
				(self ast15Add: next to: traces)
							ifTrue: [ 
								traces add: next. "self halt." 
								experiments add: (next , { current method selector, ' # ', i asString } )]
				 ].
			i := i + 1.
		 ].
	^ traces 
]

{ #category : 'external' }
MicroUMLSDForCode4 >> types: aBlock inPackage: pName [
	|  currentList traces |			
	packageName := pName.
	currentList := OrderedCollection new.
	thisContext runSimulated: aBlock  contextAtEachStep: [ :current |
			"currentList add: {current isReturn. current copy}."
			currentList add: current copy.
			].
	traces := self ast10CurrentList: currentList.
	^ self ast20Trace: traces.
]
