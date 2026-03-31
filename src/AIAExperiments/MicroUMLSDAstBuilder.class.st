Class {
	#name : 'MicroUMLSDAstBuilder',
	#superclass : 'Object',
	#instVars : [
		'actors',
		'messages',
		'messageFrom',
		'messageTo'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder class >> , aString [
    ^ self new , aString
]

{ #category : 'examples' }
MicroUMLSDAstBuilder class >> example [
	"MicroUMLSDAstBuilder
    , 'Playground'
    , 'Login System'
    , 'Database'
    & 'Playground' -> 'Login System' => 'call'
    & 'Login System' -> 'Database' => 'verify'
    & 'Database' -> 'Playground' --> ''"
]

{ #category : 'logical operations' }
MicroUMLSDAstBuilder >> & from [
    messageFrom := from.
    messageTo := nil.
    ^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> , aString [
	 messages ifNotEmpty: [ ^ self error: 'No new usage of `,` after an `&`' ].
	 (actors includesKey: aString) ifTrue: [ ^ self ].
    actors 
        add: aString -> (MicroUMLSDActor new name: aString; index: actors size + 1 ).
   
    ^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> --> aString [
	messages add: (MicroUMLSDMessages new
			 description: aString;
			 fromActor: (actors at: messageFrom);
			 toActor: (actors at: messageTo );
			 messageType: #return;
			 yourself).
	^ self
]

{ #category : 'logical operations' }
MicroUMLSDAstBuilder >> -> to [
    messageTo := to .
    ^ self
]

{ #category : 'UML - class separators' }
MicroUMLSDAstBuilder >> => aString [
	| messageType |
	messageType := #call.
	messageTo ifNil: [ messageType := #internal. messageTo := messageFrom ].
   messages add: (MicroUMLSDMessages new
			 description: aString;
			 fromActor: (actors at: messageFrom);
			 toActor: (actors at: messageTo );
			 messageType: messageType;
			 yourself).
    ^ self

]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> actors [
	^ actors values
]

{ #category : 'initialization' }
MicroUMLSDAstBuilder >> initialize [ 
	actors := OrderedDictionary new.
	messages := OrderedCollection new
]

{ #category : 'accessing' }
MicroUMLSDAstBuilder >> messages [
	^ messages 
]
