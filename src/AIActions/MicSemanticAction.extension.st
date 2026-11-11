Extension { #name : 'MicSemanticAction' }

{ #category : '*AIActions' }
MicSemanticAction >> getTagOrNil [

	| tagName |
	tagName := tokens first asString asSymbol.
	self class packageOrganizer packages do: [ :package |
		(tagName beginsWith: package name) ifTrue: [
			package tags do: [ :tag |
				package name , '-' , tag name = tagName ifTrue: [
					entity := tag.
					^ entity ] ] ] ].
	entity := nil.
	^ entity
]
