Class {
	#name : 'ApiToolGitHub',
	#superclass : 'AilienApiTool',
	#category : 'AIAZipArchive-AIApiTools',
	#package : 'AIAZipArchive',
	#tag : 'AIApiTools'
}

{ #category : 'initialization' }
ApiToolGitHub >> evaluateTool [
	| desc desc1 |
	desc := 'Search GitHub for Pharo/Smalltalk repositories. Use this when the user asks about a specific GitHub repository or project by name.'.
	desc1 := 'Search terms (e.g. "LLM", "Graphics")'.

    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'initialization' }
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
	"Transcript << '>>> ' << response asString << String lf."
	^ responseText 
]

{ #category : 'initialization' }
ApiToolGitHub >> initialize [
	name := 'searchGitHubSmalltalk'.
	required := 'query'
]
