"
AIABibLaTex is a utility class designed to generate BibLaTeX entries for academic papers. It reads paper content from text files and uses an AI-driven query to produce formatted BibLaTeX entries, including notes derived from the paper's conclusion or abstract. The class maintains a shared collection of generated entries in the Papers` variable.

## Usage Example
In the Playground, you can generate BibLaTeX entries for papers 1 to 20 and inspect the resulting string:

```
bib := AIABibLaTex new.
bib all20.
bib papersAsString
````

Select the last line and press Cmd+I (or right-click and select 'Inspect') to view the BibLaTeX entries as a string.
"
Class {
	#name : 'AIABibLaTex',
	#superclass : 'Object',
	#classVars : [
		'Papers'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'examples' }
AIABibLaTex class >> biblatex [
	<example>
	self new papersAsString inspect
]

{ #category : 'as yet unclassified' }
AIABibLaTex class >> playground [
	"Provides examples for using the AIABibLaTex class in a playground environment."
	<example>
	'''Please produce a biblatex format for the paper with a note from its conclusion or abstract. Only for the paper itself, not for its references. If possible, just return the biblatex format, and no explanation'' q0: [(FileSystem disk root / ''Users'' / ''kasper'' / ''D'' / ''Pharo'' / ''images'' / ''AIActions03'' / ''Papers'' / ''Comment101.txt'' ) readStream contents trimBoth].

AIABibLaTex new bibFor: 12.

AIABibLaTex new all20.

''Which papers are about making comments, and which are about using them'' q0: [AIABibLaTex new papersAsString] .' inspect
]

{ #category : 'as yet unclassified' }
AIABibLaTex >> all20 [
	"Generates BibLaTeX entries for papers with IDs 1 to 20 and stores them in the shared variable Papers"
	Papers := OrderedCollection new.
	1 to: 20 do: [ :id | 
		Papers add: (self bibFor: id) ].
	^ Papers 
]

{ #category : 'as yet unclassified' }
AIABibLaTex >> bibFor: id [
	"Returns a BibLaTeX entry for a paper with the given ID, including a note from its conclusion or abstract."
	| response  |
	response := 'Please produce a biblatex format for the paper with a note from its conclusion or abstract. Only for the paper itself, not for its references. If possible, just return the biblatex format, and no explanation' q0: [ self paper: id ].
	(response beginsWith: '```') 
		ifTrue:[ ^ String cr join: response lines allButFirst allButLast] 
		ifFalse: [ ^ response ].
]

{ #category : 'as yet unclassified' }
AIABibLaTex >> paper: id [
	"Returns the content of the paper file for a given ID, trimmed of leading and trailing whitespace."
	| paper |
	paper := 'LarsBendix.txt' "format: { 100 + id }".
	^ (FileSystem disk root / 'Users' / 'kasper' / 'D' / 'Pharo' / 'images' / 'AIActions03' / 'Papers' / paper ) readStream contents trimBoth
]

{ #category : 'as yet unclassified' }
AIABibLaTex >> papersAsString [
	"Returns the BibLaTeX entries for all papers as a single string, separated by newlines."
	Papers ifNil: [ self all20 ].
	^ String cr, String cr join: Papers
]
