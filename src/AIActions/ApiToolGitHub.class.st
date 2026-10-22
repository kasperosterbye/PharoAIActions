"
I am an API tool that searches GitHub for Pharo/Smalltalk repositories.

Given a search query, I return a short summary of the top matching repositories (full name and description). Use me when a user asks about a specific GitHub repository or project by name.
"
Class {
	#name : 'ApiToolGitHub',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApiTool',
	#package : 'AIActions',
	#tag : 'AIApiTool'
}

{ #category : 'evaluating' }
ApiToolGitHub >> evaluateTool [
	| desc desc1 |
	desc := 'Search GitHub for Pharo/Smalltalk repositories. Use this when the user asks about a specific GitHub repository or project by name.'.
	desc1 := 'Search terms (e.g. "LLM", "Graphics")'.

    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'evaluating' }
ApiToolGitHub >> executeTool: args [

	| aQuery response url responseText |
	super executeTool: args.
	aQuery := args at: required.
	url := 'https://api.github.com/search/repositories?q=' , aQuery urlEncoded , '+language:smalltalk'.

	response := ZnClient new 
					headerAt: 'Authorization' put: AIAGitHub gitHubToken;
					get: url.

	responseText := String streamContents: [ :s |
			  | items |
			  items := (STONJSON fromString: response) at: 'items' ifAbsent: [ #(  ) ].
			  items isEmpty ifTrue: [ s << 'No results found' ].
			  (items first: (5 min: items size)) do: [ :repo |
					| desc |
					desc := (repo at: 'description') ifNil: [ '' ].
				  s << '- ' << (repo at: 'full_name') << ': ' << desc << String cr ] ].
	^ responseText 
]

{ #category : 'initialization' }
ApiToolGitHub >> initialize [
	name := 'searchGitHubSmalltalk'.
	required := 'query'
]
