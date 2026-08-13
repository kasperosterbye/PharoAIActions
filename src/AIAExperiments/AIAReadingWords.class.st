Class {
	#name : 'AIAReadingWords',
	#superclass : 'SpPresenter',
	#category : 'AIAExperiments-Reading',
	#package : 'AIAExperiments',
	#tag : 'Reading'
}

{ #category : 'background' }
AIAReadingWords class >> danishWords [
	^ String lf join: ( self danishWords01 lines collect: [ :line | line substrings second ])
]

{ #category : 'background' }
AIAReadingWords class >> danishWords01 [
	"https://da.wiktionary.org/wiki/Wiktionary:Top_10000_(Dansk), 
	select web, paste it to texMate, remove the first and last noncense text.
	paste the result here, run the method, and store the result in ../../dansk10000.txt"
	
]

{ #category : 'as yet unclassified' }
AIAReadingWords >> wordsOfSize: n count: k [
	| result file |

	result := OrderedCollection new.
	"file := '../../dsdo.txt' asFileReference."
	file := '../../dansk10000.txt' asFileReference.

	file readStreamDo: [ :stream |
		[ stream atEnd ] whileFalse: [
			| word |
			word := stream nextLine.
			(word size = n and: [  
				word first isLowercase and: [
				word isLiteralSymbol  ]])
				ifTrue: [ result add: word ] ] ].
	Transcript << ('Size: ', n asString, ' : ', result size asString) << String lf.
	^ result shuffled first: (k min: result size)
]
