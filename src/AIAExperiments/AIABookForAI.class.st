Class {
	#name : 'AIABookForAI',
	#superclass : 'Object',
	#classInstVars : [
		'digest'
	],
	#category : 'AIAExperiments-ExperimentsTools',
	#package : 'AIAExperiments',
	#tag : 'ExperimentsTools'
}

{ #category : 'as yet unclassified' }
AIABookForAI class >> getDigest [
	^ digest contents
]

{ #category : 'as yet unclassified' }
AIABookForAI class >> q: question [
	| initialReply firstLine index book background responce |
	initialReply := question , '. Please mention the chapter number you find best to answer this prompt. If the background does not have detailed answer, please say: "it is a cool book, but X is not there"' 
		q0: [ self getDigest. ].
	^ initialReply 
]

{ #category : 'as yet unclassified' }
AIABookForAI class >> replyTo: question [
	| initialReply firstLine index book background responce |
	initialReply := question , '. Please mention the chapter number you find best to answer this prompt. If the background does not have detailed answer, please say: "it is a cool book, but X is not there"' 
		q0: [ self getDigest. ].
	firstLine := initialReply lines first.
	(firstLine includesSubstring: 'It is a cool book, but ')
		ifTrue: [ ^ firstLine ].
	index := firstLine squeezeOutNumber.
	book := (FileSystem disk root / 'Users' / 'kasper' / 'Downloads' 
				/ '2023-09-02-DeepIntoPharo.txt' ) readStream contents trimBoth.
	digest := WriteStream on: ''.
	background := book 
				copyFrom: (book findString: ('Chapter {1}' format: {index})) 
				to: (book findString: ('Chapter {1}' format: {index + 1})) - 1.
	responce := (question q0: [ background ]).
	^ responce .
]

{ #category : 'initialization' }
AIABookForAI class >> setDigest [
	| book prompt background |
	book := (FileSystem disk root / 'Users' / 'kasper' / 'Downloads' 
				/ '2023-09-02-DeepIntoPharo.txt' ) readStream contents trimBoth.
	digest := WriteStream on: ''.
	14 to: 14 do: [ :index | 
		prompt := 'Compress Chapter {1} into a dense technical reference for an AI assistant answering Pharo questions.
Rules: no prose, no examples unless critical, no repetition, preserve all precise facts and distinctions.
Format: concept name followed by colon and one-line definition. Group under: Core mechanics, API, Gotchas.' format: {index}.
		background := book 
				copyFrom: (book findString: ('Chapter {1}' format: {index})) 
				to: (book findString: ('Chapter {1}' format: {index + 1})) - 1.
		digest << ('# Chapter ', index asString) << String lf << String lf 
			<< (prompt q0: [ background ])
			<< String lf << String lf .
	].
	

]
