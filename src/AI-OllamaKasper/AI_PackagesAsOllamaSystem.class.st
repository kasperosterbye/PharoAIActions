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
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'internal' }
AI_PackagesAsOllamaSystem >> classesInPackage: aPackage [
	"Adds class name, instance variables, and method definitions to response"
	|  aClassCollection  |
	aClassCollection := aPackage classes asArray.
	aClassCollection collect: [ :cl | 
		responce nextPutAll: '## Class: ', cl name asString, String cr.
		self instanceVariablesFor: cl.
		self methodsFor: cl.
		responce nextPutAll: String cr.
	].
	
]

{ #category : 'accessing' }
AI_PackagesAsOllamaSystem >> for: aPackageList [
	"The input is {package1. package2. package3}."
	responce := WriteStream on: ''.
	aPackageList do: [ :pack | self classesInPackage: (RPackageSet named: pack) ].
	^ responce contents
	
]

{ #category : 'accessing' }
AI_PackagesAsOllamaSystem >> forClass: aClass [
	"The input is aClass, return ollama system input."
	responce := WriteStream on: ''.
	responce nextPutAll: '## Class: ', aClass name asString, String cr.
	self instanceVariablesFor: aClass.
	self methodsFor: aClass.
	responce nextPutAll: String cr.
	^ responce contents
	
]

{ #category : 'internal' }
AI_PackagesAsOllamaSystem >> instanceVariablesFor: aClass [
	"Add all the instance variables of aClass to response"
	responce nextPutAll: '### Instance variables for ', aClass name asString, ': '.
	aClass instVarNames  collect: [:each | responce nextPutAll: each asString, ' '].
	responce nextPutAll: String cr.
]

{ #category : 'internal' }
AI_PackagesAsOllamaSystem >> methodsFor: aClass [
	"Add all methods grouped by protocol, including full source code"

	responce nextPutAll: '### Methods for ', aClass name asString, ':', String cr.

	aClass protocolNames asSortedCollection do: [:protocol |
		responce nextPutAll: '#### Protocol: ', protocol, String cr.
		(aClass selectorsInProtocol: protocol) do: [:selector |
			responce nextPutAll: (aClass >> selector) sourceCode, String cr, String cr.
		].
	].
]
