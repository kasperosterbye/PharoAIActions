"
# Class Comment for AIAChatChat

`AIAChatChat` is a class designed to facilitate interactive chat-based interactions with large language models (LLMs). It manages conversation history and supports alternating between different LLM providers to generate responses.

## Key Features

- **Conversation Management**: Maintains a history of user prompts and LLM responses.
- **Multi-Model Support**: Alternates between different LLM providers (e.g., Mistral, Grok) for varied responses.
- **Contextual Prompting**: Generates follow-up questions based on previous responses to maintain coherent discussions.
- **Response Formatting**: Supports academic British style responses and custom response types.

## Usage Example

```st
""Create a new chat instance and start a conversation about Danish computer scientists""
chat := AIAChatChat new.
chat chat.

""Inspect the conversation history""
chat history
```

## Design Considerations

- **Fluid API**: Designed for interactive scripting in the Playground.
- **Provider Flexibility**: Easily switch between different LLM providers.
- **Context Awareness**: Maintains conversation context to generate relevant follow-up questions.

This class is particularly useful for educational purposes, research discussions, or any scenario requiring structured, multi-turn interactions with LLMs.
"
Class {
	#name : 'AIAChatChat',
	#superclass : 'Object',
	#instVars : [
		'history'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'initialization' }
AIAChatChat >> chat [

	| nextChat |
	self firstChat.
	1 to: 1 do: [ :i |
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

{ #category : 'initialization' }
AIAChatChat >> paperComment: all [

	| llmModels resp hist |
	llmModels := OrderedCollection new.
	resp := OrderedCollection new.
	1 to: 2 do: [ :id | llmModels add: (MistralApi defaultModel: id) new].
	1 to: 1 do: [ :id | llmModels add: (GrokApi defaultModel: id) new].
	llmModels do: [ :model |
		hist := AIAHistory new.
		hist api: model. 
		resp add: ( self paperComment: all by: hist )].
	^ resp
]

{ #category : 'as yet unclassified' }
AIAChatChat >> paperComment: all by: hist [ 
	hist background: '# Paper for discussion', String cr, String cr, (AIABibLaTex new paper: 20) .
	hist user: 'These there the comments procuded of the paper. ' , String cr, String cr. all.
	hist user: 'Based on those summaries, can you write a comment that is the essence of them all. It should not be lo'.
	hist responseType: 'The response type should be academic british style. '.
	hist getResponse.
	^ hist response
]

{ #category : 'initialization' }
AIAChatChat >> paperFirst: hist [
	hist background: '# Paper for discussion', String cr, String cr, (AIABibLaTex new paper: 20) .
	hist user: 'Can you give a summary of the paper in background. Summary of concrete experiments in the paper is the key.'.
	hist responseType: 'The response type should be academic british style. '.
	hist getResponse.
	^ hist response
]

{ #category : 'initialization' }
AIAChatChat >> paperRead [

	| all  comments |
	all := self paperReadCombine.
	comments := self paperComment: all.
	^ all
	
]

{ #category : 'initialization' }
AIAChatChat >> paperReadAll [

	| llmModels resp hist |
	llmModels := OrderedCollection new.
	resp := OrderedCollection new.
	1 to: 2 do: [ :id | llmModels add: (MistralApi defaultModel: id) new].
	1 to: 1 do: [ :id | llmModels add: (GrokApi defaultModel: id) new].
	llmModels do: [ :model |
		hist := AIAHistory new.
		hist api: model. 
		resp add: ( self paperFirst: hist )].
	^ resp
]

{ #category : 'initialization' }
AIAChatChat >> paperReadCombine [

	| all  |
	all := self paperReadAll.
	^ '-------------------', String cr, String cr join: all.
]

{ #category : 'initialization' }
AIAChatChat >> sestoft_firstChat [
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
