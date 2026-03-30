Class {
	#name : 'MicroUMLSequenceDiagram',
	#superclass : 'Object',
	#instVars : [
		'actors',
		'messages',
		'actorGap',
		'lifelineHeight',
		'canvas'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'examples' }
MicroUMLSequenceDiagram class >> diagram01 [
	<example>

    | sd |
    sd := self new.
    sd addActor: 'Login System'. 
    sd addActor: 'Database'.
    sd addMessage: 'verify ' from: 'Login System' to: 'Database'.
    sd addReturn: 'return something long here' from: 'Database' to: 'Login System'.
    sd build.
]

{ #category : 'examples' }
MicroUMLSequenceDiagram class >> diagram02 [

	<example>
	| sd |
	sd := self new.
	sd addActor: 'Playground'.
	sd addActor: 'Login System'.
	sd addActor: 'Database'.
	sd addMessage: 'call ' from: 'Playground' to: 'Login System'.
	sd addMessage: 'verify ' from: 'Login System' to: 'Database'.
	sd addReturn: '' from: 'Database' to: 'Playground'.
	sd build
]

{ #category : 'construction' }
MicroUMLSequenceDiagram >> add: type name: aDescription from: fromName to: toName [
    | message |
    message := MicroUMLSDMessages new.
    message
        description: aDescription;
        fromActor: (actors detect: [ :a | a name = fromName ]);
        toActor: (actors detect: [ :a | a name = toName ]);
        messageType: type.
    messages add: message.
    ^ message
]

{ #category : 'construction' }
MicroUMLSequenceDiagram >> addActor: aString [

	| actor |
	actor := MicroUMLSDActor new.
	actor
		name: aString;
		index: actors size.
	actors add: actor.
	^ actor
]

{ #category : 'construction' }
MicroUMLSequenceDiagram >> addMessage: aDescription from: fromName to: toName [
	^ self add: #call name: aDescription from: fromName to: toName
]

{ #category : 'construction' }
MicroUMLSequenceDiagram >> addReturn: aDescription from: fromName to: toName [
	^ self add: #return name: aDescription from: fromName to: toName
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> build [

	canvas := RSCanvas new.
	self computeActorPositions;
		computeMessagePositions;
		drawActors;
		drawLifelines;
		drawMessages.
	canvas @ RSCanvasController.
	canvas open
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> computeActorPositions [

	| currentX maxDistance |
	currentX := actorGap.
	actors first x: currentX.
	2 to: actors size do: [ :index |
			| a b messagesBetween |
			a := actors at: index -1.
			b := actors at: index .

			messagesBetween := messages select: [ :msg |
				(msg fromActor = a and: [ msg toActor = b ]) or: [ msg fromActor = b and: [ msg toActor = a ] ] ].
			maxDistance := messagesBetween
				 ifEmpty: [ actorGap ]
				 ifNotEmpty: [ :msgs | 
				 	(msgs collect: [ :msg | (RSLabel new text: msg description) textWidth ]) max + actorGap + 10].
			b x: a x + (maxDistance max: (a width / 2) + (b width / 2) + (2*actorGap) )   ].

]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> computeMessagePositions [
    messages doWithIndex: [ :msg :i |
        msg y: MicroUMLSDMessages topMargin + (i * MicroUMLSDMessages messageGap) ]
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> drawActors [
	canvas addAll: (actors collect: [ :actor | actor draw ])
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> drawLifelines [
    canvas addAll: (actors collect: [ :actor |
        RSLine new
            startPoint: actor x @ (MicroUMLSDActor boxHeight / 2);
            endPoint: actor x @ (MicroUMLSDActor boxHeight / 2 + self lifelineHeight);
            dashArray: #(5 5);
            color: Color black;
            yourself ])
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> drawMessages [
    messages do: [ :msg | canvas addAll: msg draw ]
]

{ #category : 'initialization' }
MicroUMLSequenceDiagram >> initialize [
	actors := OrderedCollection new.
	messages := OrderedCollection new.
	actorGap := MicroUMLSDActor actorGap.
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> lifelineHeight [
    ^ MicroUMLSDMessages topMargin 
        + (messages size * MicroUMLSDMessages messageGap) 
        + MicroUMLSDMessages bottomMargin
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> new_computeActorPositions [

	| currentX maxDistance |
	currentX := actorGap.
	actors first x: currentX.
	2 to: actors size do: [ :index |
			| a b messagesBetween |
			a := actors at: index -1.
			b := actors at: index .

			messagesBetween := messages select: [ :msg |
				(msg fromActor = a and: [ msg toActor = b ]) or: [ msg fromActor = b and: [ msg toActor = a ] ] ].
			maxDistance := messagesBetween
				 ifEmpty: [ actorGap ]
				 ifNotEmpty: [ :msgs | 
				 	(msgs collect: [ :msg | (RSLabel new text: msg description) textWidth ]) max + actorGap + 10].
			b x: (maxDistance max: (a width / 2) + (b width / 2) + (2*actorGap) )   ].

]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> nextX [
	actors isEmpty ifTrue: [ ^ actorGap ].
	^ actors last x + (actors last width / 2 ) + actorGap 
]

{ #category : 'roassal' }
MicroUMLSequenceDiagram >> old_computeActorPositions [
    | currentX minDistance |
    currentX := actorGap.
    actors doWithIndex: [ :actor :i |
        actor x: currentX + 10.
        i < actors size ifTrue: [
            | nextActor messagesBetween |
            nextActor := actors at: i + 1.
            messagesBetween := messages select: [ :msg |
                (msg fromActor = actor and: [ msg toActor = nextActor ]) or:
                [ msg fromActor = nextActor and: [ msg toActor = actor ] ] ].
            minDistance := messagesBetween
                ifEmpty: [ actorGap ]
                ifNotEmpty: [ :msgs |
                    (msgs collect: [ :msg |
                        (RSLabel new text: msg description) textWidth ]) max ].
            currentX := actor x + minDistance ] ]
]

{ #category : 'accessing' }
MicroUMLSequenceDiagram >> yForMessage: n [
    ^ MicroUMLSDMessages topMargin + (n * MicroUMLSDMessages messageGap)
]
