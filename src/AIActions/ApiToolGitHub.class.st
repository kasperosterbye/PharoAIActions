Class {
	#name : 'ApiToolGitHub',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
ApiToolGitHub >> evaluateTool [
	| desc desc1 |
	desc := 'Searching for Pharo/Smalltalk projects on GitHub based on keywords.'.
	desc1 := 'Search terms (e.g. "LLM", "Graphics")'.

    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'initialization' }
ApiToolGitHub >> executeTool: args [

	| aQuery response url |
	super executeTool: args.
	aQuery := args at: required.
	url := 'https://api.github.com/search/repositories?q=' , aQuery urlEncoded , '+language:smalltalk'.

	response := ZnClient new get: url.

	^ String streamContents: [ :s |
			  | items |
			  items := (STONJSON fromString: response) at: 'items' ifAbsent: [ #(  ) ].
			  items isEmpty ifTrue: [ s << 'No results found' ].
			  (items first: (5 min: items size)) do: [ :repo |
				  s << '- ' << (repo at: 'full_name') << ': ' << (repo at: 'description') << String cr ] ]
]

{ #category : 'initialization' }
ApiToolGitHub >> initialize [
	name := 'searchGitHubSmalltalk'.
	required := 'query'
]
