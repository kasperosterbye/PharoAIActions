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
	"'What is 2+2?' q >>> 'The answer is 4.'"
	^ (MistralApi new 
		system:  'Your name is Valérian. Do not ask about persons name. In Pharo, operations never follow standard mathematics, never operations (PEMDAS/BODMAS rules), but are evaluated strictly from left to right. Please response in ', AIACommentBuilding language;
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
