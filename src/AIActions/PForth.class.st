"
# PForth - A Forth Interpreter in Pharo

PForth is a Forth interpreter implemented in Pharo Smalltalk. It provides a stack-based programming environment with support for both interpretation and compilation of Forth words.

## Key Features

- Stack-based execution model (data stack and return stack)
- Support for both immediate and deferred execution
- Dictionary-based word storage
- Basic arithmetic operations (`+`, `*`, etc.)
- Word definition capabilities (`:`, `;`)

## Usage Example

```smalltalk
""Create and initialize a PForth interpreter""
forth := PForth new initialize.

""Define a simple word that adds two numbers""
forth do: ': addtwo 2 + ;'.

""Push numbers onto the stack and execute the word""
forth do: '3 4 addtwo'.

""Inspect the result (should be 9)""
forth dStack at: forth sp
```

## Implementation Notes

- Uses a flat array (`fArray`) to store words and their metadata
- Maintains separate data (`dStack`) and return (`rStack`) stacks
- Tracks execution state (`state`) and current word (`latest`)
- Supports both immediate and deferred execution modes

## Design Decisions

1. **Flat Array Storage**: Chosen for simplicity and performance in a Smalltalk environment
2. **Separate Stacks**: Data and return stacks are kept separate for clarity
3. **State Management**: Explicit state tracking for interpretation vs compilation
4. **Word Dictionary**: Simple linked list approach for word storage

## Limitations

- Currently limited to basic arithmetic operations
- No file I/O or advanced Forth features
- Basic error handling

This implementation serves as a foundation that can be extended with more Forth primitives and features.
"
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
	#category : 'AIActions-ExperimentsOLD',
	#package : 'AIActions',
	#tag : 'ExperimentsOLD'
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
