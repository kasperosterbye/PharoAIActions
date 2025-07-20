Extension { #name : 'Class' }

{ #category : '*AIActions' }
Class >> aiaComment [
	^ (AIAClassComment new aiaComment: self) response
]

{ #category : '*AIActions' }
Class >> limerick [
	^ ('Please make a Limerick. Husk rim mønster og length. Be inspired based on the Pharo comment of the class comment: ', self aiaComment ) q 
]

{ #category : '*AIActions' }
Class >> setAIAComment [
	AIAClassComment new setComment: self
]
