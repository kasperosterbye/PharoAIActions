Class {
	#name : 'AIABibLaTex',
	#superclass : 'Object',
	#classVars : [
		'Papers'
	],
	#category : 'AIAExperiments',
	#package : 'AIAExperiments'
}

{ #category : 'as yet unclassified' }
AIABibLaTex >> all20 [
	Papers := OrderedCollection new.
	0 to: 19 do: [ :id | 
		Papers add: (self bibFor: id) ].
	^ Papers 
]

{ #category : 'as yet unclassified' }
AIABibLaTex >> bibFor: id [
	| response prompt |
	prompt := 'Please produce a biblatex format for the paper. Please add a note about the conclusion in all of the paper where you can deduce it from the paper itself. Please use it references as well as its own format. If possible, just return the biblatex format, and no explanation'.
	response := prompt q0: [ self paper: id ].
	(response beginsWith: '```') 
		ifTrue:[ ^ String cr join: response lines allButFirst allButLast] 
		ifFalse: [ ^ response ].
]

{ #category : 'as yet unclassified' }
AIABibLaTex >> paper: id [
	| paper |
	paper := 'Comment{1}.txt' format: { 100 + id }.
	^ (FileSystem disk root / 'Users' / 'kasper' / 'D' / 'Pharo' / 'images' / 'AIActions03' / 'Papers' / paper ) readStream contents trimBoth
]
