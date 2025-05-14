Extension { #name : 'Behavior' }

{ #category : '*AIActions' }
Behavior >> addAIBasedComments [
	"Adds AI/Ollama based comments to my instance variables and methods"

	(AIACommentBuilding commentClass: self) extendClassWithComments
]
