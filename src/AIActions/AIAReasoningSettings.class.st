"
Stores the selected reasoning level for each AI model.
"
Class {
	#name : 'AIAReasoningSettings',
	#superclass : 'Object',
	#classInstVars : [
		'selections'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'settings' }
AIAReasoningSettings class >> level: aLevel forModel: aModelName [
    "Set or remove the selected reasoning level."

    aLevel ifNil: [
        self selections removeKey: aModelName ifAbsent: [].
        ^ self
    ].

    self selections at: aModelName put: aLevel asString
]

{ #category : 'settings' }
AIAReasoningSettings class >> levelForModel: aModelName [
    "Answer the selected reasoning level, or nil."

    ^ self selections
        at: aModelName
        ifAbsent: [ nil ]
]

{ #category : 'initialization' }
AIAReasoningSettings class >> reset [
    "Remove all selected reasoning levels."

    selections := Dictionary new
]

{ #category : 'accessing' }
AIAReasoningSettings class >> selections [
    "Answer the dictionary of selected reasoning levels."

    ^ selections ifNil: [ selections := Dictionary new ]
]
