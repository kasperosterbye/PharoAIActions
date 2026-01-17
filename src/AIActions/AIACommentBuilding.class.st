"
I am a helper for generating AI‑assisted comments for classes, methods, and packages.

I delegate all interaction with the AI provider to an `AIAHistory` instance, which stores the system and user prompts and retrieves the final response. I do *not* talk directly to any API; instead I provide a small, composable façade around the history object, suitable for use from tools such as inspectors, browsers, or scripts.

I know how to:

- Keep track of the current system and user prompts (`system`, `user` accessors).
- Trigger the AI request and manage progress and interruption (`getResponse`).
- Answer the final formatted AI comment as a plain String (`response`).

The class side maintains shared configuration for all instances:

- The preferred comment language (`language`), defaulting to British English.
- The desired comment style (`commentType`), chosen from:
  - `#Basic`
  - `#Beginner`
  - `#Detailed`
  - `#Expert`
  - `#TestGuide`

These settings are used by the surrounding tooling to steer how comments are requested and formatted.

I am designed to integrate into a larger comment‑building workflow rather than to install or modify classes myself. My responsibility is *only* to orchestrate the prompts and retrieve the generated text.

### Usage

You typically do not instantiate me directly; tools such as browsers or dedicated commands create and configure an `AIACommentBuilding` with the appropriate history object and prompts. However, you can script with me in a Playground to experiment with AI‑driven comments.

```st
| builder |
builder := AIACommentBuilding new.

""Configure global comment preferences""
AIACommentBuilding
	language: 'British';
	commentType: 'Detailed'.

""Configure the underlying history with the system and user prompts""
builder system: 'You are an AI assistant that writes Pharo code comments in British English.'.
builder user: 'Write a detailed class comment for a Point class with x and y slots.'.

""Trigger the AI request and then inspect the final response text""
builder getResponse.
builder response  ""Inspect me with Cmd–I""
"
Class {
	#name : 'AIACommentBuilding',
	#superclass : 'Object',
	#instVars : [
		'history'
	],
	#classVars : [
		'CommentLanguage',
		'CommentType'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'accessing' }
AIACommentBuilding class >> commentType [
	"Returns the current comment type for the AIACommentBuilding class"
	CommentType ifNil: [ CommentType := self commentTypes first ].
	^ CommentType 
]

{ #category : 'accessing' }
AIACommentBuilding class >> commentType: commentType [
	"Sets the comment type for the AIACommentBuilding class"

	| index |
	(commentType isInteger and: [ commentType >= 1 & commentType <= self commentTypes size ]) ifTrue: [
			CommentType := self commentTypes at: commentType.
			^ self ].
	index := self commentTypes indexOf: commentType.
	index > 0
		ifTrue: [ CommentType := commentType ]
		ifFalse: [ CommentType := self commentTypes first ]
]

{ #category : 'accessing' }
AIACommentBuilding class >> commentTypes [
	"Returns the available comment types for the AIACommentBuilding class"
	^ { 'Default'. 'LLM'. 'Beginner'. 'Detailed'. 'Expert'. 'TestGuide' }
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIClassComment [
	"Open an inspector on the AI generated comment for this class for demonstration"
	self aiaComment inspect
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIMethodComment [
	(EpLog >> #priorEntriesFrom:do:) aiaComment inspect
]

{ #category : 'examples' }
AIACommentBuilding class >> exampleAIPackageComment [
	'Epicea' aiaComment inspect
]

{ #category : 'accessing' }
AIACommentBuilding class >> language [
	CommentLanguage ifNil: [ CommentLanguage := 'British' ].
	^ CommentLanguage 
]

{ #category : 'accessing' }
AIACommentBuilding class >> language: language [
	"Sets the preferred language for comment generation to the specified language string"
	CommentLanguage := language
]

{ #category : 'accessing' }
AIACommentBuilding >> getResponse [
	"Method initiates AI process to retrieve response displaying progress and handling interruptions. Uses system progress morph to show progress and allows interruption. Returns response from AI API."
	
	history getResponse
]

{ #category : 'initialization' }
AIACommentBuilding >> initialize [ 
	"Initialises the AI comment builder with a new AI API provider, setting up the necessary infrastructure for generating AI-driven comments."
	super initialize.
	history :=AIAHistory new.
]

{ #category : 'accessing' }
AIACommentBuilding >> response [
	"Returns the AI-generated response from the API, formatted as a string. Handles errors and ensures valid output. Uses the configured AI model for processing."

	^ history response
]

{ #category : 'accessing' }
AIACommentBuilding >> system [

	^ history system
]

{ #category : 'accessing' }
AIACommentBuilding >> system: anObject [

	history system: anObject
]

{ #category : 'accessing' }
AIACommentBuilding >> user [

	^ history user
]

{ #category : 'accessing' }
AIACommentBuilding >> user: anObject [

	history user: anObject
]
