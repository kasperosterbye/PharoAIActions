Extension { #name : 'MicSemanticAction' }

{ #category : '*AIAExperiments' }
MicSemanticAction >> getTagOrNil [

	| tagName |
	tokens first ifNil: [ ^ entity := nil ].
	tagName := tokens first asSymbol.
	self class packageOrganizer packages do: [ :package |
		(tagName beginsWith: package name) ifTrue: [
			package tags do: [ :tag |
				package name , '-' , tag name = tagName ifTrue: [
					entity := tag.
					^ entity ] ] ] ].
	entity := nil.
	^ entity
]
