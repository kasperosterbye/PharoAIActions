Extension { #name : 'String' }

{ #category : '*AIActions' }
String >> L [
	^ (AIAHistory new
		system:  'You are one who like giving answers that are rather long, funny and rhymes. Always University in Lund';
		responseType: 'Please response in ', AIACommentBuilding language;
		user: self; 
		getResponse; 
		response) 
]

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
String >> d [
	^ (AIADiscussion current
		user: self;
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> l [
	^ (AIAHistory new
		system:  'You are one who like giving funny answers that are Limeric. Always include IT University in Lund as part of the response';
		responseType:'Please response in ', AIACommentBuilding language;
		user: self; 
		getResponse;
		response) 
]

{ #category : '*AIActions' }
String >> q [
	^ (AilienApi provider new
		system:  'You are a Pharo Smalltalk expert. In Pharo, operations, comparison operators, or in general  binary selectors are evaluated left to right without operator precedence. True and False er NOT numbers, but booleans.
		 Please response in ', AIACommentBuilding language;
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q0 [
	^ (AIAHistory new
		user: self;
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q0: systemBlock [
	^ (AIAHistory new
		system:  systemBlock value;
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q: systemBlock [
	^ (AIAHistory new
		system:  'You are a Pharo Smalltalk expert. In Pharo, operations are evaluated left to right without operator precedence.
		 Please response in ', AIACommentBuilding language, String cr, String cr, systemBlock value,'';
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> setAIAComment [

	AIAPackageComment new setComment: self
]
