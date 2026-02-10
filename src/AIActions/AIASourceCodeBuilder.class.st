Class {
	#name : 'AIASourceCodeBuilder',
	#superclass : 'Object',
	#instVars : [
		'response',
		'classList',
		'sourcePackage'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'internal' }
AIASourceCodeBuilder >> classHeaderFor: aClass [
	"Generates formatted class header for aClass including name definition and instance variables. Appends to response stream. Handles both regular and meta classes. Includes class comment if available."
	| className classDefinition instansVariable classComment|
	className := aClass name asString.
	classDefinition := (FluidClassDefinitionPrinter for: aClass) classDefinitionString.
	instansVariable := aClass instanceVariables collect: [:iv | '#',iv name asString, ' '].
	
	response << '## Class: ' << className  << String cr << classDefinition << String cr.
	response << '### Instance variables: ' << instansVariable << String cr.

	aClass isMeta ifFalse: [ 
		classComment := aClass comment .
		response << '### Class comment:' << String cr
			<< '````markdown' << String cr
			<< classComment << String cr
			<< '````' << String cr]
]

{ #category : 'internal' }
AIASourceCodeBuilder >> classHeaderFor: current super: aClass on: superComment [
	"Generates formatted superclass header for a class including its name definition and instance variables. Appends to provided stream. Handles both regular and meta classes. Includes class comment if available."

	| className currentName classDefinition meta metaClassDefinition |
	(classList includes: aClass) ifTrue: [ self error ].
	className := aClass name asString.
	currentName := current name asString.
	classDefinition := (FluidClassDefinitionPrinter for: aClass) classDefinitionString.
	meta := aClass class.
	metaClassDefinition := (FluidClassDefinitionPrinter for: meta) classDefinitionString.
			
	superComment << '## Superclass: ' << className << ' for class: ' 
			<< currentName << String cr << classDefinition << String cr << String cr.
	aClass methods ifNotEmpty: [
			superComment << '### Methods of ' << className << String cr.
			aClass methods do: [ :method | self methodNameAndCommentFor: method in: superComment ] ].
	(meta methods isNotEmpty or: [ meta instVarNames isNotEmpty ]) ifTrue: [
			superComment << '### ' << className << ' has meta class: ' << String cr 
					<< metaClassDefinition << String cr << String cr.
			meta methods ifNotEmpty: [
					superComment << '### Methods of ' << meta name asString << String cr.
					meta methods do: [ :method | self methodNameAndCommentFor: method in: superComment ] ] ]
]

{ #category : 'internal' }
AIASourceCodeBuilder >> classesInPackage: aPackage [
	"Generates formatted documentation for all classes in a package, including their definitions, instance variables, and methods, appending to the response stream."

	| aClassCollection |
	aClassCollection := aPackage definedClasses asArray.
	aClassCollection do: [ :cl | self forClass: cl]
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> for: packages [
	"Generates formatted source code descriptions for a list of packages, including their classes, methods, and meta-class details, appending to the response stream."

	|  selectedPackage |
	packages do: [ :packageName |
		(PackageOrganizer default hasPackage: packageName) ifTrue: [
			selectedPackage := PackageOrganizer default packageNamed: packageName.
			response << '# Package: ' << packageName << String cr.
			self classesInPackage: selectedPackage ] ].

	^ response contents
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forClass: aClass [

	| metaClass |
	sourcePackage := aClass package name asString.
	(classList includes: aClass) ifTrue: [ ^ response contents ].
	classList add: aClass.
	metaClass := aClass class.
	classList add: metaClass.

	self classHeaderFor: aClass.
	self methodsFor: aClass.

	self classHeaderFor: metaClass.
	self methodsFor: metaClass.

	response << (self forSuperClassesOf: aClass).
	^ response contents
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forClasses: aClassList [
	"Generates formatted source code descriptions for a list of classes, including their definitions, instance variables, methods, and meta-class details."
	
	aClassList do: [ :aClass | self forClass: aClass ].
	^ response contents 
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forMethod: aMethod [
	"Generates formatted source code descriptions for a method and its callers within the same package. Includes method name, class, and source code. Used for documentation and analysis."

	|  callers callersInMyPackage methodPackage |
	callers := SystemNavigation default allCallsOn: (aMethod selector).
	callersInMyPackage := OrderedCollection new.
	methodPackage := aMethod methodClass packageName.
	
	callers do: [ :caller | | callerPackage |
		callerPackage := caller methodClass packageName.
		(callerPackage alike: methodPackage ) >= 10
			ifTrue: [ callersInMyPackage add: caller ]
	].
	^ self systemForMethod: aMethod usedIn: callersInMyPackage
]

{ #category : 'internal' }
AIASourceCodeBuilder >> forSuperClassesOf: aClass [
	"Generates formatted superclass hierarchy for aClass, including methods and meta-class details, appending to response stream. Recursively processes superclasses until Object."
	| superComment superClass |
	(self stopNow: aClass) ifTrue: [ ^ '' ].
	
	superClass := aClass superclass.
	(superClass = nil) ifTrue: [ ^  '' ].
	(self stopNow: superClass) ifTrue: [ ^ '' ].
	(classList includes: superClass) 
			ifTrue: [ ^ '' ].
	superComment := WriteStream on: ''.
	self classHeaderFor: aClass super: superClass on:  superComment.
	superComment << (self forSuperClassesOf: superClass) .
	^ superComment contents
	
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forTag: tagName in: package [
	
	| potentialClasses classSet |
	potentialClasses := (PackageOrganizer default packageNamed: package) classes asArray.
	classSet := potentialClasses select: [ :aClass | aClass packageTag name asString = tagName ].
	self forClasses: classSet.
	^ response contents
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forTagsLike: aClass [
	
	self forTag: aClass packageTag name in: aClass package name.
	^ response contents
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forWildcard: wild [
	"Generates formatted source code descriptions for packages matching a wildcard pattern, including all classes, methods, and meta-class details, appending to the response stream."

	| packageNames  |
	packageNames := (wild isString and: [ wild beginsWith: '*' ])
		ifTrue: [ 
			PackageOrganizer default packages
				select: [ :p | p name beginsWith: wild copyWithoutFirst ]
				thenCollect: #name ].
	^ self for: packageNames 
]

{ #category : 'initialization' }
AIASourceCodeBuilder >> initialize [
	"Initialises a new instance of AIASourceCodeBuilder with an empty WriteStream for accumulating generated source code descriptions."
	response := WriteStream on: ''.
	classList := Set new.
]

{ #category : 'internal' }
AIASourceCodeBuilder >> instanceVariablesFor: aClass [
	"Adds instance variables of aClass to response, formatted as a list."
	response  << '### Instance variables for ' << aClass name asString << ': '.
	aClass instVarNames  collect: [:each | 
		response  << each asString << ' '].
	response nextPutAll: String cr.
]

{ #category : 'internal' }
AIASourceCodeBuilder >> methodNameAndCommentFor: method in: superComment [
	"Adds method name and comment to stream for documentation. Handles nil comments gracefully. Formats for readability. Preserves original structure."

	superComment << 'Method: ' << method name << String cr.
	method comment ifNotNil: [
		superComment << 'comment: "' << method comment << '"' << String cr ].
	superComment << String cr
]

{ #category : 'internal' }
AIASourceCodeBuilder >> methodsFor: aClass [
	"Add all methods grouped by protocol, including full source code"
	response << '### Methods for ' << aClass name asString << ':' << String cr.
	aClass protocolNames asSortedCollection do: [:protocol |
		response  << '#### Protocol: ' << protocol << String cr.
		(aClass selectorsInProtocol: protocol) do: [:methodName |
			response << (aClass >> methodName) sourceCode << String cr << String cr.
		].
	].
	response << String cr.
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> response [
	"Returns the WriteStream used to accumulate generated source code descriptions. Initialised in initialize."
	^ response 
]

{ #category : 'as yet unclassified' }
AIASourceCodeBuilder >> stopNow: aClass [
	^ sourcePackage = aClass package name asString.
	"((((aClass = Object 
		or: [ aClass = Object class ])
		or: [ aClass = Metaclass])
		or: [ aClass = TestCase ])
		or: [ aClass = ProtoObject ])
		ifTrue: [ ^ true ].
	^ false"
]

{ #category : 'internal' }
AIASourceCodeBuilder >> systemForMethod: aMethod usedIn: callersInMyPackage [
	"Generates formatted source code description for a method and its callers within the same package. Includes method name, class, and source code. Used for documentation and analysis."
	| className methodName|
	className := aMethod methodClass name asString.
	methodName := aMethod selector.
	response << '## Calling methods: ' << className << ' >> #' << methodName << String cr.
	
	callersInMyPackage do: [ :caller | | className2 methodName2 |
		className2 := caller methodClass name asString.
		methodName2 := caller selector.
		response << className2<< ' >> #' << methodName2 << String cr << String cr.
	].
	^ response contents
	
]
