Class {
	#name : 'AIIssueHelp',
	#superclass : 'Object',
	#instVars : [
		'issueNumber',
		'issueDiscussion'
	],
	#category : 'AIAExperiments-ExperimentsTools',
	#package : 'AIAExperiments',
	#tag : 'ExperimentsTools'
}

{ #category : 'as yet unclassified' }
AIIssueHelp >> fetchIssueDiscussion [
	| url discussion original|
	discussion := WriteStream on: ''.
	url := 'https://api.github.com/repos/pharo-project/pharo/issues/',issueNumber asString.
	original := STONJSON fromString: (ZnClient new url: url;get).
	discussion << '# ' << (original at: 'title') << String cr.
	discussion << '## Issue ' << issueNumber asString 
				  << ' (' << ((original at: 'created_at') first: 10) 
				  << ') by ' << ((original at: 'user') at: 'login')
				  << String cr.
	discussion << (original  at: 'body') << String cr << String cr.
	(STONJSON fromString: (ZnClient new url: url, '/comments';get)) 
		do: [:comment |
			(((comment at: 'user') at: 'type') = 'Bot') ifFalse: [  
				discussion << '### Comment ' 
					<< '(' << ((comment at: 'created_at') first: 10)
					<< ') by ' << ((comment at: 'user') at: 'login') << String cr.
				discussion << (comment  at: 'body') << String cr << String cr]
	].
	^ discussion contents
	
]

{ #category : 'accessing' }
AIIssueHelp >> issueDiscussion [

	^ issueDiscussion
]

{ #category : 'accessing' }
AIIssueHelp >> issueDiscussion: anObject [

	issueDiscussion := anObject
]

{ #category : 'accessing' }
AIIssueHelp >> issueNumber [

	^ issueNumber
]

{ #category : 'accessing' }
AIIssueHelp >> issueNumber: anObject [

	issueNumber := anObject
]
