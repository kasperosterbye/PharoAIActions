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
CompiledMethod >> haiko [
	^ ('Chan you please make a Haiku. Use the rules of hakido you know. Make a haiko based on this Pharo method: ', self sourceCode ) q 
]

{ #category : '*AIActions' }
CompiledMethod >> setAIAComment [
	^ AIAMethodComment new setComment: self.
]

{ #category : '*AIActions' }
CompiledMethod >> setBlackComment [
	^ AIAMethodComment new setBlackComment: self.
]
