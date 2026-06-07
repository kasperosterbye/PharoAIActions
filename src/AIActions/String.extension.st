Extension { #name : 'String' }

{ #category : '*AIActions' }
String >> aiaComment [
	"Provides comments for packages or package prefixes using AIA system."
	| package |
	
	(thisContext sender method name = 'StMethodFinderSend>>#evaluate') ifTrue: [ ^''].
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
	
	(thisContext sender method name = 'StMethodFinderSend>>#evaluate') ifTrue: [ ^''].
	resp := (AIAHistory dDiscussion 
		user: self;
		getResponse;
		response ).
	^ resp.
]

{ #category : '*AIActions' }
String >> du [
	| resp |
	
	(thisContext sender method name = 'StMethodFinderSend>>#evaluate') ifTrue: [ ^''].
	resp := (AIAHistory dDiscussion 
		user: self).
	^ resp.
]

{ #category : '*AIActions' }
String >> l [
	
	(thisContext sender method name = 'StMethodFinderSend>>#evaluate') ifTrue: [ ^''].
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
String >> p [
	| resp |
	(thisContext sender method name = 'StMethodFinderSend>>#evaluate') ifTrue: [ ^''].
	resp := (AIAHistory dDiscussion 
		user: self;
		getResponse;
		response ).
	^ resp.
]

{ #category : '*AIActions' }
String >> q [
	
	(thisContext sender method name = 'StMethodFinderSend>>#evaluate') ifTrue: [ ^''].
	^ AIAHistory new
		addPreHistory: AIAHistory qPrefix ;
		user: self; 
		getResponse; 
		response 
]

{ #category : '*AIActions' }
String >> q0 [
	
	(thisContext sender method name = 'StMethodFinderSend>>#evaluate') ifTrue: [ ^''].
	^ (AIAHistory new
		user: self;
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q0: systemBlock [
	systemBlock isBlock ifFalse: [ ^ '' ].
	^ (AIAHistory new
		system:  systemBlock value;
		user: self; 
		getResponse; 
		response) 
]

{ #category : '*AIActions' }
String >> q: systemBlock [
	systemBlock isBlock ifFalse: [ ^ '' ].
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

	(thisContext sender method name = 'StMethodFinderSend>>#evaluate') ifTrue: [ ^''].
	AIAPackageComment new setComment: self
]
