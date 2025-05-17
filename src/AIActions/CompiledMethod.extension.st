Extension { #name : 'CompiledMethod' }

{ #category : '*AIActions' }
CompiledMethod >> getAIComment [
	^ AIAMethodComment new getComment: self.
]
