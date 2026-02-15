"
# Class Comment for AIAGitHub

The `AIAGitHub` class provides an interface to interact with GitHub repositories, specifically for fetching and processing issues and comments. It supports pagination for large result sets and includes methods for extracting key information from GitHub API responses.

## Key Features

- **Issue Management**: Fetch open issues from a specified repository, including pagination support.
- **Comment Processing**: Retrieve and format comments associated with specific issues.
- **Repository Configuration**: Set and retrieve the target GitHub repository.

## Usage Example

```st
""Create an instance and fetch open issues from the Microdown repository""
github := AIAGitHub new.
github repository: 'pillar-markup/Microdown'.
github fetchOpenIssues.

""Inspect the first issue's details""
github llmOpenIssue: (github openIssues first at: 'number').
```

This class is designed for interactive use in the Pharo Playground, with methods returning collections or objects suitable for inspection.
"
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

{ #category : 'token' }
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

{ #category : 'fetching' }
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

{ #category : 'fetching' }
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

{ #category : 'fetching' }
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

{ #category : 'intialization' }
AIAGitHub >> initialize [ 
	"Initialises the GitHub repository and open issues collection"
	super initialize.
	openIssues := OrderedCollection new.
	repository := 'pillar-markup/Microdown'.
]

{ #category : 'fetching' }
AIAGitHub >> issue: issue at: name [
	"Returns a dictionary entry for the specified issue attribute, handling the 'user' case separately to extract the login name."
	name = 'user' ifTrue: [ ^ 'user' -> ((issue at: 'user') at: 'login') ].
	^ name -> (issue at: name)
]

{ #category : 'fetching' }
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

{ #category : 'llm support' }
AIAGitHub >> llmCommentsFor: issue in: issueMD [
	(issue at: 'comments') asString = 0 ifTrue: [ ^ self ].
	(issue at: 'commentList') do: [ :comment | | time |
		time := ((comment at: 'created_at') copyReplaceFrom: 11 to: 11 with: ' ') allButLast .
		issueMD 
			<< String lf
			<< '### ' << (comment at: 'user') << ' (' << time << ')' << String lf << String lf
			<< (comment at: 'body') << String lf
		 ]
]

{ #category : 'llm support' }
AIAGitHub >> llmOpenIssue: issueNumber [
	"Returns the open issue with the specified number from the collection of open issues."
	| issue issueMD time|
	issue := openIssues detect: [ :f | (f at: 'number') = issueNumber ].
	time := ((issue at: 'updated_at') copyReplaceFrom: 11 to: 11 with: ' ') allButLast .
	issueMD := WriteStream on: ''.
	issueMD 
		<< '# Issue #' << (issue at: 'number') asString << ': ' << (issue at: 'title') << String lf
		<< '- Author: ' << (issue at: 'user') << String lf 
		<< '- Updated: ' << time << String lf 
		<< '- Comments: ' << (issue at: 'comments') asString << String lf << String lf
		"Maybe a test should be made if there are none"
		<< (issue at: 'body') << String lf.
	self llmCommentsFor: issue in: issueMD .
	^ issueMD contents
]

{ #category : 'llm support' }
AIAGitHub >> llmOpenIssues [
	"Returns the open issue with the specified number from the collection of open issues."
	| issueMD |
	issueMD := WriteStream on: ''.
	openIssues do: [:issue | 
		issueMD << (self llmOpenIssue: (issue at: 'number')) << String lf << String lf
		].
	^ issueMD contents
]

{ #category : 'accessing' }
AIAGitHub >> repository [
	"Returns the GitHub repository name"

	^ repository
]

{ #category : 'accessing' }
AIAGitHub >> repository: anObject [
	"Sets the GitHub repository name for the instance"

	repository := anObject
]
