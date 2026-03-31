Class {
	#name : 'MicroUMLSDFoo',
	#superclass : 'Object',
	#instVars : [
		'tally'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'as yet unclassified' }
MicroUMLSDFoo >> foo2 [
	| trace |
trace := OrderedCollection new.
thisContext sender
    runSimulated: [ AIASourceCode forClass: AIAClassComment. ]
    contextAtEachStep: [ :current |
        "Vi logger kun, når konteksten skifter til en interessant klasse"
        (current method methodClass package name = 'AIActions') ifTrue: [
            trace add: { 
                #from -> current sender methodClass name. 
                #to -> current method methodClass name. 
                #selector -> current selector 
            } asDictionary.
        ]
    ].
]

{ #category : 'as yet unclassified' }
MicroUMLSDFoo >> sdFor: aBlock [
	tally := MessageTally 
		tallySendsTo: nil 
		inBlock: aBlock 
		showTree: true 
		closeAfter: false 
		openResultWindow: false.
	self halt.
	^ tally
	
"self theClass name"
]

{ #category : 'as yet unclassified' }
MicroUMLSDFoo >> types: aBlock inPackage: packageName [
	| trace |
trace := OrderedCollection new.
thisContext sender
    runSimulated: aBlock 
    contextAtEachStep: [ :current |
		  "Vi logger kun, når konteksten skifter til en interessant klasse"
        (current method methodClass package name = packageName) ifTrue: [
	| from to sel |
		from := current sender methodClass .
		to := current method methodClass .
      sel -> current selector.
		self halt.
            trace add: { 
                #from -> current sender methodClass name. 
                #to -> current method methodClass name. 
                #selector -> current selector 
            } .
        ]
    ].
^ trace
]

{ #category : 'as yet unclassified' }
MicroUMLSDFoo >> types: aBlock inTag: tagName [
	| trace |
trace := OrderedCollection new.
thisContext sender
    runSimulated: aBlock 
    contextAtEachStep: [ :current |
        "Vi logger kun, når konteksten skifter til en interessant klasse"
        (current method methodClass package name = tagName) ifTrue: [
            trace add: { 
                #from -> current sender methodClass name. 
                #to -> current method methodClass name. 
                #selector -> current selector 
            } asDictionary.
        ]
    ].
^ trace
]
