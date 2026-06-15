"
# Class Comment for AIATeacup

## Purpose and Role in the System

The `AIATeacup` class serves as a web service interface within the Pharo Smalltalk environment. It utilises the Teapot framework to create a lightweight HTTP server, providing endpoints to access and manipulate Smalltalk class information dynamically. This class is particularly useful for developers and system administrators who need to interact with Pharo's class structure programmatically or through a web interface.

## Main Collaborators or Dependencies

- **Teapot**: The primary dependency is the Teapot framework, which is a lightweight web framework for Pharo. It handles HTTP requests and responses, routing, and server management.
- **PackageOrganizer**: This collaborator is used to access and manage the packages within the Pharo environment, allowing `AIATeacup` to retrieve and list classes from specific packages.
- **WebBrowser**: Used to open documentation or external resources, such as the Teapot User Guide, providing additional support and context for users.

## Important Invariants or Design Constraints

1. **Teapot Initialisation**: The `AIATeacup` class assumes that the Teapot framework is available in the Smalltalk environment. If not, it dynamically loads it using Metacello.
2. **Server Configuration**: The server is configured to run on port 1777. This port number should be unique and not conflict with other services running on the same machine.
3. **Route Handling**: The class defines several routes to handle different types of requests, such as retrieving an overview, listing all packages, and fetching class source code. Each route is designed to handle specific query parameters and return appropriate responses.

## Illustrative Usage Examples

### Example 1: Starting the Server

To start the server and make the endpoints available, you can use the following code snippet:

```smalltalk
AIATeacup new initialize.
```

This will initialise the server and set up the necessary routes. The server will then be accessible at `http://localhost:1777`.

### Example 2: Accessing Class Information

To retrieve the source code of a specific class, you can make a GET request to the `/classSource` endpoint with the class name as a query parameter:

```smalltalk
WebClient htmlSubmit: 'http://localhost:1777/classSource?className=AIATeacup'.
```

This will return the source code of the `AIATeacup` class, formatted and ready for inspection.

By leveraging the `AIATeacup` class, developers can easily integrate web-based access to Pharo's class structure, enhancing the interactivity and accessibility of the development environment.
"
Class {
	#name : 'AIATeacup',
	#superclass : 'Object',
	#instVars : [
		'teapot'
	],
	#category : 'AIAExperiments-Teacup issue',
	#package : 'AIAExperiments',
	#tag : 'Teacup issue'
}

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
	^ super new
]

{ #category : 'examples' }
AIATeacup class >> teapotDocumentation [
	<example> "should be a better name..."
	
	WebBrowser openOn: 'https://github.com/zeroflag/Teapot/blob/master/docs/UserGuide.md'
]

{ #category : 'private' }
AIATeacup >> doExpression: expr [
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
AIATeacup >> getAllPackages [
	| allPackageNames |
	Transcript << '/packages called'  << String lf.
	allPackageNames := PackageOrganizer default packages 
		collect: [ :package | package name asString] .
	^ allPackageNames 
]

{ #category : 'private' }
AIATeacup >> getClassCode: className [
	| aClass |
	Transcript << '/classSource called, with argument ' << className << String lf.
	aClass := Smalltalk at: className asSymbol 
		ifAbsent: [ ^ 'Class ', className, ' does not exist' ].
	^ AIASourceCode new forClass: aClass.
]

{ #category : 'private' }
AIATeacup >> getClassesOfPackage: aPackage [
	| allPackageNames |
	
	Transcript << '/packageClasses called, with argument ' << aPackage << String lf.
	allPackageNames := (PackageOrganizer default  packageNamed: aPackage ) 
		classes asArray select: [:aClass | aClass package name asString = aPackage].
	^ allPackageNames 
]

{ #category : 'private' }
AIATeacup >> getOverview [
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
  GET /classSource/<name>        - Source code of a class
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
AIATeacup >> initialize [
	super initialize.
	teapot := Teapot on .

]

{ #category : 'private' }
AIATeacup >> setIndex [
      
	teapot 
		GET: '/' -> [self getOverview] ;
		GET: '/packages' -> [ self getAllPackages ] ;
		GET: '/doExpression' -> [:req | self doExpression: (req at: #expr ifAbsent: ['']) ];
    	GET: '/time' -> [ DateAndTime now asString ];
		GET: '/packageClasses/<packageName>' -> [ :ref | 
				self getClassesOfPackage: (ref at: #packageName) ];		
		GET: '/classSource/<className>' -> [ :ref | 
				self getClassCode: (ref at: #className) ].
	teapot 
		start.
]
