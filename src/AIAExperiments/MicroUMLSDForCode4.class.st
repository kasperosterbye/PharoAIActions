Class {
	#name : 'MicroUMLSDForCode4',
	#superclass : 'Object',
	#instVars : [
		'packageName',
		'actions',
		'messages',
		'astBuilder'
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

{ #category : 'examples' }
MicroUMLSDForCode4 class >> example5 [
	<example>
	self new rawTypes: [ 'abcd' last] inPackage: ''
]

{ #category : 'as yet unclassified' }
MicroUMLSDForCode4 class >> on: block inPackage: pack [
	self new types: block inPackage: pack
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast10CurrentList: currentList [
	"Processes a list of current contexts to generate a trace of method calls, filtering based on package criteria."
	|  next |
	messages := OrderedCollection new.
	currentList do: [ :current |
		(self ast12CheckCurrent: current )
			ifTrue: [ 
				next := { current sender methodClass. current method methodClass . 
							 current method selector . current isReturn}  .
				(self ast15AddTest: next ) ifTrue: [ messages add: next. ]
				 ].
		 ].
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast12CheckCurrent: current [
	"Checks if the current method or its sender is in the specified package."
	| sender  method res |
	sender := current sender.
	method := current method.
	res := [ 
		    	([ sender methodClass package name ] onErrorDo: [ '*' ]) = packageName or: [
				([ method methodClass package name ] onErrorDo: [ '*' ]) = packageName ] ] 
			onErrorDo: [ false ] .
	^ res
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast15AddTest: next [ 
	"Determines whether a trace entry should be added by checking it is not a duplicate with the same return flag"
	messages reverseDo: [ :trac |
		next allButLast = trac allButLast
			ifTrue: [ ^ next fourth ~= trac fourth ].
	 ].
	^true
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast20Messages [
	"Constructs an abstract syntax tree from a trace of method calls."

	messages 
		ifNotEmpty: [ self ast30Actions]
		ifEmpty: [ 
			RSCanvas new
				add: (RSLabel new text: 'Empty Sequence Diagram');
				open
			
			 ]	
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast20Trace [
	"Constructs an abstract syntax tree from a trace of method calls."

	| builder |
	self halt.
	messages 
		ifNotEmpty: [
			builder := MicroUMLSDAstBuilder new.
			messages  do: [ :message |
				self ast30Actions: message  ].
			MicroUMLSequenceDiagram from: builder ]
		ifEmpty: [ 
			RSCanvas new
				add: (RSLabel new text: 'Empty Sequence Diagram');
				open
			
			 ]	
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast26Message: each on: builder [
	"Constructs a message in the builder based on the given trace entry, considering package criteria"
	| firstPackage secondPackage |
	firstPackage := each first package name.
	secondPackage := each second package name.
	((firstPackage ~= packageName ) or: [ secondPackage ~= packageName  ])
		ifTrue: [ self ast27Message: each on: builder ]
		ifFalse: [  self ast28Message: each on: builder ]
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast27Message: each on: builder [
	| firstPackage secondPackage |
	firstPackage := each first package name.
	secondPackage := each second package name.
	firstPackage ~= packageName 
		ifTrue: [ 
			each last
					ifFalse: [ builder & 'O' -> each second name => each third. ]
					ifTrue: [ builder & each second name -> 'O' --> each third ]].
	"secondPackage ~= packageName 
		ifTrue: [ builder & each first name => each third. ^ self]."

]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast28Message: each on: builder [
	each first = each second
		ifTrue: [
				each last
					ifFalse: [ builder & each first name => each third ]
					ifTrue: [ builder & each first name --> each third ] ]
		ifFalse: [
				each last
					ifFalse: [ builder & each first name -> each second name => each third ]
					ifTrue: [ builder & each second name -> each first name --> each third ] ].
]

{ #category : 'as yet unclassified' }
MicroUMLSDForCode4 >> ast30Actions [
	| allActions |
	allActions := OrderedDictionary new.
	messages do: [ :message |
		allActions add: message first name -> message first name
		].
	actions := allActions 
]

{ #category : 'as yet unclassified' }
MicroUMLSDForCode4 >> ast40Build [
	"set the actions based on messages,
	then 
	1) build the actions
	2) buld the messages"
	astBuilder := MicroUMLSDAstBuilder new.
	self ast43BuildActors.
	self halt.
	MicroUMLSequenceDiagram from: 'builder'.
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast43ActorsOf: aTrace [ 
	"Builds actors from a trace of method calls and adds them to the builder."

	| actors |
	actors := OrderedCollection new.
	astBuilder , 'O'.
	aTrace do: [ :each |
			self xxx_ast24Add: each first to: actors.
			self xxx_ast24Add: each second to: actors].
	actors do: [ :actor | astBuilder , actor ].
]

{ #category : 'as yet unclassified' }
MicroUMLSDForCode4 >> ast43BuildActors [
	actions do: [ :actor | astBuilder , actor ].
]

{ #category : 'external' }
MicroUMLSDForCode4 >> types: aBlock inPackage: pName [
	|  currentList  |			
	packageName := pName.
	currentList := OrderedCollection new.
	thisContext runSimulated: aBlock  contextAtEachStep: [ :current |
			currentList add: current copy.
			].
	self ast10CurrentList: currentList.
	self ast20Messages.
	self ast40Build.
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> xxx_ast15Add: next to: traces [
	"Determines whether a trace entry should be added by checking it is not a duplicate with the same return flag"
	traces reverseDo: [ :trac |
		next allButLast = trac allButLast
			ifTrue: [ ^ next fourth ~= trac fourth ].
	 ].
	^true
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> xxx_ast20Messages: traces [
	"Constructs an abstract syntax tree from a trace of method calls."

	| builder |
	traces 
		ifNotEmpty: [
			builder := MicroUMLSDAstBuilder new.
			"self ast23ActorsOf: traces on: builder."
			traces  do: [ :trace |
				self ast26Message: trace on: builder  ].
			MicroUMLSequenceDiagram from: builder ]
		ifEmpty: [ 
			RSCanvas new
				add: (RSLabel new text: 'Empty Sequence Diagram');
				open
			
			 ]	
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> xxx_ast23ActorsOf: aTrace on: aBuilder [
	"Builds actors from a trace of method calls and adds them to the builder."

	| actors |
	actors := OrderedCollection new.
	aBuilder , 'O'.
	aTrace do: [ :each |
			self xxx_ast24Add: each first to: actors.
			self xxx_ast24Add: each second to: actors].
	actors do: [ :actor | aBuilder , actor ].
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> xxx_ast24Add: element to: actors [
	
	((actors includes: element) not and: [ element package name = packageName ])
		ifTrue: [ actors add: element name ]
]
