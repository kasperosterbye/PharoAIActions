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
String >> Q [

	| models responces |
	models := {
		          (MistralApi newOnModel: 1).
		          (GrokApi newOnModel: 1).
		          (GrokApi newOnModel: 3).
		          (OpenAIApi newOnModel: 1) }.
	responces := WriteStream on: ''.
	models do: [ :model |
			responces << 'Model: ' << model printString << String cr.
			responces << (AIAHistory new
				api: model;
				user: self;
				responseType: 'Make as short an answer as possible';
				getResponse;
				response).
			responces << String cr ].
	^ responces contents
]

{ #category : '*AIActions' }
String >> Q: systemBlock [

	| models responses |
	models := {
		          (MistralApi newOnModel: 1).
		          (GrokApi newOnModel: 1).
		          (GrokApi newOnModel: 3).
		          (OpenAIApi newOnModel: 1) }.
	responses := WriteStream on: ''.
	models do: [ :model |
			responses << 'Model: ' << model printString << String cr.
			responses << (AIAHistory new
				api: model;
		system:  systemBlock value;
				user: self;
				responseType: 'Make as short an answer as possible';
				getResponse;
				response).
			responses << String cr << String cr ].
	responses contents
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
String >> l [
	^ (AIAHistory new
		system:  'You are one who like giving funny answers that are Limeric. Always include IT University in Lund as part of the response';
		responseType:'Please response in ', AIACommentBuilding language;
		user: self; 
		getResponse;
		response) 
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
		addPreHistory: AIAHistory qHistory;
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
	^ (AIAHistory new
		system:  'You are a Pharo Smalltalk expert. In Pharo, operations are evaluated left to right without operator precedence.
		 Please response in ', AIACommentBuilding language, String cr, String cr, systemBlock value,'';
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> setAIAComment [
	"Sets an AI-generated comment for a package or package prefix using the AIA system"

	AIAPackageComment new setComment: self
]
