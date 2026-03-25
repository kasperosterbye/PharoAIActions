Class {
	#name : 'AIATeacup',
	#superclass : 'Object',
	#instVars : [
		'teapot'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIAExperiments-Teacup issue',
	#package : 'AIAExperiments',
	#tag : 'Teacup issue'
}

{ #category : 'examples' }
AIATeacup class >> default [
	default ifNil: [ default := super new ].
	^ default
]

{ #category : 'examples' }
AIATeacup class >> ensureTeacup [
	<example> "should be a better name..."
	
	(Smalltalk globals includesKey: #Teapot) ifTrue: [ ^ self ].
	Metacello new
  		baseline: 'Teapot';
  		repository: 'github://kasperosterbye/Teapot/source';
  		load.
]

{ #category : 'examples' }
AIATeacup class >> new [
	"self error: 'Use default instead'"
	^ super new
]

{ #category : 'examples' }
AIATeacup class >> teapotDocumentation [
	<example> "should be a better name..."
	
	WebBrowser openOn: 'https://github.com/zeroflag/Teapot/blob/master/docs/UserGuide.md'
]

{ #category : 'private' }
AIATeacup >> getAllPackages [
	| allPackageNames |
	allPackageNames := PackageOrganizer default packages 
		collect: [ :package | package name asString] .
	^ allPackageNames 
]

{ #category : 'private' }
AIATeacup >> getClassCode: className [
	| aClass |
	aClass := Smalltalk at: className asSymbol 
		ifAbsent: [ ^ 'Class ', className, ' does not exist' ].
	^ AIASourceCodeBuilder new forClass: aClass.
]

{ #category : 'private' }
AIATeacup >> getClassesOfPackage: aPackage [
	| allPackageNames |
	allPackageNames := (PackageOrganizer default  packageNamed: aPackage ) 
		classes asArray select: [:aClass | aClass package name asString = aPackage].
	^ allPackageNames 
]

{ #category : 'as yet unclassified' }
AIATeacup >> getOverview [
	^ self getClassCode: 'AIATeacup'
]

{ #category : 'initialization' }
AIATeacup >> initialize [
	"Kilroy came by here"
	teapot := Teapot on.
]

{ #category : 'private' }
AIATeacup >> setIndex [
	teapot 
		GET: '/' -> self getOverview ;
		GET: '/packages' -> self getAllPackages ;
		GET: '/packageClasses/<packageName>' -> [ :ref | 
				self getClassesOfPackage: (ref at: #packageName) ];		
		GET: '/classSource/<className>' -> [ :ref | 
				self getClassCode: (ref at: #className) ];		
		GET: '/classSource'"?className=" -> [ :ref |
				self getClassCode: (ref uri query at: #className) ].
	teapot 
		start.
]
