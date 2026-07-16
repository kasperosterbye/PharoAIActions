"
# Class Comment for PForth

## Purpose and Role in the System

The `PForth` class is a Forth interpreter implemented in Pharo Smalltalk. Forth is a stack-based programming language that is known for its simplicity, efficiency, and extensibility. The `PForth` class provides a Forth environment within Pharo, allowing developers to write and execute Forth code directly within the Pharo environment. This can be particularly useful for educational purposes, embedded systems, and scenarios where a lightweight, efficient interpreter is required.

## Main Collaborators or Dependencies

The `PForth` class collaborates with several key components:

1. **Forth Array (`#fArray`)**: This array stores the Forth dictionary, which contains the definitions of Forth words.
2. **Data Stack (`#dStack`)**: This stack is used for storing data during the execution of Forth words.
3. **Return Stack (`#rStack`)**: This stack is used for storing return addresses and other control information.
4. **State Variables (`#state`, `#latest`, `#here`, `#tip`, `#tin`)**: These variables manage the state of the Forth interpreter, including the current state (interpret or compile), the latest word defined, and the current position in the Forth array.

## Important Invariants or Design Constraints

1. **Stack Management**: The interpreter must correctly manage the data and return stacks, ensuring that operations like push and pop are performed correctly.
2. **State Transitions**: The interpreter must handle transitions between interpret and compile states correctly, ensuring that words are executed or compiled as appropriate.
3. **Dictionary Management**: The Forth dictionary must be managed correctly, with words being added and retrieved efficiently.
4. **Error Handling**: The interpreter must handle errors gracefully, providing meaningful feedback when something goes wrong.

## Illustrative Usage Examples

### Example 1: Defining and Executing a Forth Word

```smalltalk
| forth |
forth := PForth new.
forth do: ': square dup * ;'.
forth do: '5 square .'.
```

In this example, a new Forth interpreter is created. The word `square` is defined to duplicate the top of the stack and multiply the two values. The word is then executed with the value `5`, resulting in `25` being printed.

### Example 2: Using the Forth Interpreter for Simple Calculations

```smalltalk
| forth |
forth := PForth new.
forth do: '5 3 + .'.
```

In this example, the Forth interpreter is used to perform a simple addition. The values `5` and `3` are pushed onto the stack, and the `+` word is executed to add them together. The result, `8`, is then printed.

## Conclusion

The `PForth` class provides a robust and efficient Forth interpreter within the Pharo environment. It is particularly useful for scenarios where a lightweight, stack-based programming language is required. The class is designed to be extensible, allowing developers to add new Forth words and functionality as needed.
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
