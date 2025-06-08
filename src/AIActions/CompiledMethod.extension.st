Extension { #name : 'CompiledMethod' }

{ #category : '*AIActions' }
CompiledMethod >> aiaComment [
	^ (AIAMethodComment new aiaComment: self) response.
]

{ #category : '*AIActions' }
CompiledMethod >> aiaWhiteComment [
	^ (AIAMethodComment new aiaWhiteComment: self) response.
]

{ #category : '*AIActions' }
CompiledMethod >> setAIAComment [
	^ AIAMethodComment new setComment: self.
]

{ #category : '*AIActions' }
CompiledMethod >> setWhiteComment [
	^ AIAMethodComment new setWhiteComment: self.
]
