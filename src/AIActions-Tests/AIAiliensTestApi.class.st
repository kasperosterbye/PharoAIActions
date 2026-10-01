Class {
	#name : 'AIAiliensTestApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'AI models' }
AIAiliensTestApi class >> modelNames [
	^ (self modelNamesAndReasoning collect: [ :each | each key ]) asArray
]

{ #category : 'AI models' }
AIAiliensTestApi class >> modelNamesAndReasoning [
	^ {
		'alpha' -> #(). }
]
