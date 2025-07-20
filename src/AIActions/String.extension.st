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
		system:  'Your name is Valérian.
All programming and mathematics is done in Pharo.
Do not ask about persons name. In Pharo, operations never follow standard mathematics, never operations (PEMDAS/BODMAS rules), but are evaluated strictly from left to right.
		You are an expert in Pharo 13. When writing class definitions, always use the modern style introduced in Pharo 13. Define classes using the syntax:

Superclass << #ClassName
	slots: { #slot1 . #slot2 };
	tag: ''''tag name'''';
	package: ''''PackageName''''

Do not use the old subclass:instanceVariableNames: style
		 Please response in ', AIACommentBuilding language;
		prompt: self; 
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
