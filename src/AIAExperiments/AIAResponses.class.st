Class {
	#name : 'AIAResponses',
	#superclass : 'Object',
	#instVars : [
		'title',
		'sharedPrompt',
		'responces'
	],
	#classVars : [
		'responceDictionary'
	],
	#category : 'AIAExperiments',
	#package : 'AIAExperiments'
}

{ #category : 'initialization' }
AIAResponses class >> getLastHistoryPrompt [
	| lastHistoryPrompt |
	lastHistoryPrompt := WriteStream on: ''.
	AilienApi lastHistory allButLast do: [ :item |
		lastHistoryPrompt 
			<< '## role: ' << item key << String cr
			<< '``````content' << String cr 
			<< item value << String cr
			<< '``````' << String cr << String cr
	].
	^ lastHistoryPrompt contents
]

{ #category : 'instance creation' }
AIAResponses class >> newTitled: aTitle [
	^ self new title: aTitle
]

{ #category : 'instance creation' }
AIAResponses class >> titles [
	^ responceDictionary
]

{ #category : 'initialization' }
AIAResponses >> getLastHistoryPrompt [
	^ self class getLastHistoryPrompt
]

{ #category : 'initialization' }
AIAResponses >> initialize [ 
	super initialize.
	title := 'error'. 
	responces := OrderedDictionary new.
]

{ #category : 'as yet unclassified' }
AIAResponses >> markDownResult [
	| md |
	md := WriteStream on: ''.
	md << '## Result ' << String cr .
	md << '### ORIGINAL PROMPT HISTORY WAS: ' << String cr <<
		(self getLastHistoryPrompt 
					copyReplaceAll: String cr with: (String cr , '> ');
					copyReplaceAll: String lf with: (String cr , '> ') )  
	 << String cr << String cr.
	md << '### RESPONSES TABLE START' << String cr << String cr.
	md << '| Provider | Model | Response |' << String cr.
	md << '| -------- | ----- | -------- |' << String cr.
		self providers do: [ :provider |
		1 to: 4 do: [ :modelId | | responce |
			"self provider: provider model: modelId response: promptBlock"
			responce := ( responces at: provider at: modelId )
					copyReplaceAll: String cr with: '<br>';
					copyReplaceAll: String lf with: '<br>'.
			md << '| ' << provider asString 
				<< ' | ' << (provider modelNames at: modelId) 
				<< ' | ' << responce
				<< ' | ' << String cr.
			 ]
		 ].
	md << String cr.
	md << 'This was the responses' << String cr.
	^ md contents 
]

{ #category : 'as yet unclassified' }
AIAResponses >> prompt: promptBlock [
	sharedPrompt := promptBlock.
	self providers do: [ :provider |
		1 to: 4 do: [ :modelId |
			self provider: provider model: modelId response: sharedPrompt
			 ]
		 ]
	
]

{ #category : 'as yet unclassified' }
AIAResponses >> provider: p model: m response: r [
	AilienApi provider: p.
	p defaultModel: m.
	responces at: p at: m put: r value
]

{ #category : 'provider' }
AIAResponses >> providers [
	"AilienApi providers  "
	^ {ClaudeApi. GeminiApi. GrokApi. MistralApi}.
]

{ #category : 'as yet unclassified' }
AIAResponses >> responses [
	^ responces 
]

{ #category : 'initialization' }
AIAResponses >> setLastHistoryPrompt [
	| lastHistoryPrompt |
	lastHistoryPrompt := WriteStream on: ''.
	AilienApi lastHistory do: [ :item |
		lastHistoryPrompt 
			<< '## role: ' << item key << String cr
			<< '``````content' << String cr 
			<< item value << String cr
			<< '``````' << String cr << String cr
	].
]

{ #category : 'instance creation' }
AIAResponses >> title: n [
	title := n.
	responceDictionary ifNil: [ responceDictionary := OrderedDictionary new ].
	responceDictionary at: title put: self.
	
]

{ #category : 'instance creation' }
AIAResponses >> titles [
	^ self class titles
	
]
