Class {
	#name : 'AIAHistoryPresenterTestApi',
	#superclass : 'Object',
	#instVars : [
		'messageList'
	],
	#category : 'AIActions-Tests-UIPresenters-Tests',
	#package : 'AIActions-Tests',
	#tag : 'UIPresenters-Tests'
}

{ #category : 'accessing' }
AIAHistoryPresenterTestApi >> loadResponse: aHistory [
	aHistory assistant: 'Deterministic test response'
]

{ #category : 'accessing' }
AIAHistoryPresenterTestApi >> messageList: aCollection [
	messageList := aCollection

]

{ #category : 'accessing' }
AIAHistoryPresenterTestApi >> model [
	^ 'test-model'

]

{ #category : 'accessing' }
AIAHistoryPresenterTestApi >> responseWaitingInSecs [
	^ 1

]
