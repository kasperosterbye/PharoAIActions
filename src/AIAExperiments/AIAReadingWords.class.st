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

	result := OrderedCollection new: k.
	file := '../../dsdo.txt' asFileReference.

	file readStreamDo: [ :stream |
		[ stream atEnd or: [ result size = k ] ] whileFalse: [
			| word |
			word := stream nextLine.
			(word size = n and: [
				(word includes: $-) not and: [
				(word includes: $') not ]])
				ifTrue: [ result add: word ] ] ].

	^ result asArray
]
