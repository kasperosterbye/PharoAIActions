Extension { #name : 'CompiledMethod' }

{ #category : '*AIActions' }
CompiledMethod >> aiaBlackComment [
	^ (AIAMethodComment new aiaBlackComment: self) response.
]

{ #category : '*AIActions' }
CompiledMethod >> aiaComment [
	^ (AIAMethodComment new aiaComment: self) response.
]

{ #category : '*AIActions' }
CompiledMethod >> setAIAComment [
	^ AIAMethodComment new setComment: self.
]

{ #category : '*AIActions' }
CompiledMethod >> setBlackComment [
	^ AIAMethodComment new setBlackComment: self.
]
