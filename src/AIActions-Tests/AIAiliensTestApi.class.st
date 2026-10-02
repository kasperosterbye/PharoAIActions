"
A minimal test double for `AilienApi`, used by the AIActions test suite. It stands in for a real AI provider API, exposing a single dummy model (`alpha`) with no reasoning variants, so that API-dependent behaviour can be exercised without contacting an external service.
"
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
