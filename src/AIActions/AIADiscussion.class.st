"
# AIADiscussion Class Comment

The `AIADiscussion` class represents a conversational interface for interacting with an AI assistant, maintaining a structured history of the discussion. It serves as a bridge between user inputs, AI responses, and the underlying API, enabling seamless multi-turn conversations.

## Core Responsibilities
- **Conversation Management**: Tracks the sequence of user messages and AI responses in an ordered history.
- **API Integration**: Facilitates communication with the AI provider (e.g., MistralApi) by passing conversation context and retrieving responses.
- **Context Preservation**: Maintains the state of the discussion to ensure coherent, context-aware interactions.
- **Response Handling**: Processes and presents AI responses to the user, typically via a presenter (e.g., `AIACommentPresenter`).

## Key Features
- **History Tracking**: Stores each interaction as a structured record (role + content) for reference and continuity.
- **Dynamic Updates**: Automatically updates the conversation history after each user-AI exchange.
- **Session Management**: Supports multiple discussion instances, with a ""current"" session and historical records.

## Usage Scenarios
- **Interactive AI Assistants**: Enables real-time, back-and-forth discussions with AI models.
- **Contextual Q&A**: Maintains context across multiple queries to improve response relevance.
- **Debugging/Inspection**: Provides tools to inspect conversation history for troubleshooting.

## Class Variables
- **Current**: The active discussion instance.
- **Histories**: A collection of all past discussions for reference or analysis.

## Methods
- **Accessing**: Retrieve the conversation history or current state.
- **Adding**: Append user messages and AI responses to the history.
- **Initialization**: Set up a new discussion with a fresh history and API connection.
- **Response Handling**: Fetch, process, and display AI responses.

This class is designed to abstract the complexity of AI interactions, providing a user-friendly interface while ensuring robust conversation management.
"
Class {
	#name : 'AIADiscussion',
	#superclass : 'Object',
	#instVars : [
		'history',
		'api'
	],
	#classVars : [
		'Current',
		'Histories'
	],
	#category : 'AIActions-AIADiscussion',
	#package : 'AIActions',
	#tag : 'AIADiscussion'
}

{ #category : 'accessing' }
AIADiscussion class >> current [
	Current ifNil: [ Current := self new ].
	^ Current
]

{ #category : 'accessing' }
AIADiscussion class >> currentHistory [
	^ self current history
]

{ #category : 'class initialization' }
AIADiscussion class >> histories [
	^ Histories collect: [ :dis| dis history first value -> dis history ]
]

{ #category : 'class initialization' }
AIADiscussion class >> next [

	Current
		ifNil: [
				Histories := OrderedDictionary new.
				Current := nil ]
		ifNotNil: [
				Histories add: Current.
				Current := self new. ]
]

{ #category : 'writing' }
AIADiscussion class >> readCurrentTo: fileName [
	"Serialises the current history to the specified file name."
	FLMaterializer 
		materializeFromFileNamed: (FileSystem workingDirectory / fileName) fullName
]

{ #category : 'writing' }
AIADiscussion class >> writeCurrentTo: fileName [
	"Serialises the current history to the specified file name."
	FLSerializer 
		serialize: self currentHistory 
		toFileNamed: (FileSystem workingDirectory / fileName) fullName
]

{ #category : 'initialization' }
AIADiscussion >> chatHistory [
	"Returns formatted conversation history as a string with numbered entries for each message"
	| historyText counter |
	historyText := WriteStream on: ''.
	counter := 1.
	history do: [ :item | 
		historyText << '## ['<< counter asString << '] ' << item key << String cr
			<< item value << String cr << String cr.
			counter := counter + 1.
		 ].
	"There is some comment here"
	^ historyText contents
]

{ #category : 'adding' }
AIADiscussion >> getResponse [
	"Retrieves the AI's response from the API, updates the history, and presents the response using AIACommentPresenter. Returns the response text."
	api history: history.
	api getResponse.
	AIAPresenter onText: api response.
	"getResponce adds the response to the history"
]

{ #category : 'accessing' }
AIADiscussion >> history [
	"Returns the ordered collection of chat history items, each containing a role and content. Used to track the conversation flow between user and assistant."
	^ history 
]

{ #category : 'initialization' }
AIADiscussion >> initialize [ 
	"Initialises a new AI discussion with empty history and API connection"
	super initialize.
	history := OrderedCollection new.
	api := AilienApi provider new. 
]

{ #category : 'adding' }
AIADiscussion >> response [
	^ api response
]

{ #category : 'adding' }
AIADiscussion >> user: aString [
	api history: history.
	api user: aString.
]
