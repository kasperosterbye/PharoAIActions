"
# Class Comment for `AIASlotComment`

`AIASlotComment` is a builder class designed to generate and manage comments for instance variables (slots) in Pharo classes. It leverages AI to automatically generate descriptive comments for each slot, including the expected class of the value and a brief explanation of its purpose.

## Key Features

- **AI-Powered Comment Generation**: Uses an AI model to generate slot comments based on the class context.
- **Slot Comment Storage**: Maintains a dictionary (`classSlotCommentDictionary`) to store and retrieve slot comments for different classes.
- **Usage in Playground**: Can be used interactively in the Pharo Playground to generate and inspect slot comments.

## Usage Example

```st
""Example: Generate and inspect slot comments for a class""
| builder comments |
builder := AIASlotComment new.
builder for: Point. ""Generate comments for the Point class""
comments := builder classSlotCommentDictionary at: Point. ""Retrieve the generated comments""
comments inspect. ""Inspect the dictionary of slot comments""
```

## Design Decisions

- **Fluid Syntax**: Designed to work with Pharo's fluid syntax for scripting and interactive use.
- **Non-Invasive**: Does not modify or install classes; relies on `ShiftClassInstaller` for installation.
- **Extensibility**: Can be extended with different builder enhancers (e.g., `ShDefaultBuilderEnhancer`).
- **Comparison Capability**: Can compare old and new class configurations to determine required changes.
- **Anonymous Class Support**: Can build anonymous classes, though it is recommended to use the anonymous class installer.

## Future Improvements

- Revisit the need for fluid class builders and align APIs with class default values.
- Reduce unnecessary conversions between class information formats.

This class is part of the `AIActions` package and is tagged as `CommentBuilder`.`
"
Class {
	#name : 'AIASlotComment',
	#superclass : 'AIACommentBuilding',
	#classInstVars : [
		'classSlotCommentDictionary'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'accessing' }
AIASlotComment class >> classSlotCommentDictionary [
	classSlotCommentDictionary ifNil: [ self initialize ].
	^ classSlotCommentDictionary 
]

{ #category : 'instance creation' }
AIASlotComment class >> for: aClass [
	"Generates AI comments for a class's instance variables. Uses a prompt to request comments from an AI model, then stores them in a dictionary."

	|  response slotsCollection|
	
	classSlotCommentDictionary ifNil: [ self initialize ].
	response := (self promptFor: aClass) q: [ AIASourceCodeBuilder new forClass: aClass ].
	response := response lines.
	(response first beginsWith: '```') ifTrue: [
		response := response copyFrom: 2 to: response size - 1].
	
	slotsCollection := (response collect: [ :f |
				OpalCompiler new
				        source: f;
				        evaluate ]) asDictionary.
	classSlotCommentDictionary 
		at: aClass 
		put: slotsCollection .
]

{ #category : 'instance creation' }
AIASlotComment class >> hasComments: aClass [
	self classSlotCommentDictionary at: aClass ifAbsent: [ ^ false ].
	^ true
]

{ #category : 'initialization' }
AIASlotComment class >> initialize [
	classSlotCommentDictionary := Dictionary new.
]

{ #category : 'instance creation' }
AIASlotComment class >> promptFor: aClass [
	"Generates a prompt for AI to create comments for a class's instance variables. Returns a formatted string with the class name."

	| prompt |
	prompt := 'For each instance variable in class {1} and only for that class, write a comment in the format:

#varName -> ''=> Class. Short description...''

Include the exact class name of the value each variable holds, and a brief explanation of its purpose. Just return the instance variables, not the class own definition.'.
	^ prompt format: { aClass name }.
]

{ #category : 'instance creation' }
AIASlotComment class >> slotCommentFor: slot in: aClass [
	| shots slotComment |
	shots := classSlotCommentDictionary at: aClass ifAbsent: [ ^ '' ].
	slotComment := shots at: slot name asString ifAbsent: [ ^ 'undefined.' ].
	^ ' " {1}"' format: {slotComment}
]
