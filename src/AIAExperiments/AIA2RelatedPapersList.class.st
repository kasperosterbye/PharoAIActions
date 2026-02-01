Class {
	#name : 'AIA2RelatedPapersList',
	#superclass : 'Object',
	#instVars : [
		'referencesList'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIAExperiments-PaperWriting',
	#package : 'AIAExperiments',
	#tag : 'PaperWriting'
}

{ #category : 'accessing' }
AIA2RelatedPapersList class >> clearDefault [
	<example>
    default := nil
]

{ #category : 'accessing' }
AIA2RelatedPapersList class >> default [
	default ifNil: [ default := self new ].
	^ default
]

{ #category : 'as yet unclassified' }
AIA2RelatedPapersList >> papersBibtex [
	| lists bib response |
	response := WriteStream on: ''.
   lists := AIA2RelatedPaperExtractor extractorList. 
	1 to: lists size do: [ :index |
		bib := (lists at: index) arXivExtracted at: 'bibtex'.
		bib := self slitBibtexToDictionary: bib.
		response 
			<< '(' << index asString << ') '
			<< (bib at: 'author') << String lf
			<< '**' << (bib at: 'title') << '**' << String lf
			<< (bib at: 'year') << ' '
			<< (bib at: 'journal' ifPresent: [ :j | j, '. ' ] ifAbsent: [ '' ])
			<< (bib at: 'url' ifPresent: [ :j | j, '. ' ] ifAbsent:  [  
					(bib at: 'publisher' ifAbsent:  [ '' ]) , ' - '
					, (bib at: 'doi' ifAbsent:  [ '' ]) ])
			<< String lf << String lf.
	 ].
	^ response contents
]

{ #category : 'as yet unclassified' }
AIA2RelatedPapersList >> slitBibtexToDictionary: bib [
	| internal doc|
	internal := bib copyFrom: 2 to: bib size - 1.
	doc := Dictionary new.
	1 to: internal size do: [ :index | 
		| raw  key value |
		internal at: index put: (internal at: index) trimLeft.
		raw := internal at: index.
		key := (raw copyUpTo: $=) trimBoth.
		value := (raw copyAfter: $=) trimBoth.
		value := value trimBoth: [ :char | '{}(),' includes: char ].
		doc at: key put: value.
		].
	^ doc
]
