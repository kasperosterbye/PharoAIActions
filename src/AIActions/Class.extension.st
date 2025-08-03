Extension { #name : 'Class' }

{ #category : '*AIActions' }
Class >> aiInstanceVariables [
	^ ('What is the type of the instance variable in the class {1}. List only the variable names and types, one per line. Do not explain, introduce, or use bullets.' format: { self }) q: [AIASourceCodeBuilder new forClass: self.].
]

{ #category : '*AIActions' }
Class >> aiaComment [
	^ (AIAClassComment new aiaComment: self) response
]

{ #category : '*AIActions' }
Class >> setAIAComment [
	AIAClassComment new setComment: self
]
