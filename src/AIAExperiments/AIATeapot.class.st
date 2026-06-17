"
Kilroy is not here
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
AIATeapot >> doExpression: url [
	| expr result |
	
	expr := ZnUrl new decodePercent: url.
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
Use randowm words xxx and yyy in ?<xxx>=<yyy> to bypass caching. Do that for ALL endpoints

AVAILABLE ENDPOINTS:
  GET /                          - This overview 
  GET /pharoSyntax               - Pharo14 class definition syntax with examples 
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
(This confirms correct URL-encoding and that Pharo operator precedence is respected).

To make classes in Pharo14, check https://pharoaiactions.ngrok.dev/getPharoSyntax?<randomWord>=<randomStringAndValue>'
]

{ #category : 'as yet unclassified' }
AIATeapot >> getPharoSyntax [
    ^ 'PHARO14 CLASS DEFINITION SYNTAX

To define a class in Pharo14, use the fluid class definition API:

  (Object << #MyNewClass
      slots: { #foo . #bar };
      tag: ''MyTag'';
      package: ''MyPackage'') fluidInstall.

WHERE:
  Object       - the superclass (can be any existing class e.g. Object, Collection)
  #MyNewClass  - the name of the new class (a Symbol with #)
  slots:       - instance variables, array of Symbols (replaces old instanceVariableNames:)
                 zero slots: slots: {}
                 one slot:   slots: { #foo }
                 many slots: slots: { #foo . #bar . #baz }
  tag:         - sub-package grouping within the package (optional)
  package:     - the package name (a String)

NOTE: << is the Pharo14 fluid class definition operator.
It replaces the old verbose form:
  Object subclass: #MyNewClass
      instanceVariableNames: ''foo bar''
      classVariableNames: ''''
      poolDictionaries: ''''
      category: ''MyPackage''

To create a class, pass the definition to /doExpression with URL-encoding:
  + becomes %2B, space becomes %20, # becomes %23, > becomes %3E

SELF-TEST:
  GET /doExpression?expr=Object%20%3C%3C%20%23TestClass123
  Expected: TestClass123'
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
		GET: '/pharoSyntax' -> [self getPharoSyntax] ;
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
