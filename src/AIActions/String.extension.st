Extension { #name : 'String' }

{ #category : '*AIActions' }
String >> getAIComment [
	| package |
	package := (PackageOrganizer default packageNamed: self ifAbsent: [^ 'No package named: ', self]).
	^ AIAPackageComment new getComment: self
]

{ #category : '*AIActions' }
String >> q [
	"Q is short for query. It asks the Mistral AI for a response to self"
	(MistralApi new getResponseForPrompt: self) inspect
]
