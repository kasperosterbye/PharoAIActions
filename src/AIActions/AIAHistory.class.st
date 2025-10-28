"
## Class: AIAHistory

AIAHistory is a class designed to manage the history and context of interactions with an AI API. It maintains a collection of messages exchanged between the user and the assistant, along with initial and final roles that define the system's behaviour, such as system prompts, backgrounds, and response types. This class facilitates building conversational contexts for AI-driven applications, allowing users to append user messages and retrieve assistant responses.

### Key Features
- **Messages Management**: Stores an ordered collection of messages, where each message is a key-value pair (e.g., 'user' -> message or 'assistant' -> response).
- **Role Configuration**: Supports setting initial roles (e.g., system prompts and backgrounds) and final roles (e.g., response types) to customise AI interactions.
- **API Integration**: Holds a reference to an AI API provider (e.g., AilienApi) for potential future extensions.
- **Response Retrieval**: Provides methods to access the latest assistant response.

### Usage Example
In the Pharo Playground, you can create an instance of AIAHistory, configure roles, add a user message, and inspect the messages collection. Note that this example assumes the class is already defined in the system; it does not install or modify other objects.

```smalltalk
| history |
history := AIAHistory new.
history system: 'You are a helpful assistant.'.
history background: 'This is a conversation about Pharo programming.'.
history user: 'What is a class in Pharo?'.
history messages  ""Inspect this to see the messages collection""
```

This code initialises an AIAHistory instance, sets up roles, adds a user message, and ends with an expression (`history messages`) that can be inspected using command-I to view the current state of the messages.
"
Class {
	#name : 'AIAHistory',
	#superclass : 'Object',
	#instVars : [
		'api',
		'messages',
		'firstRoles',
		'lastRoles'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
AIAHistory >> api [
	"Returns the API provider instance or defaults to the AilienApi provider if the instance is nil"
	api ifNil: [ ^ AilienApi provider ].
	^ api
]

{ #category : 'accessing' }
AIAHistory >> api: anObject [

	api := anObject
]

{ #category : 'accessing' }
AIAHistory >> apiMessageList [
	"Returns an ordered list of all messages with first and last roles included"
	| messageList |
	messageList := OrderedCollection new.
	firstRoles keysAndValuesDo: [ :key :value | messageList add: key -> value ].
	messages do: [ :m | messageList add: m ].
	lastRoles  keysAndValuesDo: [ :key :value | messageList add: key -> value ].
	^ messageList
]

{ #category : 'context roles' }
AIAHistory >> background [
	^ firstRoles at: 'background'
]

{ #category : 'context roles' }
AIAHistory >> background: string [
	firstRoles at: 'background' put: string 
]

{ #category : 'initialization' }
AIAHistory >> initialize [
	super initialize.
	api := AilienApi provider.
	messages := OrderedCollection new.
	firstRoles := OrderedDictionary new.
	lastRoles := OrderedDictionary new.
]

{ #category : 'accessing' }
AIAHistory >> messages [
	^ messages 
]

{ #category : 'accessing' }
AIAHistory >> response [
	(messages last key = 'assistant')
		ifTrue: [ ^ messages last value ]
		ifFalse: [ ^ nil ]
]

{ #category : 'context roles' }
AIAHistory >> responseType [
	lastRoles at: 'responseType:'
]

{ #category : 'context roles' }
AIAHistory >> responseType: string [
	lastRoles at: 'responseType:' put: string 
]

{ #category : 'context roles' }
AIAHistory >> system [
	^ firstRoles at: 'system'
]

{ #category : 'context roles' }
AIAHistory >> system: string [
	firstRoles at: 'system' put: string 
]

{ #category : 'accessing' }
AIAHistory >> user: aString [
	messages add: 'user' -> aString
]
