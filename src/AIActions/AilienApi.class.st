Class {
	#name : 'AilienApi',
	#superclass : 'Object',
	#instVars : [
		'model',
		'tools',
		'history'
	],
	#classInstVars : [
		'modelLLM'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'private' }
AilienApi class >> defaultModel [
	modelLLM ifNil: [ modelLLM := self modelNames first ].
	^ modelLLM 
]

{ #category : 'private' }
AilienApi class >> defaultModel: modelNumber [
	"Sets the default model for the Ollama API, ensuring it exists in the available models list. If not, defaults to the first model."

	modelLLM := self modelNames 
		at: modelNumber 
		ifAbsent: [ modelLLM := self modelNames first ]
]

{ #category : 'AI models' }
AilienApi class >> modelNames [
	"returns an array with one item per model."
	^ self models collect: [ :model | model at: 'name' ]
]

{ #category : 'accessing' }
AilienApi class >> models [
	"Subclasses should implement this to return a list of available models from the API"
	self subclassResponsibility
]

{ #category : 'initialization' }
AilienApi >> assistant: aString [
	history add: 'assistant' -> aString
]

{ #category : 'initialization' }
AilienApi >> chatAllHistory [
	| historyText |
	historyText := WriteStream on: ''.
	history do: [ :item | 
		historyText << '## ' << item key << String cr
			<< item value << String cr << String cr
		 ].
	^ historyText contents
]

{ #category : 'initialization' }
AilienApi >> chatHistory [
	| historyText counter |
	historyText := WriteStream on: ''.
	counter := 1.
	history allButFirst do: [ :item | 
		historyText << '## ['<< counter asString << '] ' << item key << String cr
			<< item value << String cr << String cr.
			counter := counter + 1.
		 ].
	^ historyText contents
]

{ #category : 'ollama models' }
AilienApi >> getResponse [
	"This method initiates an AI process to retrieve a response, displaying progress and handling interruptions."

	[ :job | | aiProcess |
		aiProcess := [ self loadResponse ] newProcess.
		aiProcess priority: Processor userBackgroundPriority. 
		aiProcess resume.
		SystemProgressMorph uniqueInstance position: 10@20.
		job interruptBlock: [ 
			aiProcess terminate.
			self assistant: 'AI based response Terminated'.
			^ self
		].
		1 to: 300 do: [:each |
			job
				progress: ((1/300) * each) ;
				title: ('AI working {1} of 30' format: {(each/10) asFloat printString}).
				self response ifNil: [100 milliSeconds wait].
		].
	] asJob run.
]

{ #category : 'initialization' }
AilienApi >> history [
	^ history
]

{ #category : 'initialization' }
AilienApi >> initialize [ 
	super initialize.
	self model: ''.
	history := OrderedCollection new.
]

{ #category : 'accessing' }
AilienApi >> jsonHistory [
	| jsonHistory |
	jsonHistory := OrderedCollection new.
	history do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'content' -> item value.})
	].
	^ jsonHistory asArray.
]

{ #category : 'mistral models' }
AilienApi >> loadResponse [
		self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> model [

	^ model
]

{ #category : 'accessing' }
AilienApi >> model: anObject [

	model := anObject
]

{ #category : 'initialization' }
AilienApi >> prompt: aString [
	history add: 'user' -> aString
]

{ #category : 'accessing' }
AilienApi >> response [
	(history last key = 'assistant')
		ifTrue: [ ^ history last value ]
		ifFalse: [ ^ nil ]
]

{ #category : 'accessing' }
AilienApi >> system [
	history isEmpty ifTrue: [ ^ nil ].
	history first key = 'system'
		ifTrue: [ ^ history first value ]
		ifFalse: [ ^ nil ]
]

{ #category : 'initialization' }
AilienApi >> system: aString [
	history size = 0 ifFalse: [ self error: 'system call must be first' ].
	history add: 'system' -> aString
]

{ #category : 'initialization' }
AilienApi >> user: aString [
	history add: 'user' -> aString
]
