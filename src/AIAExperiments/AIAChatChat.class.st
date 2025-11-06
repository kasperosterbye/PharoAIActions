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
	1 to: 25 do: [ :i |
			nextChat := history response.
			history user: 'You said ', nextChat, '. What do you think? Is what I said wrong, did what I say similar to an other country, or something else'.
			i odd
				ifTrue: [ AilienApi provider: GrokApi ]
				ifFalse: [ AilienApi provider: MistralApi ].
			history getResponse ].
	^ history
]

{ #category : 'initialization' }
AIAChatChat >> extractPromptFromResponse [
	^ history response lines last
]

{ #category : 'initialization' }
AIAChatChat >> firstChat [
	history background: 'history background: ''We alternate explaining Danish PhD computer scientists.
I name a person and ask: "Can you explain [name]?"
You explain their research area and contributions.
Then pick someone who has cited their work or collaborated with them, and ask me: "Can you explain [new name]?"
If uncertain about a person, say "I do not know [name]" and ask about someone from a related area instead.
Stay focused on Danish CS researchers.

Example:
USER: Can you explain Peter Sestoft?
ASSISTANT: [explanation of Sestoft''''s work in functional programming and ITU]. Can you explain Fritz Henglein?'''.
	history user: 'Can you explain Peter Sestoft?'.
	history getResponse.
]

{ #category : 'initialization' }
AIAChatChat >> initialize [

	history := AIAHistory new.

	AilienApi provider: MistralApi
]

{ #category : 'initialization' }
AIAChatChat >> old2_firstChat [
	history background: 'We are trying to understand PhD persons who got their degree from Denmark. I pick a person, and you explain the background of that person. If you know the person, explain its scientific are area. If you do not know that person, say "I do not know that person, please ask about somebody else from the same area". Example: USER: Can you explain about Peter Sestoft? ASSISTANT: [explanation]. Can you explain one one the persons who cite the papers of Peter Sestoft'.
	history user: 'Can you explain Peter Sestoft?'.
	history getResponse.
]

{ #category : 'initialization' }
AIAChatChat >> old_chat [

	| nextChat |
	self firstChat.
	1 to: 10 do: [ :i |
			nextChat := self extractPromptFromResponse.
			history user: nextChat.
			i odd
				ifTrue: [ AilienApi provider: GrokApi ]
				ifFalse: [ AilienApi provider: MistralApi ].
			history getResponse ].
	^ history
]

{ #category : 'initialization' }
AIAChatChat >> old_firstChat [
	history background: 'We alternate explaining European governments.
I pick a country and ask: "Can you explain the government of XXX?"
You answer, then pick a different European country and ask me the same format: "Can you explain the government of YYY?"
If uncertain about a country, say "I do not know about [country]" and pick different country.
Example: USER: Can you explain the government of France? ASSISTANT: [explanation]. Can you explain the government of Finland?'.
	history user: 'Can you explain the government of Italy?'.
	history getResponse.
]
