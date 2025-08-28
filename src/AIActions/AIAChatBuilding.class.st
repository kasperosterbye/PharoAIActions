"
# Class Comment for AIAChatBuilding

`AIAChatBuilding` is a class designed to facilitate the construction and management of chat history for AI conversations. It maintains an ordered collection of messages exchanged between users and AI assistants, supporting roles such as 'system', 'user', and 'assistant'.

## Key Features

- **History Tracking**: Maintains a chronological record of chat interactions.
- **Role-Based Messaging**: Supports different message roles (system, user, assistant).
- **JSON Conversion**: Converts chat history to JSON format for API requests.
- **AI Integration**: Works with AI APIs to generate and process responses.

## Usage Example

```st
""Create a new chat building instance""
chatBuilder := AIAChatBuilding new.

""Add system, user, and assistant messages""
chatBuilder system: 'You are a helpful assistant.';
chatBuilder user: 'Hello, how are you?';
chatBuilder assistant: 'I''m doing well, thank you! How can I assist you today?'.

""View the chat history""
chatBuilder history.

""Convert history to JSON format""
chatBuilder jsonHistory.
```

This example demonstrates how to create a chat history, add messages, and convert the history to JSON format, which is suitable for inspection in the Playground using `command-I`.
```
"
Class {
	#name : 'AIAChatBuilding',
	#superclass : 'AIACommentBuilding',
	#instVars : [
		'history'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'initialization' }
AIAChatBuilding >> assistant: aString [
	"Adds an assistant message to the chat history and returns the updated history. Used to simulate AI responses in the conversation."
	history add: 'assistant' -> aString
]

{ #category : 'accessing' }
AIAChatBuilding >> history [
	"Returns the ordered collection of chat history items, each containing a role and content. Used to track the conversation flow between user and assistant."
	^ history 
]

{ #category : 'initialization' }
AIAChatBuilding >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	history := OrderedCollection new.
]

{ #category : 'initialization' }
AIAChatBuilding >> jsonHistory [
	"Converts chat history to JSON format for API request. Adds system, user, and assistant messages to ordered collection. Returns formatted JSON array."
	| jsonHistory |
	jsonHistory := OrderedCollection new.
	history do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'content' -> item value.})
	].
	jsonHistory := jsonHistory asArray.
	aiaApi messagePart: jsonHistory.
	aiaApi getResponse.
	^ self response 
"	^jsonHistory "
]

{ #category : 'initialization' }
AIAChatBuilding >> system: aString [
	"Adds a system message to the chat history and returns the updated history. Used to set the context for the AI conversation."
	history add: 'system' -> aString
]

{ #category : 'initialization' }
AIAChatBuilding >> user: aString [
	"Adds a user message to the chat history and returns the updated history Used to simulate user input in the conversation"
	history add: 'user' -> aString
]
