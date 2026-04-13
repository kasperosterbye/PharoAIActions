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

{ #category : 'as yet unclassified' }
MicroUMLSDForCode4 class >> on: block inPackage: pack [
self halt. 
	self new types: block inPackage: pack
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast10CurrentList: currentList [
	|  next |
	actions := OrderedDictionary new.
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
	messages reverseDo: [ :trac |
		next allButLast = trac allButLast
			ifTrue: [ ^ next fourth ~= trac fourth ].
	 ].
	^true
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast20Messages [
	| me |
	me := self class name.
	messages := messages select: [ :m | m first name ~= me and: [ m second name ~= me ] ].
	messages do: [ :message |
		 message first package name = packageName  ifTrue: [ 
			actions at: message first name asString put: message first ].
		message second package name = packageName ifTrue: [ 
			actions at: message second name asString put: message second ] ].
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast40Build [

	astBuilder := MicroUMLSDAstBuilder new. 
	self ast43BuildActors.
	self ast46BuildMessages.
	MicroUMLSequenceDiagram from: astBuilder .
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast43BuildActors [
	astBuilder , 'O'. "Omverdenen"
	actions do: [ :actorClass | 
		astBuilder , actorClass name asString ].
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast46BuildMessages [

	| firstPackage secondPackage |
	messages do: [ :message |
			firstPackage := message first package name.
			secondPackage := message second package name.
			(firstPackage ~= packageName or: [ secondPackage ~= packageName ])
				ifTrue: [ self ast47Message: message ]
				ifFalse: [ self ast48Message: message ] ]
]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast47Message: each [
	| firstPackage secondPackage |
	firstPackage := each first package name.
	secondPackage := each second package name.
	firstPackage ~= packageName 
		ifTrue: [ 
			each last
					ifFalse: [ astBuilder & 'O' -> each second name => each third. ]
					ifTrue: [ astBuilder & each second name -> 'O' --> each third ]].

]

{ #category : 'internals' }
MicroUMLSDForCode4 >> ast48Message: each [
	each first = each second
		ifTrue: [
				each last
					ifFalse: [ astBuilder & each first name => each third ]
					ifTrue: [ astBuilder & each first name --> each third ] ]
		ifFalse: [
				each last
					ifFalse: [ astBuilder & each first name -> each second name => each third ]
					ifTrue: [ astBuilder & each second name -> each first name --> each third ] ].
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
