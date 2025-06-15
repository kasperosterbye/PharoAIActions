Extension { #name : 'String' }

{ #category : '*AIActions' }
String >> aiaComment [
	| package |
	package := PackageOrganizer default 
		packageNamed: self 
		ifAbsent: [^ 'No package named: ', self].
	^ (AIAPackageComment new aiaComment: self) response
]

{ #category : '*AIActions' }
String >> q [
	^ (MistralApi new 
		system:  'Your name is Valérian. Do not ask about persons name. ';
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
