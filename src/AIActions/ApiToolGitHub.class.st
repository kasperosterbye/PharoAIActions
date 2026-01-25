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
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> name.
            'description' -> desc.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'expression' -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> desc1
                    })
                }).
                'required' -> {required} 
            })
        })
    }
]

{ #category : 'initialization' }
ApiToolGitHub >> executeTool: args [
	| aQuery response url |
	aQuery := args at: required.
    url := 'https://api.github.com/search/repositories?q=', 
           args urlEncoded, 
           '+language:smalltalk'.
    
    response := ZnClient new
        get: url.
    
    ^ String streamContents: [ :s | | items |
        items := (STONJSON fromString: response) at: 'items' ifAbsent: [ #() ].
        items isEmpty ifTrue: [ s << 'Ingen resultater fundet.' ].
        (items first: (5 min: items size)) do: [ :repo |
            s << '- ' << (repo at: 'full_name') << ': ' << (repo at: 'description') << String cr ] ]

]

{ #category : 'initialization' }
ApiToolGitHub >> initialize [
	name := 'searchGitHubSmalltalk'.
	required := 'query'
]
