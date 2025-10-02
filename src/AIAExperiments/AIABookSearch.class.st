Class {
	#name : 'AIABookSearch',
	#superclass : 'Object',
	#classInstVars : [
		'digest'
	],
	#category : 'AIAExperiments',
	#package : 'AIAExperiments'
}

{ #category : 'as yet unclassified' }
AIABookSearch class >> getDigest [
	^ digest contents
]

{ #category : 'as yet unclassified' }
AIABookSearch class >> replyTo: question [
	| initialReply firstLine index book background responce |
	initialReply := question , '. Please mention the chapter number you find best to answer this prompt. If the background does not have detailed answer, please say: "it is a cool book, but X is not there"' 
		q0: [ AIABookSearch getDigest. ].
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
AIABookSearch class >> setDigest [
	| book prompt background |
	book := (FileSystem disk root / 'Users' / 'kasper' / 'Downloads' 
				/ '2023-09-02-DeepIntoPharo.txt' ) readStream contents trimBoth.
	digest := WriteStream on: ''.
	1 to: 18 do: [ :index | 
		prompt := 'Please give a detailed list of what is in Chapter {1}. 	Please structure it as Main purpose, Key concepts, How to use, Common pitfalls' format: {index}.
		background := book 
				copyFrom: (book findString: ('Chapter {1}' format: {index})) 
				to: (book findString: ('Chapter {1}' format: {index + 1})) - 1.
		digest << ('# Chapter ', index asString) << String lf << String lf 
			<< (prompt q0: [ background ])
			<< String lf << String lf .
	].
	

]
