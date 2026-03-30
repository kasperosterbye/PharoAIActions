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
    sd addMessage: 'Verify credentials' from: 'Login System' to: 'Database'.
    sd addReturn: 'Return verification', String cr,  'result' from: 'Database' to: 'Login System'.
    sd build.

	"@startuml
actor User
participant ""Login System"" as LS
participant ""Database"" as DB

User -> LS : Enter credentials
LS -> DB : Verify credentials
DB --> LS : Return verification result
LS --> User : Grant/deny access
@enduml"
]

{ #category : 'adding' }
MicroUMLSequenceDiagram >> add: type name: aDescription from: fromName to: toName [
    | message |
    message := MicroUMLSDMessages new.
    message
        description: aDescription;
        fromActor: (actors detect: [ :a | a name = fromName ]);
        toActor: (actors detect: [ :a | a name = toName ]);
        y: MicroUMLSDMessages topMargin + (messages size * MicroUMLSDMessages messageGap);
        messageType: type.
    messages add: message.
    ^ message
]

{ #category : 'adding' }
MicroUMLSequenceDiagram >> addActor: aString [

	| actor |
	actor := MicroUMLSDActor new.
	actor
		name: aString;
		index: actors size;
		x: self nextX + ( actor width / 2).
	actors add: actor.
	^ actor
]

{ #category : 'adding' }
MicroUMLSequenceDiagram >> addMessage: aDescription from: fromName to: toName [
	^ self add: #call name: aDescription from: fromName to: toName
]

{ #category : 'adding' }
MicroUMLSequenceDiagram >> addReturn: aDescription from: fromName to: toName [
	^ self add: #return name: aDescription from: fromName to: toName
]

{ #category : 'building' }
MicroUMLSequenceDiagram >> build [

	canvas := RSCanvas new.
	self drawActors.
	self drawLifelines.
	self drawMessages.
	canvas @ RSCanvasController.
	canvas open
]

{ #category : 'building' }
MicroUMLSequenceDiagram >> drawActors [
	canvas addAll: (actors collect: [ :actor | actor draw ])
]

{ #category : 'as yet unclassified' }
MicroUMLSequenceDiagram >> drawLifelines [
    canvas addAll: (actors collect: [ :actor |
        RSLine new
            startPoint: actor x @ (MicroUMLSDActor boxHeight / 2);
            endPoint: actor x @ (MicroUMLSDActor boxHeight / 2 + self lifelineHeight);
            dashArray: #(5 5);
            color: Color black;
            yourself ])
]

{ #category : 'as yet unclassified' }
MicroUMLSequenceDiagram >> drawMessages [
    messages do: [ :msg | canvas addAll: msg draw ]
]

{ #category : 'initialization' }
MicroUMLSequenceDiagram >> initialize [
	actors := OrderedCollection new.
	messages := OrderedCollection new.
	actorGap := MicroUMLSDActor actorGap.
]

{ #category : 'accessing' }
MicroUMLSequenceDiagram >> lifelineHeight [
    ^ MicroUMLSDMessages topMargin 
        + (messages size * MicroUMLSDMessages messageGap) 
        + MicroUMLSDMessages bottomMargin
]

{ #category : 'building' }
MicroUMLSequenceDiagram >> nextX [
	actors isEmpty ifTrue: [ ^ actorGap ].
	^ actors last x + (actors last width / 2 ) + actorGap 
]

{ #category : 'accessing' }
MicroUMLSequenceDiagram >> yForMessage: n [
    ^ MicroUMLSDMessages topMargin + (n * MicroUMLSDMessages messageGap)
]
