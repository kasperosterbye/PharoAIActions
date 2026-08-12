Class {
	#name : 'AIAReadingWords',
	#superclass : 'SpPresenter',
	#category : 'AIAExperiments-Reading',
	#package : 'AIAExperiments',
	#tag : 'Reading'
}

{ #category : 'as yet unclassified' }
AIAReadingWords >> wordsOfSize: n count: k [
	| result file |

	result := OrderedCollection new.
	file := '../../dsdo.txt' asFileReference.

	file readStreamDo: [ :stream |
		[ stream atEnd ] whileFalse: [
			| word |
			word := stream nextLine.
			(word size = n and: [  
				word first isLowercase and: [
				word isLiteralSymbol  ]])
				ifTrue: [ result add: word ] ] ].
	^ result shuffled first: (k min: result size)
]
