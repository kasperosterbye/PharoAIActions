Extension { #name : 'FluidClassDefinitionPrinter' }

{ #category : '*AIActions' }
FluidClassDefinitionPrinter >> slotDefinitionsOn: aStream [
	"If the class has many instance variable print one slot per line, do the same for complex slots."

	| oneSlotPerLine localSlots |
	"We could have the heuristics based on the sum of the slot name character length."
	oneSlotPerLine := false.
	localSlots := forClass localSlots.
	( localSlots size > 8 or: [ localSlots anySatisfy: [ :s | s needsFullDefinition ]])
		ifTrue: [ localSlots size = 1 ifFalse: [ oneSlotPerLine := true ] ].
	(AIASlotComment hasComments: forClass ) ifTrue: [ oneSlotPerLine := true. ].
	aStream nextPutAll: '{'.
	"To start aligned really nice when we have two complex slots"
	oneSlotPerLine ifTrue: [
		self slotShiftOn: aStream ].
	localSlots
		do: [ :slot |
			aStream space.
			aStream nextPutAll: slot definitionString.
			aStream << (AIASlotComment slotCommentFor: slot in: forClass).
			oneSlotPerLine := slot needsFullDefinition | oneSlotPerLine.
			aStream space ]
		separatedBy: [
			aStream nextPutAll: '.'.
			oneSlotPerLine ifTrue: [ self slotShiftOn: aStream ] ].
	aStream nextPutAll: '}'
]
