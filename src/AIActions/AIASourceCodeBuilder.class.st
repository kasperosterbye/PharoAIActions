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
