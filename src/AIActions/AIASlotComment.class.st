"
# AIASlotComment

`AIASlotComment` is a specialized comment builder that generates AI-driven documentation for instance variables in Pharo classes. It utilises an AI model to create concise, type-annotated comments that describe the purpose and expected type of each slot.

## Key Features

- **AI-Powered Generation**: Automatically generates comments using an AI model, ensuring consistency and relevance.
- **Type Annotations**: Includes the class name of the slot's value in the comment for clarity.
- **Dictionary Storage**: Maintains a dictionary of comments keyed by class and slot name for quick access.
- **Fluid Interface**: Provides a clean API for generating and retrieving slot comments.

## Usage Example

```st
""Generate and inspect AI comments for a class's slots""
AIASlotComment for: Point.
AIASlotComment slotCommentFor: #x in: Point
```

## Design Considerations

- **Non-Invasive**: Does not modify or install classes; focuses solely on comment generation.
- **Extensible**: Can be extended to support additional comment types or languages.
- **Integration**: Works seamlessly with existing Pharo class structures.

This builder is particularly useful for maintaining consistent documentation across large codebases, reducing manual effort while ensuring accuracy.
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
	"Generates comments for instance variables of a class, using AI."
	|  response comments slotsCollection|
	
	classSlotCommentDictionary ifNil: [ self initialize ].
	response := (self promptFor: aClass) q: [ AIASourceCodeBuilder new forClass: aClass ].
	response := response lines.
	comments := OrderedCollection new.
	response do: [ :resp |
		(resp beginsWith: '#') ifTrue: [ 
			comments add: (resp copyReplaceAll: '"' with: '""') ]].
	slotsCollection := (comments collect: [ :f |
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

#varName -> ''=> Class. Short description, around 40 charcters''

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
