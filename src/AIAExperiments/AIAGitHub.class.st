Class {
	#name : 'AIAGitHub',
	#superclass : 'Object',
	#instVars : [
		'openIssues',
		'repository'
	],
	#classInstVars : [
		'default',
		'pillar'
	],
	#category : 'AIAExperiments-MicrodownExperiments',
	#package : 'AIAExperiments',
	#tag : 'MicrodownExperiments'
}

{ #category : 'examples' }
AIAGitHub class >> clearDefault [
	<example>
	default := nil
]

{ #category : 'examples' }
AIAGitHub class >> clearPillar [
	<example>
	pillar := nil
]

{ #category : 'examples' }
AIAGitHub class >> default [
	default ifNil: [ default := self new ].
	^ default
]

{ #category : 'examples' }
AIAGitHub class >> gitHubToken [
	"From https://github.com/settings/tokens"
	^(FileSystem disk workingDirectory / '../../gitHubToken.txt') readStream contents trimBoth.
]

{ #category : 'examples' }
AIAGitHub class >> pillar [
	pillar ifNil: [ 
		pillar := self new.
		pillar repository: 'pillar-markup/pillar' ].
	^ pillar
]

{ #category : 'as yet unclassified' }
AIAGitHub >> commentsFrom: comments [
	"This method processes a collection of GitHub comments, extracting key information such as the user, creation date, and body text. It returns a formatted list of these comments."

	| commentsList |
	commentsList := OrderedCollection new.
	commentsList addAll: (comments collect: [ :comment |
				 {
					 ('user' -> ((comment at: 'user') at: 'login')).
					 ('created_at' -> (comment at: 'created_at')).
					 ('body' -> (comment at: 'body' ifAbsent: [ '(no text)' ])) } asDictionary ]).
	^ commentsList
]

{ #category : 'as yet unclassified' }
AIAGitHub >> fetchOpenIssues [
	"Fetches open issues from the GitHub repository, paginating through results and storing them in the openIssues collection."

	| url page issues30 |
	openIssues := OrderedCollection new.
	page := 1.
	[
		url := 'https://api.github.com/repos/{1}/issues?state=open&per_page=30&page={2}' format: {
				       repository.
				       page }.
		[
			issues30 := STONJSON fromString: (ZnClient new
					             beOneShot;
									 headerAt: 'Authorization' put: self class gitHubToken;
					             get: url) ]
			on: Error
			do: [ ^ openIssues ].
		openIssues addAll: (issues30 collect: [ :issue | self issueInfo: issue ]).
		issues30 size = 30 ] whileTrue: [ page := page + 1 ].
	openIssues do: [ :issue | self fetchOpenIssuesComments: (issue at: 'number') ].
	^ openIssues
]

{ #category : 'as yet unclassified' }
AIAGitHub >> fetchOpenIssuesComments: issueNumber [
	"Fetches and processes comments for a specific GitHub issue, storing them in the issue's dictionary."

	| url comments discussion issue |
	issue := openIssues detect: [ :f | (f at: 'number') = issueNumber ].
	issue add: 'commentList' -> #(  ).
	url := 'https://api.github.com/repos/{1}/issues/{2}/comments' format: {
			       repository.
			       issueNumber asString }.
	[
		(issue at: 'comments') > 0 ifTrue: [
				comments := STONJSON fromString: (ZnClient new
						             beOneShot;
						             headerAt: 'Authorization' put: self class gitHubToken;
						             get: url).
				discussion := self commentsFrom: comments.
				issue add: 'commentList' -> discussion ] ]
		on: Error
		do: [ ^ self ].
	^ self
]

{ #category : 'as yet unclassified' }
AIAGitHub >> initialize [ 
	"Initialises the GitHub repository and open issues collection"
	super initialize.
	openIssues := OrderedCollection new.
	repository := 'pillar-markup/Microdown'.
]

{ #category : 'as yet unclassified' }
AIAGitHub >> issue: issue at: name [
	"Returns a dictionary entry for the specified issue attribute, handling the 'user' case separately to extract the login name."
	name = 'user' ifTrue: [ ^ 'user' -> ((issue at: 'user') at: 'login') ].
	^ name -> (issue at: name)
]

{ #category : 'as yet unclassified' }
AIAGitHub >> issueInfo: issue [
	"Returns a dictionary containing key information about a GitHub issue, including number, user, title, update date, comment count, and body text."

	^ {
		  (self issue: issue at: 'number').
		  (self issue: issue at: 'user').
		  (self issue: issue at: 'title').
		  (self issue: issue at: 'updated_at').
		  (self issue: issue at: 'comments').
		  (self issue: issue at: 'body') } asDictionary
]

{ #category : 'as yet unclassified' }
AIAGitHub >> llmOpenIssue: issueNumber [
	| issue |
	issue := openIssues detect: [ :f | (f at: 'number') = issueNumber ].
	^ issue
]

{ #category : 'as yet unclassified' }
AIAGitHub >> llmOpenIssues [
	"Returns the open issues as a string representation"
	^ openIssues asString
]

{ #category : 'as yet unclassified' }
AIAGitHub >> repository [
	"Returns the GitHub repository name"

	^ repository
]

{ #category : 'as yet unclassified' }
AIAGitHub >> repository: anObject [
	"Sets the GitHub repository name for the instance"

	repository := anObject
]
