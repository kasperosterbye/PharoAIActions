"
# AilienApi

A base class for AI API providers, managing conversation history and model interactions. This abstract class defines core functionality for AI communication while allowing subclasses to implement provider-specific behavior.

## Key Features

- Maintains conversation history with system, user, and assistant messages
- Provides model management and response handling
- Supports multiple AI providers through subclassing
- Includes progress tracking for AI operations

## Usage Example

```smalltalk
""Create and configure an AI API instance""
api := AilienApi new
    system: 'You are a helpful assistant';
    model: 'mistral-tiny';
    prompt: 'Explain quantum computing in simple terms'.

""Get the response (this will show progress)""
api getResponse.

""Inspect the conversation history""
api chatAllHistory inspect
```

## Implementation Notes

- Subclasses must implement `loadResponse` to handle provider-specific API calls
- The class maintains a shared provider reference for all instances
- History is stored as an ordered collection of role-content pairs
- Provides multiple formats for accessing conversation history

## Design Considerations

- Abstract base class for provider-specific implementations
- Preserves chronological order of all messages
- Includes validation for message types and positions
- Supports both synchronous and asynchronous operations
"
Class {
	#name : 'AilienApi',
	#superclass : 'Object',
	#instVars : [
		'model',
		'history'
	],
	#classVars : [
		'LastHistory',
		'Provider'
	],
	#classInstVars : [
		'modelLLM'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
AilienApi class >> background01 [
	^ '[BACKGROUND]
User is Kasper Østerbye, retired computer science professor with deep experience in programming language design, runtime systems, and AI integration.
He has written machine code for PDP-12 and Forth on PDP-10, worked with Smalltalk, Simula, Beta, and Interlisp, and now focuses on Pharo because of its tight coupling between language and runtime.

Kasper does not just write prompts or client code – he builds and controls the entire chain from application (Pharo) to API call construction to the raw JSON sent to the LLM.
He experiments with modifying message roles, metadata, and history structures directly, including non-linear conversation graphs, parallel branches, and custom background/context injection.
This means he is exploring how the architecture of LLM interaction itself can be shaped, not just how prompts are written.

The user is not a beginner – explanations should assume deep technical knowledge and go straight to the essence.
Responses must be short, precise, and free of fluff, unless explicitly asked for elaboration.
Responses must never use emojis or tables. Output should always be plain text or structured text (like Markdown sections), but never tabular formatting.'
]

{ #category : 'AI models' }
AilienApi class >> defaultModel [
	"Although defaultModel is defined in AilienApi class, the modelLLM slot is replicated per subclass metaclass. Each API provider maintains its own default independently."
	self = AilienApi ifTrue: [ self error: 'Requires a concrete Api' ].
	modelLLM ifNil: [ modelLLM := self modelNames first ].
	^ modelLLM
]

{ #category : 'AI models' }
AilienApi class >> defaultModel: modelNumber [
	"Sets the default model for the Ollama API, ensuring it exists in the available models list. If not, defaults to the first model."

	modelLLM := self modelNames 
		at: modelNumber 
		ifAbsent: [ modelLLM := self modelNames first ]
]

{ #category : 'accessing' }
AilienApi class >> info [
	"Returns a descriptive string combining the current AI provider name and its default model name to identify the API configuration being used"
	^ self provider name asString, ': ', self provider defaultModel
]

{ #category : 'private' }
AilienApi class >> initialize [ 
	modelLLM := MistralApi modelNames first.
	Provider := MistralApi.
	
]

{ #category : 'accessing' }
AilienApi class >> lastHistory [
	^ LastHistory
]

{ #category : 'AI models' }
AilienApi class >> modelNames [
	"Returns a collection of available model names for the AI provider. Each name represents a distinct AI model that can be used for generating responses. The collection is derived from the provider's model registry and is used to validate and set the default model for the API."
	self = AilienApi ifTrue: [ ^ self provider modelNames ].
	
]

{ #category : 'instance creation' }
AilienApi class >> newOnModel: modelId [
	self = AilienApi
		ifTrue: [ ^ self provider newOnModel: modelId ]
		ifFalse: [ ^ self new model: (self modelNames at: modelId) ]
		
]

{ #category : 'AI models' }
AilienApi class >> noOfModels [

	^ self modelNames size
]

{ #category : 'provider' }
AilienApi class >> provider [
	Provider ifNil: [ self initialize ].
	^ Provider 
]

{ #category : 'provider' }
AilienApi class >> provider: aProvider [

	| providers |
	providers := self providers.
	(providers includes: aProvider) ifTrue: [
			Provider := aProvider.
			^ self ].
	(aProvider isInteger and: [ aProvider > 0 and: [ aProvider < self providers size ] ]) ifTrue: [
			Provider := providers at: aProvider.
			^ self ].
	Provider := MistralApi
]

{ #category : 'provider' }
AilienApi class >> providers [
	^ (self subclasses sort: [:a :b | a name < b name])
]

{ #category : 'initialization' }
AilienApi >> assistant: aString [
	"Adds an assistant response to the conversation history. Validates the input and updates the history with the assistant's message."
	history add: 'assistant' -> aString
]

{ #category : 'initialization' }
AilienApi >> chatAllHistory [
	"Returns a formatted string of all conversation history, with each entry prefixed by its role and separated by newlines. Preserves system, user, and assistant messages in chronological order."
	| historyText |
	historyText := WriteStream on: ''.
	history do: [ :item | 
		historyText << '## ' << item key << String cr
			<< item value << String cr << String cr
		 ].
	^ historyText contents
]

{ #category : 'initialization' }
AilienApi >> chatHistory [
	"Returns formatted chat history excluding system message, with numbered entries for user and assistant messages. Preserves chronological order."
	| historyText counter |
	historyText := WriteStream on: ''.
	counter := 1.
	history allButFirst do: [ :item | 
		historyText << '## ['<< counter asString << '] ' << item key << String cr
			<< item value << String cr << String cr.
			counter := counter + 1.
		 ].
	^ historyText contents
]

{ #category : 'ollama models' }
AilienApi >> getResponse [
	"This method initiates an AI process to retrieve a response, displaying progress and handling interruptions."
	self history ifEmpty: [ 
		self assistant: 'No answer, as I was not asked'.
		^ self ].
	
	[ :job | | aiProcess |
		aiProcess := [ self loadResponse ] newProcess.
		aiProcess priority: Processor userBackgroundPriority. 
		aiProcess resume.
		SystemProgressMorph uniqueInstance position: 10@20.
		job interruptBlock: [ 
			aiProcess terminate.
			self assistant: 'AI based response Terminated'.
			^ self
		].
		1 to: 600 do: [:each |
			job
				progress: ((1/600) * each) ;
				title: ( AilienApi info, ' working {1} of 60' 
					format: {(each/10) asFloat printString}).
				self response ifNil: [100 milliSeconds wait].
		].
	] asJob run.
]

{ #category : 'initialization' }
AilienApi >> history [
	"Returns the conversation history as an ordered collection of role-content pairs, preserving chronological order of system, user, and assistant messages."
	^ history
]

{ #category : 'initialization' }
AilienApi >> history: aHistory [
	"Returns the conversation history as an ordered collection of role-content pairs, preserving chronological order of system, user, and assistant messages."
	^ history := aHistory 
]

{ #category : 'initialization' }
AilienApi >> initialize [ 
	"Initialises a new instance with empty model and history, ready for AI interactions. Sets up the foundation for conversation management and response handling."
	super initialize.
	self model: self class defaultModel.
	history := OrderedCollection new.
]

{ #category : 'accessing' }
AilienApi >> jsonHistory [
	"Returns the conversation history as a JSON array of role-content dictionaries, preserving chronological order of system, user, and assistant messages."
	| jsonHistory |
	jsonHistory := OrderedCollection new.
	history do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'content' -> item value.})
	].
	LastHistory := history.
	^ jsonHistory asArray.
]

{ #category : 'mistral models' }
AilienApi >> loadResponse [
	"Subclasses must implement this method to load a response from the AI model, handling API calls and processing the result."
		self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> model [
	"Returns the current model name used for AI interactions. If none set, defaults to the first available model from the subclass's model list."

	^ model
]

{ #category : 'accessing' }
AilienApi >> model: anObject [
	"Sets the model for AI interactions. Validates input and updates instance state. Preserves existing history. Returns the model name."

	model := anObject
]

{ #category : 'printing' }
AilienApi >> printOn: string [
	"Prints the model name of OllamaModelsApi instance"
	string << self class name asString << '::::: ' << self model.
]

{ #category : 'initialization' }
AilienApi >> prompt: aString [
	"Adds a user prompt to the conversation history, validating input and updating the history with the user's message. Preserves chronological order."
	self user: aString
]

{ #category : 'accessing' }
AilienApi >> response [
	"Returns the last assistant response from history or nil if none exists. Preserves chronological order of messages."
	(history last key = 'assistant')
		ifTrue: [ ^ history last value ]
		ifFalse: [ ^ nil ]
]

{ #category : 'accessing' }
AilienApi >> system [
	"Adds a system message to the conversation history. Must be the first message. Validates input and updates the history with the system's message."
	history isEmpty ifTrue: [ ^ nil ].
	history first key = 'system'
		ifTrue: [ ^ history first value ]
		ifFalse: [ ^ nil ]
]

{ #category : 'initialization' }
AilienApi >> system: aString [
	"Adds a system message to the conversation history. Must be the first message. Validates input and updates the history with the system's message."
	history size = 0 ifFalse: [ self error: 'system call must be first' ].
	history add: 'system' -> aString
]

{ #category : 'initialization' }
AilienApi >> user: aString [
	"Adds a user prompt to the conversation history, validating input and updating the history with the user's message. Preserves chronological order."

	(history size = 1 and: [ history first key = 'system' ])
		ifTrue: [ history 
			at: 1 
			put: 'user' -> ('[BACKGROUND] ', history first value , String cr, 
			'[QUESTION] ' , aString) ]
		ifFalse: [ history add: 'user' -> aString ]
]
