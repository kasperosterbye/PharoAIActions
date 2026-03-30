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

{ #category : 'logical operations' }
MicroUMLSDAstBuilder >> & from [
    messageFrom := from .
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
			 fromActor: messageFrom;
			 toActor: messageTo;
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
   messages add: (MicroUMLSDMessages new
			 description: aString;
			 fromActor: messageFrom;
			 toActor: messageTo;
			 messageType: #call;
			 yourself).
    ^ self

]

{ #category : 'initialization' }
MicroUMLSDAstBuilder >> initialize [ 
	actors := OrderedDictionary new.
	messages := OrderedCollection new
]
