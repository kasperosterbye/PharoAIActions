Extension { #name : 'Behavior' }

{ #category : '*AIActions' }
Behavior >> addAIBasedComments [
	"Adds AI/Ollama based comments to my instance variables and methods"

	(AI_CommentBuilding commentClass: self) extendClassWithComments
]
