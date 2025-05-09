Extension { #name : 'String' }

{ #category : '*AIActions' }
String >> q [
	"Q is short for query. It asks the Mistral AI for a response to self"
	(MistralApi new getResponseForPrompt: self) inspect
]
