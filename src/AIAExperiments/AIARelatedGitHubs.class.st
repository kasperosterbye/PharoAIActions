Class {
	#name : 'AIARelatedGitHubs',
	#superclass : 'Object',
	#classInstVars : [
		'default'
	],
	#category : 'AIAExperiments-ExperimentsTools',
	#package : 'AIAExperiments',
	#tag : 'ExperimentsTools'
}

{ #category : 'examples' }
AIARelatedGitHubs class >> clearDefault [
	<example>
	default := nil
]

{ #category : 'examples' }
AIARelatedGitHubs class >> default [
	default ifNil: [ default := self new ].
	^ default
]

{ #category : 'as yet unclassified' }
AIARelatedGitHubs >> exp01 [
	| prompt items htmls|
	prompt := 'LLM+OR+AI'.
	items := STONJSON fromString: (ZnClient new get: 'https://api.github.com/search/repositories?q=', prompt, '+language:smalltalk').
	items := items at: 'items'. 
	htmls := WriteStream on: ''.
	items do: [ :item |
		| name url branch readme |
		name := item at: 'full_name' ifAbsent: [ nil ].
		url := item at: 'html_url'.
		branch := item at: 'default_branch'.
		readme := ZnClient new get: 'https://raw.githubusercontent.com/', 
											name, '/' , branch, '/README.md'.
		"htmls add: { url. readme }."
		self halt.
		htmls << '# ' << name << String lf
			<< '<!-- ' << url << ' -->' << String lf << String lf
			<< readme << String lf << String lf
		 ].
	^ htmls contents
]
