Extension { #name : 'String' }

{ #category : '*AIActions' }
String >> aiaComment [
	| package |
	(self beginsWith: '*')
		ifTrue: [ 
			^  (PackageOrganizer default packages 
				select: [:p| p name beginsWith: self copyWithoutFirst ] 
				thenCollect: #name) aiaComment ]
		ifFalse: [
			package := PackageOrganizer default 
				packageNamed: self 
				ifAbsent: [^ 'No package named: ', self].
				^ (AIAPackageComment new aiaComment: self) response
		].
	
]

{ #category : '*AIActions' }
String >> q [
	^ (MistralApi new 
		system:  'You are a Pharo Smalltalk expert. In Pharo, operations are evaluated left to right without operator precedence.
		 Please response in ', AIACommentBuilding language;
		prompt: self, '
		 Please response in ', AIACommentBuilding language; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q: systemBlock [
	^ (MistralApi new 
		system:  systemBlock value;
		prompt: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> setAIAComment [
	AIAPackageComment new setComment: self
]
