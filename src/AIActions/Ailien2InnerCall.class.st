Class {
	#name : 'Ailien2InnerCall',
	#superclass : 'Object',
	#instVars : [
		'outer',
		'llmReply',
		'toolCall'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'instance creation' }
Ailien2InnerCall class >> on: outer [
	| instance |
	instance := self new.
	instance outer: outer.
	^ instance
]

{ #category : 'accessing' }
Ailien2InnerCall >> outer [
	^ outer
]

{ #category : 'accessing' }
Ailien2InnerCall >> outer: o [
	outer := o
]
