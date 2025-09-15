"
Here's a class comment for `AIASourceCodeBuilder` in Markdown format, including a usage example suitable for the Playground:

# AIASourceCodeBuilder

A utility class for generating formatted source code documentation from Pharo classes and packages. It provides methods to extract and format class definitions, instance variables, methods, and superclass hierarchies, making it useful for code analysis, documentation generation, and system exploration.

## Key Features

- Generates human-readable source code documentation from classes and packages
- Extracts class definitions, instance variables, and method implementations
- Handles both instance and class-side methods
- Includes superclass hierarchy information
- Supports package-level documentation generation
- Provides method call analysis within the same package

## Usage Example

```smalltalk
""Generate documentation for the Point class and inspect the result""
builder := AIASourceCodeBuilder new.
builder forClass: Point.
builder response contents inspect
```

```smalltalk
""Generate documentation for all classes in the Kernel package and inspect the result""
builder := AIASourceCodeBuilder new.
builder for: 'Kernel'.
builder response contents inspect
```

## Design Notes

- The builder uses a `WriteStream` to accumulate the generated documentation
- Methods are organized by protocol for better readability
- Class comments are included in the generated output
- The builder can handle both direct class references and package names
- Package names can be specified with wildcards (e.g., '*Kernel*')

## Extensibility

The builder can be extended to:
- Generate different output formats (HTML, Markdown, etc.)
- Include additional metadata (author, version, etc.)
- Filter methods based on specific criteria
- Generate UML diagrams from the extracted information

## Implementation Notes

- Uses `FluidClassDefinitionPrinter` for class definition formatting
- Leverages `SystemNavigation` for method call analysis
- Maintains package boundaries when analyzing method calls
- Handles both regular classes and metaclasses appropriately

This builder is particularly useful for:
- Code review and documentation generation
- System analysis and understanding
- Educational purposes to explore class structures
- Creating custom code analysis tools
```

The example shows how to use the builder to generate documentation for a specific class or package, with the result being inspected in the Playground. The comment provides context about the builder's capabilities, usage patterns, and design decisions.
"
Class {
	#name : 'AIASourceCodeBuilder',
	#superclass : 'Object',
	#instVars : [
		'response',
		'classList'
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

{ #category : 'accessing' }
AIASourceCodeBuilder >> classHeaderFor: current super: aClass on: superComment [
	"Generates a formatted class header string for aClass, including its name and definition, and appends it to the superComment stream. Includes methods and meta-class details."

	| meta |
	(classList includes: aClass) ifTrue: [ self error ].
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
	"Generates formatted documentation for all classes in a package, including their definitions, instance variables, and methods, appending to the response stream."

	| aClassCollection |
	aClassCollection := aPackage definedClasses asArray.
	aClassCollection do: [ :cl | self forClass: cl]
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
	| metaClass |
		(classList includes: aClass) 
			ifTrue: [ ^ response contents ].
		classList add: aClass.
		self classHeaderFor: aClass.
		self methodsFor: aClass.
		response << String cr.
		metaClass := aClass class.
		classList add: metaClass.
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
	"Generates formatted superclass hierarchy for aClass, including methods and meta-class details, appending to response stream. Recursively processes superclasses until Object."
	| superComment superClass |
	aClass = Object  ifTrue: [ ^ '' ].
	
	superClass := aClass superclass.
	superClass = Object ifTrue: [ ^ '' ].
	(classList includes: superClass) 
			ifTrue: [ ^ '' ].
	superComment := WriteStream on: ''.
	self classHeaderFor: aClass super: superClass on:  superComment.
	superComment << (self forSuperClassesOf: superClass) .
	^ superComment contents
	
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

{ #category : 'internal' }
AIASourceCodeBuilder >> old_classesInPackage: aPackage [
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

{ #category : 'accessing' }
AIASourceCodeBuilder >> tag: aTagName package: packages [
	| tagClasses |
	tagClasses := ((PackageOrganizer default packageNamed: packages) 
			tagNamed: aTagName
			ifAbsent: [^ '']) classes. 
	tagClasses do: [ :cl | self forClass: cl ].
	^ response contents
]
