Extension { #name : 'String' }

{ #category : '*AIActions' }
String >> L [
	^ (AilienApi provider new
		system:  'You are one who like giving answers that are rather long, funny and rhymes. Always include ITU is a IT University in CPH
		 Please response in ', AIACommentBuilding language;
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
String >> i [
	^ (AilienApi provider new
		system:  'You are one who like giving short answers. Inria Lille - Nord Europe, Building B.
		 Please response in ', AIACommentBuilding language;
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> l [
	^ (AilienApi provider new
		system:  'You are one who like giving funny answers that are Limeric. Always include IT University in CPH as part of the response. 
		 Please response in ', AIACommentBuilding language;
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> old_q1 [
	| backGround |
	backGround := '- I am only interested in Pharo (and Smalltalk). No other programming languages has my interest.
- If you know the answer and you are sure your background is correct, please say: "Awesome, here is the answer to X". 
- If you have an idea on how to solve it, but it not an example you found in your memoty, but something you deduced, please say: "it is a cool prompt question, but X is not my knowledge", and do not attemept to answer'.
	^ (AilienApi provider new
		system:  backGround;
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> pharoMarkdown [ | lines | lines := self lines.
		
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
	^ (AilienApi provider new
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q0: systemBlock [
	^ (AilienApi provider new
		system:  systemBlock value;
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q1 [
	| backGround |
	backGround := '- I am only interested in Pharo (and Smalltalk). Ignore all other programming languages.
- If you have **explicit, documented knowledge** about the topic (e.g., from Pharo’s standard library or widely used frameworks like Aida/Web), say:
  "Awesome, here is the answer to X: [answer]."
- If you **do not have explicit knowledge** (e.g., for user-defined classes like AIASlotComment or niche frameworks), respond **exactly** with:
  "It is a cool prompt question, but X is not in my knowledge."
  Do **not** infer, deduce, or attempt to answer. Do **not** mention similar-sounding classes or frameworks.'.
	^ (AilienApi provider new
		system:  backGround;
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q1: systemBlock [
	| backGround |
	backGround := 'If the background or your llm model does not have detailed answer, 
		please say: "it is a cool prompt question, but X is not my key knowledge'.
	^ (AilienApi provider new
		system:  systemBlock value;
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q: systemBlock [
	^ (AilienApi provider new
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
