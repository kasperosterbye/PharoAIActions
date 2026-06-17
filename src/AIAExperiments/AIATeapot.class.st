"
AIATeapot is the Teapot-based web server for PharoAIActions.

It exposes REST endpoints for%3A
- Package and class browsing
- Class comments and source
- Dynamic expression evaluation.

Uses Teapot for routing%2C OpalCompiler for eval.

Always URL-encode params and add cache-busters.
"
Class {
	#name : 'AIATeapot',
	#superclass : 'Object',
	#instVars : [
		'teapot'
	],
	#category : 'AIAExperiments-Teacup issue',
	#package : 'AIAExperiments',
	#tag : 'Teacup issue'
}

{ #category : 'examples' }
AIATeapot class >> ensureTeapot [
	<example> "should be a better name..."
	
	(Smalltalk globals includesKey: #Teapot) ifTrue: [ ^ self ].
	Metacello new
  		baseline: 'Teapot';
  		repository: 'github://kasperosterbye/Teapot/source';
  		load.
]

{ #category : 'examples' }
AIATeapot class >> new [ 
	self ensureTeapot.
	^ super new
]

{ #category : 'examples' }
AIATeapot class >> teapotDocumentation [
	<example>
	
	WebBrowser openOn: 'https://github.com/zeroflag/Teapot/blob/master/docs/UserGuide.md'
]

{ #category : 'private' }
AIATeapot >> doExpression: expr [
	| result |
	
	Transcript << '>>> doExpression: called with argument: ' << expr << String lf.
	result := ''.
	[ result := (OpalCompiler new evaluate: expr) printString]
		on: Error
		do: [ :ex | result := 'Error: ' , ex messageText ].
	
	Transcript << '<<< ' << result << String lf.
	^ result 
	

	
]

{ #category : 'private' }
AIATeapot >> getAllPackages [
	| allPackageNames |
	Transcript << '/packages called'  << String lf.
	allPackageNames := PackageOrganizer default packages 
		collect: [ :package | package name asString] .
	^ allPackageNames 
]

{ #category : 'private' }
AIATeapot >> getClassCode: className [
	| aClass |
	Transcript << '/classSource called, with argument ' << className << String lf.
	aClass := Smalltalk at: className asSymbol 
		ifAbsent: [ ^ 'Class ', className, ' does not exist' ].
	^ AIASourceCode new forClass: aClass.
]

{ #category : 'private' }
AIATeapot >> getClassComment: className [
	| aClass |
	Transcript << '/getClassComment: called, with argument ' << className << String lf.
	aClass := Smalltalk at: className asSymbol 
		ifAbsent: [ ^ 'Class ', className, ' does not exist' ].
	^ aClass comment.
]

{ #category : 'private' }
AIATeapot >> getClassesOfPackage: aPackage [
	| allPackageNames |
	
	Transcript << '/packageClasses called, with argument ' << aPackage << String lf.
	allPackageNames := (PackageOrganizer default  packageNamed: aPackage ) 
		classes asArray select: [:aClass | aClass package name asString = aPackage].
	^ allPackageNames 
]

{ #category : 'private' }
AIATeapot >> getOverview [
	"https://pharoaiactions.ngrok.dev"
	Transcript << 'Get overview called' << String lf.
	^ 'Welcome to AIATeacup - A Pharo Smalltalk Web Interface

Important
Use ?<randomWord>=<randomStringAndValue> to bypass caching. Do that for any endpoint

AVAILABLE ENDPOINTS:
  GET /                          - This overview 
  GET /time                      - Current server time
  GET /packages                  - List of all Pharo packages
  GET /packageClasses/<name>     - All classes in a package
  GET /classComment/<name>       - Comment of a class <name>
  GET /classSource/<name>        - Source code of a class <name>
  GET /doExpression?expr=<code>  - Evaluate a Pharo expression

IMPORTANT - URL ENCODING:
All parameter values must be URL-encoded (percent-encoded).
Special characters: + becomes %2B, * becomes %2A, > becomes %3E, # becomes %23, space becomes %20.
Example: "12345**59" must be sent as "12345%2A%2A59"

SELF-TEST:
Please verify your setup by calling:
  GET /doExpression?expr=2%2B3%2A4
Expected result: 20
(This confirms correct URL-encoding and that Pharo operator precedence is respected)

CACHE NOTE:
Always append random parameters to avoid stale responses, e.g.:
  GET /?<randomWord>=<randomStringAndValue>'
]

{ #category : 'initialization' }
AIATeapot >> initialize [
	super initialize.
	teapot := Teapot on .

]

{ #category : 'private' }
AIATeapot >> setIndex [
      
	teapot 
		GET: '/' -> [self getOverview] ;
		GET: '/packages' -> [ self getAllPackages ] ;
		GET: '/doExpression' -> [:req | self doExpression: (req at: #expr ifAbsent: ['']) ];
    	GET: '/time' -> [ DateAndTime now asString ];
		GET: '/packageClasses/<packageName>' -> [ :ref | 
				self getClassesOfPackage: (ref at: #packageName) ];		
		GET: '/classComment/<className>' -> [ :ref | 
				self getClassComment: (ref at: #className) ];		
		GET: '/classSource/<className>' -> [ :ref | 
				self getClassCode: (ref at: #className) ].
	teapot 
		start.
]
