Extension { #name : 'Class' }

{ #category : '*AIActions' }
Class >> aiaComment [
	^ (AIAClassComment new aiaComment: self) response
]

{ #category : '*AIActions' }
Class >> setAIAComment [
	AIAClassComment new setComment: self
]
