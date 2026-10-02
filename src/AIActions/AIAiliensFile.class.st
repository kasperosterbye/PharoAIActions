"
The `AIAiliensFile` class manages the configuration and interaction with AI providers, handling model definitions, comments, and selection history.
"
Class {
	#name : 'AIAiliensFile',
	#superclass : 'Object',
	#instVars : [
		'rootDirectory',
		'comments',
		'models'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
AIAiliensFile class >> commentLinesOf: aProviderClass [
	| method |
	method := aProviderClass class
		compiledMethodAt: #modelNamesAndReasoning
		ifAbsent: [
			aProviderClass class
				compiledMethodAt: #modelNames
				ifAbsent: [ ^ #() ] ].
	^ (method ast comments collect: [ :each | each contents ])
		flatCollect: [ :text | text lines collect: [ :line | line trimBoth ] ]
]

{ #category : 'accessing' }
AIAiliensFile class >> default [
	"Minimal configuration used when no ailiens.txt exists."

	^ self fromString: '# MistralApi
Look at https://docs.mistral.ai/getting-started/models/models_overview/ to see the list
- codestral-latest
- zai-glm-5-2
- mistral-medium-3-5
- mistral-large-latest'
]

{ #category : 'accessing' }
AIAiliensFile class >> defaultRootDirectory [
	^ FileLocator home / 'D' / 'Pharo'
]

{ #category : 'accessing' }
AIAiliensFile class >> fileName [
	^ 'ailiens.txt'
]

{ #category : 'accessing' }
AIAiliensFile class >> fromImage [
	"Build the file contents from the model lists compiled in this image.
	Ollama asks its server, and test providers do not belong in the file."
	| ailiens |
	ailiens := self new.
	(AilienApi providers reject: [ :cls |
		cls package name endsWith: '-Tests' ] )
		do: [ :cls |
			ailiens
				addProvider: cls name
				comment: (self commentLinesOf: cls)
				modelsAndReasoning: cls modelNamesAndReasoning ].
	^ ailiens
]

{ #category : 'accessing' }
AIAiliensFile class >> fromString: aString [
	^ self new
		parse: aString;
		yourself
]

{ #category : 'accessing' }
AIAiliensFile class >> historyFileName [
	^ 'ailiens-history.txt'
]

{ #category : 'accessing' }
AIAiliensFile class >> loadFrom: aDirectory [
	"Loads the Ailiens file from a specified directory, handling both existing and default configurations."
	| file ailiens |

	file := aDirectory / self fileName.

	ailiens := file exists
		ifTrue: [ self fromString: file contents ]
		ifFalse: [ self default ].

	ailiens rootDirectory: aDirectory.
	^ ailiens
]

{ #category : 'accessing' }
AIAiliensFile class >> loadRawFrom: aDirectory [
	"Loads the raw contents of the Ailiens file from a specified directory."
	^ (self fromString: (aDirectory / self fileName) contents)
		rootDirectory: aDirectory;
		yourself
]

{ #category : 'initialization' }
AIAiliensFile >> addProvider: aProviderName comment: lines modelsAndReasoning: associations [
	self ensureProvider: aProviderName.
	(comments at: aProviderName) addAll: (lines reject: [ :each | each isEmpty ]).
	(models at: aProviderName) addAll:
		(associations collect: [ :each | each key -> each value asArray ])
]

{ #category : 'accessing' }
AIAiliensFile >> commentFor: aProviderName [
	^ String cr join: (comments at: aProviderName)
]

{ #category : 'accessing' }
AIAiliensFile >> comments [

	^ comments
]

{ #category : 'accessing' }
AIAiliensFile >> comments: anObject [

	comments := anObject
]

{ #category : 'installing' }
AIAiliensFile >> compileModelsOf: aProviderName into: aProviderClass [
	| comment source |
	comment := (self commentFor: aProviderName) copyReplaceAll: '"' with: '""'.
	source := String streamContents: [ :stream |
		stream nextPutAll: 'modelNamesAndReasoning'; cr.
		comment ifNotEmpty: [
			stream tab; nextPut: $"; nextPutAll: comment; nextPut: $"; cr; cr ].
		stream tab; nextPutAll: '^ {'.
		(models at: aProviderName) do: [ :each |
			stream cr; tab; tab.
			stream print: each key; nextPutAll: ' -> '; print: each value; nextPut: $. ].
		stream nextPutAll: ' }' ].
	aProviderClass class compile: source classified: 'AI models'.
]

{ #category : 'saving' }
AIAiliensFile >> contents [
	"The Microdown text of the file."
	^ String streamContents: [ :stream |
		models keysAndValuesDo: [ :name :list |
			stream nextPutAll: '# '; nextPutAll: name; cr.
			(comments at: name) do: [ :line |
				stream nextPutAll: line; cr ].
			list do: [ :each |
				stream nextPutAll: '- '; nextPutAll: each key.
				each value do: [ :level |
					stream space; nextPutAll: level ].
				stream cr ].
			stream cr ] ]
]

{ #category : 'initialization' }
AIAiliensFile >> ensureProvider: aProviderName [
	models at: aProviderName ifAbsentPut: [ OrderedCollection new ].
	comments at: aProviderName ifAbsentPut: [ OrderedCollection new ]
]

{ #category : 'initialization' }
AIAiliensFile >> initialize [
	super initialize.
	comments := OrderedDictionary new.
	models := OrderedDictionary new.
	rootDirectory := self class defaultRootDirectory
]

{ #category : 'installing' }
AIAiliensFile >> install [
	"Validate every provider before compiling any, so a bad file
	leaves the image untouched."
	| classes |
	classes := self providerNames collect: [ :name | self providerClassFor: name ].
	classes with: self providerNames do: [ :cls :name |
		self compileModelsOf: name into: cls ]
]

{ #category : 'accessing' }
AIAiliensFile >> modelNamesAndReasoningFor: aProviderName [
	^ (models at: aProviderName) asArray
]

{ #category : 'accessing' }
AIAiliensFile >> modelNamesFor: aProviderName [
	^ ((models at: aProviderName) collect: [ :each | each key ]) asArray
]

{ #category : 'accessing' }
AIAiliensFile >> models [

	^ models
]

{ #category : 'accessing' }
AIAiliensFile >> models: anObject [

	models := anObject
]

{ #category : 'initialization' }
AIAiliensFile >> parse: aString [
	"Headings start a provider, '- ' lines are models with optional
	reasoning levels, any other non-blank line is comment text."
	| current |
	current := nil.
	aString lines do: [ :line |
		(line beginsWith: '# ')
			ifTrue: [
				current := (line allButFirst: 2) trimBoth asSymbol.
				self ensureProvider: current ]
			ifFalse: [
				current ifNotNil: [ self parseLine: line for: current ] ] ]
]

{ #category : 'initialization' }
AIAiliensFile >> parseLine: aLine for: aProviderName [
	| trimmed words |
	trimmed := aLine trimBoth.
	trimmed ifEmpty: [ ^ self ].
	(trimmed beginsWith: '- ') ifFalse: [
		(comments at: aProviderName) add: trimmed.
		^ self ].
	words := (trimmed allButFirst: 2) substrings.
	(models at: aProviderName) add:
		words first -> (words allButFirst collect: [ :each | each asSymbol ])
]

{ #category : 'installing' }
AIAiliensFile >> providerClassFor: aProviderName [
	| cls |
	cls := Smalltalk globals
		at: aProviderName
		ifAbsent: [ self error: 'Unknown provider: ', aProviderName ].
	(AilienApi allSubclasses includes: cls) ifFalse: [
		self error: 'Not an AilienApi provider: ', aProviderName ].
	^ cls
]

{ #category : 'accessing' }
AIAiliensFile >> providerNames [
	^ models keys asArray
]

{ #category : 'selection history' }
AIAiliensFile >> recordSelection: aProviderName model: aModelName [
	| file old |
	rootDirectory ensureCreateDirectory.
	file := rootDirectory / self class historyFileName.
	old := file exists ifTrue: [ file contents ] ifFalse: [ '' ].
	file ensureDelete.
	file writeStreamDo: [ :stream |
		stream
			nextPutAll: old;
			print: DateAndTime now; space;
			nextPutAll: aProviderName; space;
			nextPutAll: aModelName; cr ]
]

{ #category : 'accessing' }
AIAiliensFile >> rootDirectory [
	^ rootDirectory
]

{ #category : 'accessing' }
AIAiliensFile >> rootDirectory: anObject [

	rootDirectory := anObject
]

{ #category : 'saving' }
AIAiliensFile >> save [
	| file |
	rootDirectory ensureCreateDirectory.
	file := rootDirectory / self class fileName.
	file ensureDelete.
	file writeStreamDo: [ :stream | stream nextPutAll: self contents ]
]

{ #category : 'selection history' }
AIAiliensFile >> selectionHistory [
	| file |
	file := rootDirectory / self class historyFileName.
	file exists ifFalse: [ ^ #() ].
	^ (file contents lines reject: [ :each | each isEmpty ])
		collect: [ :line | AIAiliensSelection fromLine: line ]
]
