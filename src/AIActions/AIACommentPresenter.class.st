Class {
	#name : 'AIACommentPresenter',
	#superclass : 'MicrodownPresenter',
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
AIACommentPresenter class >> onText: aString [
	commentPresenter ifNotNil: [ commentPresenter delete].
	commentPresenter := self basicNew.
	commentPresenter
		commentName: ((aString lines first takeFirst: 20), '...');
		initialize;
		text: (Microdown asRichText: (aString copyReplaceAll: '```markdown' with: '') );
		"text: aString;"
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
