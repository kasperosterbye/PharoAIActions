"
# Class Comment for AIASourceCodeBuilder

## AIASourceCodeBuilder

**AIASourceCodeBuilder** is a utility class designed to generate formatted source code descriptions for Pharo classes and packages. It is particularly useful for documentation and code analysis purposes. The class provides methods to generate detailed descriptions of classes, including their instance variables, methods, and meta-classes.

### Key Features:

- **Package-Level Generation**: Generates source code descriptions for a list of packages.
- **Class-Level Generation**: Generates source code descriptions for individual classes or a list of classes.
- **Detailed Descriptions**: Includes class definitions, instance variables, and methods grouped by protocol.
- **Meta-Class Support**: Generates descriptions for both the class and its meta-class.

### Usage:

To use `AIASourceCodeBuilder`, you can call its class-side methods to generate descriptions for specific packages or classes. For example:

```smalltalk
| builder packageList classList |
builder := AIASourceCodeBuilder new.
packageList := { 'Package1'. 'Package2' }.
classList := { SomeClass. AnotherClass }.

""Generate description for a list of packages""
builder for: packageList.

""Generate description for a single class""
builder forClass: SomeClass.

""Generate description for a list of classes""
builder forClasses: classList.
```

### Methods:

- **`for: aPackageList`**: Generates a formatted string describing the classes in the given list of packages.
- **`forClass: aClass`**: Generates a formatted string describing the given class.
- **`forClasses: aClassList`**: Generates a formatted string describing the given list of classes.
- **`classesInPackage: aPackage`**: Internal method to add class names, instance variables, and method definitions to the response for a given package.
- **`instanceVariablesFor: aClass`**: Internal method to add all instance variables of a class to the response.
- **`methodsFor: aClass`**: Internal method to add all methods grouped by protocol, including full source code, to the response.
- **`classHeaderFor: aClass`**: Internal method to return a string with the class name and definition for a class.

### Example:

```smalltalk
| builder description |
builder := AIASourceCodeBuilder new.
description := builder forClass: SomeClass.
Transcript show: description.
```

This class comment provides an overview of the `AIASourceCodeBuilder` class, its features, usage, and key methods. It is intended to help users understand how to utilise the class effectively for generating source code descriptions.
"
Class {
	#name : 'AIASourceCodeBuilder',
	#superclass : 'Object',
	#instVars : [
		'response'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'internal' }
AIASourceCodeBuilder >> classHeaderFor: aClass [
	"Generates a formatted class header string for aClass, including its name and definition, and appends it to the response stream."
	response << '## Class: ' << aClass name asString << String cr
		<< (FluidClassDefinitionPrinter for: aClass) classDefinitionString
		<< String cr.
	response << '### Instance variables: ' << 
		(aClass instanceVariables collect: [:iv | '#',iv name asString, ' '])
		 << String cr.

	aClass isMeta ifTrue: [ ^ self ].
	response << '### Class comment:' << String cr
		<< '````markdown' << String cr
		<< aClass comment << String cr
		<< '````' << String cr
]

{ #category : 'internal' }
AIASourceCodeBuilder >> classHeaderFor: current super: aClass on: superComment [
	"Generates a formatted class header string for aClass, including its name and definition, and appends it to the superComment stream. Includes methods and meta-class details."

	| meta |
	superComment << '## Superclass: ' << aClass name asString
	<< ' for class: ' << current name asString << String cr
	<< (FluidClassDefinitionPrinter for: aClass) classDefinitionString
	<< String cr << String cr.
	aClass methods size > 0 ifTrue: [
			superComment << '### Methods of ' << aClass name asString
			<< String cr.
			aClass methods do: [ :method | self methodNameAndCommentFor: method in: superComment ] ].
	meta := aClass class.
	(meta methods size > 0 or: [ meta instVarNames size > 0 ]) ifFalse: [
		^ self ].
	superComment << '### ' << aClass name asString << ' has meta class: '
	<< String cr
	<< (FluidClassDefinitionPrinter for: meta) classDefinitionString
	<< String cr << String cr.
	meta methods size > 0 ifTrue: [
			superComment << '### Methods of ' << meta name asString
			<< String cr.
			meta methods do: [ :method | self methodNameAndCommentFor: method in: superComment] ]
]

{ #category : 'internal' }
AIASourceCodeBuilder >> classesInPackage: aPackage [
	"Adds class name, instance variables, and method definitions to response"

	| aClassCollection |
	aClassCollection := aPackage definedClasses asArray.
	aClassCollection do: [ :cl |
			response << '## Class: ' << cl name asString <<String cr.
			self instanceVariablesFor: cl.
			self methodsFor: cl.
			response << String cr ]
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> for: packages [
	"Generates a formatted string describing the classes in the given list of packages."

	((packages isString and: [ (packages beginsWith: '*') ] )
			ifTrue: [ PackageOrganizer default packages
		               select: [ :p |
		               p name beginsWith: packages copyWithoutFirst ]
		               thenCollect: #name ]
			ifFalse: [ packages ])
	 do: [ :package |
			(PackageOrganizer default hasPackage: package) 
				ifTrue: [ 
					response << '# Package: ' << package  << String cr.
					self classesInPackage:
						(PackageOrganizer default packageNamed: package) ]].
	^ response contents
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forClass: aClass [
	"Generates a formatted string describing the given class including its name definition instance variables methods and meta class details."
	| metaClass |

		self classHeaderFor: aClass.
		self methodsFor: aClass.
		response << String cr.
		metaClass := aClass class.
		self classHeaderFor: metaClass.
		self methodsFor: metaClass.
		response << String cr.
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
	"Returns a formatted description of the given method, including its source code and all callers within the same package, useful for documentation and analysis"
	|  callers ": OrderedCollection" callersInMyPackage ": OrderedCollection"|
	callers := SystemNavigation default allCallsOn: (aMethod selector).
	callersInMyPackage := OrderedCollection new.
	callers do: [ :caller | 
		(caller methodClass packageName alike: aMethod methodClass packageName ) > 4
			ifTrue: [ callersInMyPackage add: caller ]
	].
	^ self systemForMethod: aMethod usedIn: callersInMyPackage
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forSuperClassesOf: aClass [
	"Generates formatted class header for superclasses of aClass including name definition methods and meta class details."

	| superComment superClass |
	aClass = Object  ifTrue: [ ^ '' ].
	
	superClass := aClass superclass.
	superClass = Object ifTrue: [ ^ '' ].
	
	superComment := WriteStream on: ''.
	self classHeaderFor: aClass super: superClass on:  superComment.
	superComment << (self forSuperClassesOf: superClass) .
	^ superComment contents
	
]

{ #category : 'initialization' }
AIASourceCodeBuilder >> initialize [
	"Initialises a new instance of AIASourceCodeBuilder with an empty WriteStream for accumulating generated source code descriptions."
	response := WriteStream on: ''.
]

{ #category : 'internal' }
AIASourceCodeBuilder >> instanceVariablesFor: aClass [
	"Adds instance variables of aClass to response, formatted as a list."
	response  << '### Instance variables for ' << aClass name asString << ': '.
	aClass instVarNames  collect: [:each | 
		response  << each asString << ' '].
	response nextPutAll: String cr.
]

{ #category : 'as yet unclassified' }
AIASourceCodeBuilder >> methodNameAndCommentFor: method in: superComment [
	"Appends method name and comment to superComment stream for aClass. Formats as 'Method: name comment: comment' with newlines. Used in classHeaderFor:super:on:."

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
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> response [
	"Returns the WriteStream used to accumulate generated source code descriptions. Initialised in initialize."
	^ response 
]

{ #category : 'internal' }
AIASourceCodeBuilder >> systemForMethod: aMethod usedIn: callersInMyPackage [
	"Generates formatted source code description for a method and its callers within the same package. Includes method name, class, and source code. Used for documentation and analysis."
	response << '## Calling methods: ' << 
		aMethod methodClass name asString << ' >> #' <<aMethod selector << String cr.
	callersInMyPackage do: [ :caller |
		response << caller methodClass name asString << ' >> #' .
		response << caller sourceCode  << String cr << String cr.
	].
	^ response contents
	
]
