Class {
	#name : 'AIAResponses',
	#superclass : 'Object',
	#instVars : [
		'name',
		'responces'
	],
	#classVars : [
		'responceDictionary'
	],
	#category : 'AIAExperiments',
	#package : 'AIAExperiments'
}

{ #category : 'instance creation' }
AIAResponses class >> named: name [
	^ self new named: name
]

{ #category : 'initialization' }
AIAResponses >> initialize [ 
	super initialize.
	name := 'error'. 
	responces := OrderedDictionary new.
]

{ #category : 'instance creation' }
AIAResponses >> named: n [
	name := n
]

{ #category : 'as yet unclassified' }
AIAResponses >> prompt: promptBlock [
	self providers do: [ :provider |
		1 to: 4 do: [ :modelId |
			self provider: provider model: modelId response: promptBlock
			 ]
		 ]
	
]

{ #category : 'as yet unclassified' }
AIAResponses >> provider: p model: m [ 
	^ responces at: p at: m 
]

{ #category : 'as yet unclassified' }
AIAResponses >> provider: p model: m response: r [
	responces at: p at: m put: (r value)
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
