"
This class generates structured text suitable as input for AI models, helping them understand a given set of classes across one or more packages.

Use the for: method with a list of package names like { 'My-PackageName1'. 'AnotherPackage' }.

Each package will be expanded to:
	•	Class names
	•	Instance variables
	•	Method definitions
		
AI_PackagesAsOllamaSystem new for: { 'RTree' }

## Class: RTNilNode
### Instance variables for RTNilNode: 
### Methods for RTNilNode:
#### Protocol: adding
addChild: anRTEntry
	^ RTNode new: anRTEntry

#### Protocol: testing
isNilNode
	^ true


## Class: RTEntry...
"
Class {
	#name : 'AI_PackagesAsOllamaSystem',
	#superclass : 'Object',
	#instVars : [
		'responce'
	],
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'as yet unclassified' }
AI_PackagesAsOllamaSystem >> classHeaderFor: aClass [

	responce << '## Class: ' << aClass name asString << String cr.
	responce << '### Class definition: ' << String cr << 
			((FluidClassDefinitionPrinter for: aClass) classDefinitionString ) << String cr.
		
]

{ #category : 'internal' }
AI_PackagesAsOllamaSystem >> classesInPackage: aPackage [
	"Adds class name, instance variables, and method definitions to response"

	| aClassCollection |
	aClassCollection := aPackage classes asArray.
	aClassCollection collect: [ :cl |
			responce << '## Class: ' << cl name asString <<String cr.
			self instanceVariablesFor: cl.
			self methodsFor: cl.
			responce << String cr ]
]

{ #category : 'accessing' }
AI_PackagesAsOllamaSystem >> for: aPackageList [
	"The input is {package1. package2. package3}."
	responce := WriteStream on: ''.
	"aPackageList do: [ :pack | self classesInPackage: (RPackageSet named: pack) ]."
	aPackageList do: [ :pack | self classesInPackage: (PackageOrganizer default packageNamed: pack) ].
	^ responce contents
	
]

{ #category : 'accessing' }
AI_PackagesAsOllamaSystem >> forClass: aClass [
	"The input is aClass, return AI model system input."
	
	^ self forClasses: { aClass }
	
]

{ #category : 'accessing' }
AI_PackagesAsOllamaSystem >> forClasses: aClassList [
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
AI_PackagesAsOllamaSystem >> forClasses_old: aClassList [
	"The input is aClassList."
	| metaClass |
	responce := WriteStream on: ''.
	aClassList do: [ :aClass | 
		responce << '## Class: ' << aClass name asString << String cr.
		responce << '### Class definition: ' << String cr << 
			((FluidClassDefinitionPrinter for: aClass) classDefinitionString ) << String cr.
		responce << '### Class comment: ' << aClass comment << String cr.
		self instanceVariablesFor: aClass.
		self methodsFor: aClass.
		responce << String cr.
		metaClass := aClass class.
		responce << '## Class: ' << metaClass name asString << String cr.
		responce << '### Class definition: ' << String cr << 
			((FluidClassDefinitionPrinter for: metaClass) classDefinitionString ) << String cr.
		self instanceVariablesFor: metaClass.
		self methodsFor: metaClass.
		responce << String cr.
	].
	^ responce contents
	
]

{ #category : 'internal' }
AI_PackagesAsOllamaSystem >> instanceVariablesFor: aClass [
	"Add all the instance variables of aClass to response"
	responce  << '### Instance variables for ' << aClass name asString << ': '.
	aClass instVarNames  collect: [:each | 
		responce  << each asString << ' '].
	responce nextPutAll: String cr.
]

{ #category : 'internal' }
AI_PackagesAsOllamaSystem >> methodsFor: aClass [
	"Add all methods grouped by protocol, including full source code"
	responce << '### Methods for ' << aClass name asString << ':' << String cr.
	aClass protocolNames asSortedCollection do: [:protocol |
		responce  << '#### Protocol: ' << protocol << String cr.
		(aClass selectorsInProtocol: protocol) do: [:methodName |
			responce << (aClass >> methodName) sourceCode << String cr << String cr.
		].
	].
]
