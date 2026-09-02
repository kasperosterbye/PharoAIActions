Class {
	#name : 'AIAHistoryPresenterTreeNode',
	#superclass : 'Object',
	#instVars : [
		'history',
		'isReference'
	],
	#category : 'AIActions-UIPresenters',
	#package : 'AIActions',
	#tag : 'UIPresenters'
}

{ #category : 'accessing' }
AIAHistoryPresenterTreeNode class >> referenceFor: aHistory [
	^ self new
		history: aHistory;
		isReference: true;
		yourself
]

{ #category : 'accessing' }
AIAHistoryPresenterTreeNode class >> rootFor: aHistory [
	^ self new
		history: aHistory;
		isReference: false;
		yourself
]

{ #category : 'accessing' }
AIAHistoryPresenterTreeNode >> children [
	^ history preHistories collect: [ :each |
		self class referenceFor: each ]
]

{ #category : 'accessing' }
AIAHistoryPresenterTreeNode >> history [

	^ history
]

{ #category : 'accessing' }
AIAHistoryPresenterTreeNode >> history: anObject [

	history := anObject
]

{ #category : 'accessing' }
AIAHistoryPresenterTreeNode >> isReference [

	^ isReference
]

{ #category : 'accessing' }
AIAHistoryPresenterTreeNode >> isReference: anObject [

	isReference := anObject
]
