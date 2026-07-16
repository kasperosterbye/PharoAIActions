Class {
	#name : 'PForth',
	#superclass : 'Object',
	#instVars : [
		'fArray',
		'dStack',
		'sp',
		'rStack',
		'rp',
		'state',
		'latest',
		'here',
		'tip',
		'tin'
	],
	#category : 'AIAZipArchive-AlgorithmicCore',
	#package : 'AIAZipArchive',
	#tag : 'AlgorithmicCore'
}

{ #category : 'private' }
PForth >> booter [ 
	| cfaWords |
	cfaWords := self class selectorsInProtocol: 'CFA'.
	cfaWords do: [ :cfa |
		fArray at: here put: latest.
		fArray at: here + 1 put: ( self class >> cfa asSymbol) ast pragmas first arguments first value.
		fArray at: here + 2 put: #Pharo.
		fArray at: here + 3 put: ( self class >> cfa asSymbol).
		latest := here + 1.
		here := here + 4.
		
		 ]
	
]

{ #category : 'private' }
PForth >> compileState: foo [
	self error.
]

{ #category : 'private' }
PForth >> do: aString [
	| words |
	words := aString substrings.
	words do: [ :word | 
		self wordAction: word
		 ]
]

{ #category : 'private' }
PForth >> doInteger: integer [
	sp := sp + 1.
	dStack at: sp put: integer.
]

{ #category : 'CFA' }
PForth >> fAdd [
	<forth: '+'>
	sp := sp - 1.
	dStack at: sp put: (dStack at: sp) + (dStack at: sp + 1)
]

{ #category : 'CFA' }
PForth >> fColon [
	<forth: ':'>
]

{ #category : 'CFA' }
PForth >> fDot [
	<forth: '.'>
	
	sp := sp - 1.
	self inspect.	
]

{ #category : 'CFA' }
PForth >> fInteger: int [
	<forth: ' lit'>
	sp := sp + 1.
	dStack at: sp put: int
]

{ #category : 'CFA' }
PForth >> fMultiply [
	<forth: '*'>
	sp := sp - 1.
	dStack at: sp put: (dStack at: sp) * (dStack at: sp + 1)
]

{ #category : 'CFA' }
PForth >> fSemicolon [
	<forth: ';'>
]

{ #category : 'private' }
PForth >> fibbe [ 
	^88
]

{ #category : 'initialization' }
PForth >> initialize [
	fArray := Array new: 1000. 
	dStack := Array new: 100. 
	sp := 0.
	rStack := Array new: 100. 
	rp := 0.
	state := #InterpretState. "or #CompileState"
	latest := 0.
	here := 1. "First free element in array, in Pharo, arrays start at 1, not 0"
	
]

{ #category : 'private' }
PForth >> interpretState: index [
	(fArray at: index + 1) = #Pharo
		ifTrue: [ 
			(fArray at: index + 2 ) valueWithReceiver: self arguments: #() 
		]
]

{ #category : 'private' }
PForth >> wordAction: word [
	| location |
	location := latest.
	[ location > 0 and: [(fArray at: location) ~= word ] ] 
		whileTrue: [ location := fArray at: (location - 1) ].
	(location = 0 and: [ word asInteger isNotNil ]) ifTrue: [ 
		^ self doInteger: word asInteger.
		 ].
	
	state = #InterpretState
		ifTrue: [ self interpretState: location ]
		ifFalse:[ self compileState: location ]
]
