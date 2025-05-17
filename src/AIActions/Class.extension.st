Extension { #name : 'Class' }

{ #category : '*AIActions' }
Class >> getAIComment [
	^ AIAClassComment new getComment: self
]
