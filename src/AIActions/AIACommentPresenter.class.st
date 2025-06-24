Class {
	#name : 'AIACommentPresenter',
	#superclass : 'SpTextPresenter',
	#instVars : [
		'commentName'
	],
	#classInstVars : [
		'commentPresenter'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'instance creation' }
AIACommentPresenter class >> onText: aText [
	commentPresenter ifNotNil: [ commentPresenter delete].
	commentPresenter := self basicNew.
	commentPresenter
		commentName: ((aText lines first takeFirst: 20), '...');
		initialize;
		text: aText ;
		open 
]

{ #category : 'accessing' }
AIACommentPresenter >> commentName [

	^ commentName
]

{ #category : 'accessing' }
AIACommentPresenter >> commentName: anObject [

	commentName := anObject
]

{ #category : 'accessing' }
AIACommentPresenter >> windowTitle [

	^ 'Comment for ', self commentName  
]
