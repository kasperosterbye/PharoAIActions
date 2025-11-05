Class {
	#name : 'AIAChatChat',
	#superclass : 'Object',
	#instVars : [
		'history'
	],
	#category : 'AIAExperiments',
	#package : 'AIAExperiments'
}

{ #category : 'initialization' }
AIAChatChat >> chat [

	| nextChat |
	self firstChat.
	1 to: 10 do: [ :i |
			nextChat := self extractPromptFromResponse.
			history user: nextChat.
			i odd
				ifTrue: [ AilienApi provider: GrokApi ]
				ifFalse: [ AilienApi provider: MistralApi ] history getResponse ].
	^ history
]

{ #category : 'initialization' }
AIAChatChat >> extractPromptFromResponse [
	^ history response lines last
]

{ #category : 'initialization' }
AIAChatChat >> firstChat [
	history background: 'We alternate explaining European governments.
I pick a country and ask: "Can you explain the government of XXX?"
You answer, then pick a different European country and ask me the same format: "Can you explain the government of YYY?"
If uncertain about a country, say "I do not know about [country]" and pick different country.
Example: USER: Can you explain the government of France? ASSISTANT: [explanation]. Can you explain the government of Finland?'.
	history user: 'Can you explain the government of Italy?'.
	history getResponse.
]

{ #category : 'initialization' }
AIAChatChat >> initialize [
	history := AIAHistory new.
]
