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
	"Provides comments for packages or package prefixes using AIA system."
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
	| resp |
	resp := (AIAHistory dDiscussion 
		user: self;
		getResponse;
		response ).
	"AIAPresenter onText: resp."
	^ resp.
]

{ #category : '*AIActions' }
String >> du [
	| resp |
	resp := (AIAHistory dDiscussion 
		user: self).
	"AIAPresenter onText: resp."
	^ resp.
]

{ #category : '*AIActions' }
String >> l [
	^ (AIAHistory new
		system:  'You are one who like giving funny answers that are Limeric. ';
		responseType:'Please response in ', AIACommentBuilding language;
		user: self; 
		getResponse;
		response) 
]

{ #category : '*AIActions' }
String >> maxFirst: index [
	self size <= index 
		ifTrue: [ ^ self ]
		ifFalse: [ ^ self first: index ]
]

{ #category : '*AIActions' }
String >> old_q [
	^ (AIAHistory new
		system:  'You are a Pharo Smalltalk expert. In Pharo, operations, comparison operators, or in general  binary selectors are evaluated left to right without operator precedence. True and False er NOT numbers, but booleans.
		 Please response in ', AIACommentBuilding language;
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q [
	^ AIAHistory new
		addPreHistory: AIAHistory qPrefix ;
		user: self; 
		getResponse; 
		response 
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
	^ AIAHistory new
		addPreHistory: AIAHistory qPrefix ;
		background: systemBlock value;
		user: self; 
		getResponse; 
		response
]

{ #category : '*AIActions' }
String >> setAIAComment [
	"Sets an AI-generated comment for a package or package prefix using the AIA system"

	AIAPackageComment new setComment: self
]
