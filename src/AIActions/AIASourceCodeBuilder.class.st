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

This class comment provides an overview of the `AIASourceCodeBuilder` class, its features, usage, and key methods. It is intended to help users understand how to utilize the class effectively for generating source code descriptions.
"
Class {
	#name : 'AIASourceCodeBuilder',
	#superclass : 'Object',
	#instVars : [
		'responce'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'internal' }
AIASourceCodeBuilder >> classHeaderFor: aClass [
	"Returns a string with the class name and definition for aClass."

	responce << '## Class: ' << aClass name asString << String cr.
	responce << '### Class definition: ' << String cr << 
			((FluidClassDefinitionPrinter for: aClass) classDefinitionString ) << String cr.
		
]

{ #category : 'internal' }
AIASourceCodeBuilder >> classesInPackage: aPackage [
	"Adds class name, instance variables, and method definitions to response"

	| aClassCollection |
	aClassCollection := aPackage definedClasses asArray.
	aClassCollection do: [ :cl |
			responce << '## Class: ' << cl name asString <<String cr.
			self instanceVariablesFor: cl.
			self methodsFor: cl.
			responce << String cr ]
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> for: aPackageList [
	"The input is {package1. package2. package3}."
	responce := WriteStream on: ''.
	aPackageList do: [ :package | 
			self classesInPackage: (PackageOrganizer default packageNamed: package) ].
	^ responce contents
	
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forClass: aClass [
	"Returns a package for a single class."
	
	^ self forClasses: { aClass }
	
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forClasses: aClassList [
	"Generates a formatted string describing the classes and their meta-classes in aClassList."
	| metaClass |
	responce := WriteStream on: ''.
	aClassList do: [ :aClass | 
		self classHeaderFor: aClass.
		responce << '### Class comment: ' << aClass comment << String cr.
		self instanceVariablesFor: aClass.
		self methodsFor: aClass.
		responce << String cr.
		metaClass := aClass class.
		self classHeaderFor: metaClass.
		self instanceVariablesFor: metaClass.
		self methodsFor: metaClass.
		responce << String cr.
	].
	^ responce contents
	
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> forMethod: aMethod [
	| selector myClass myPackage callers callersInMyPackage|
	selector := aMethod selector.
	myClass := aMethod methodClass.
	myPackage := myClass packageName.
	callers := SystemNavigation default allCallsOn: selector.
	callersInMyPackage := OrderedCollection new.
	callers do: [ :caller | 
		caller methodClass packageName = myPackage 
			ifTrue: [ callersInMyPackage add: caller ]
	].
	^ self systemForMethod: aMethod usedIn: callersInMyPackage
]

{ #category : 'internal' }
AIASourceCodeBuilder >> instanceVariablesFor: aClass [
	"Add all the instance variables of aClass to response"
	responce  << '### Instance variables for ' << aClass name asString << ': '.
	aClass instVarNames  collect: [:each | 
		responce  << each asString << ' '].
	responce nextPutAll: String cr.
]

{ #category : 'internal' }
AIASourceCodeBuilder >> methodsFor: aClass [
	"Add all methods grouped by protocol, including full source code"
	responce << '### Methods for ' << aClass name asString << ':' << String cr.
	aClass protocolNames asSortedCollection do: [:protocol |
		responce  << '#### Protocol: ' << protocol << String cr.
		(aClass selectorsInProtocol: protocol) do: [:methodName |
			responce << (aClass >> methodName) sourceCode << String cr << String cr.
		].
	].
]

{ #category : 'accessing' }
AIASourceCodeBuilder >> systemForMethod: aMethod usedIn: callersInMyPackage [
	
	responce := WriteStream on: ''.
	responce << '## Method calling ' << aMethod selector << String cr.
	callersInMyPackage do: [ :caller |
		responce << '### Called in:' << String cr.
		responce << caller sourceCode  << String cr << String cr.
	].
	^ responce contents
	
]
