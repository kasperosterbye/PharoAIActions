"
Fabbe comment
"
Class {
	#name : 'AilienApi',
	#superclass : 'Object',
	#instVars : [
		'model',
		'system',
		'promptPrefix',
		'response'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'ollama models' }
AilienApi class >> modelNames [
	"returns an array with one item per model."
	^ self models collect: [ :model | model at: 'name' ]
]

{ #category : 'accessing' }
AilienApi class >> models [
	"Return a list of available Mistral models from the API"
	self subclassResponsibility
]

{ #category : 'initialization' }
AilienApi >> initialize [ 
	super initialize.
	"self model: (self class modelNames) first."
	self model: 'codestral-latest'.
	self system: ''.
	self promptPrefix: ''.
]

{ #category : 'accessing' }
AilienApi >> model [

	^ model
]

{ #category : 'accessing' }
AilienApi >> model: anObject [

	model := anObject
]

{ #category : 'printing' }
AilienApi >> printOn: string [
	string << 'MistralApi: ' << self model.
]

{ #category : 'accessing' }
AilienApi >> promptPrefix [

	^ promptPrefix
]

{ #category : 'accessing' }
AilienApi >> promptPrefix: anObject [

	promptPrefix := anObject
]

{ #category : 'accessing' }
AilienApi >> response [

	^ response
]

{ #category : 'accessing' }
AilienApi >> response: anObject [

	response := anObject
]

{ #category : 'accessing' }
AilienApi >> system [

	^ system
]

{ #category : 'accessing' }
AilienApi >> system: anObject [

	system := anObject
]
