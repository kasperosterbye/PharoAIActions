Extension { #name : 'Class' }

{ #category : '*AIActions' }
Class >> aiaComment [
	^ (AIAClassComment new aiaComment: self) response
]

{ #category : '*AIActions' }
Class >> setAIAComment [
	AIAClassComment new setComment: self
]

{ #category : '*AIActions' }
Class >> uml [
	| uml aiModel|
	aiModel := AilienApi provider.
	AilienApi provider: GrokApi .
	uml := ('Can you make a PlantUML classes diagram only containing the class and its variable, not it methods. I would like the diagram to have {1} class as its root, and include its superclases, subclasses and those classes that uses it. Only include methods difines in its own class. Only include the result, no explanation. no fence' format: { self name asString}) q: [   AIASourceCodeBuilder new forClass: self] .
	AIAPlantUML umlToImage: uml.
	AilienApi provider: aiModel 
]
