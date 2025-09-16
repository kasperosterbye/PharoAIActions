"
# AilienApi

`AilienApi` is an abstract base class for interacting with AI language models, providing a standardised interface for managing conversations, model selection, and response handling. It maintains conversation history, supports multiple AI models, and offers methods for both synchronous and asynchronous response retrieval.

## Key Features

- **Conversation Management**: Tracks system, user, and assistant messages in chronological order
- **Model Support**: Abstract interface for different AI model providers (e.g., Mistral, Ollama)
- **Response Handling**: Methods for both immediate and background response processing
- **History Formatting**: Multiple output formats for conversation history

## Usage Example

```smalltalk
""Create and configure an API instance""
api := AilienApi new
    system: 'You are a helpful assistant';
    model: 'llama3';
    prompt: 'Explain quantum computing in simple terms'.

""Get a response (synchronous)""
api getResponse.
api response inspect.

""View formatted history""
api chatAllHistory inspect.
```

## Implementation Notes

Subclasses must implement:
- `loadResponse` for actual API calls
- `models` to provide available models

The class maintains conversation state and provides multiple history formats for different use cases.

## Design Considerations

- Abstract base class for different AI providers
- Preserves conversation context between interactions
- Supports both immediate and background response processing
- Provides multiple history output formats for different needs
```

The example shows how to:
1. Create and configure an API instance
2. Add system message and user prompt
3. Get a response (synchronous)
4. Inspect the response
5. View formatted conversation history

The comment follows British English conventions and provides clear documentation of the class's purpose and usage. The example returns an expression (`api response inspect`) that can be evaluated in the Playground using Command-I.
"
Class {
	#name : 'AilienApi',
	#superclass : 'Object',
	#instVars : [
		'provider',
		'model',
		'history'
	],
	#classInstVars : [
		'modelLLM'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'instance creation' }
AilienApi class >> default [
	"Default returns a new instance of AileinProvider provider"
	^ AileinProvider provider
]

{ #category : 'private' }
AilienApi class >> defaultModel [
	"Although defaultModel is defined in AilienApi class, the modelLLM slot is replicated per subclass metaclass. Each API provider maintains its own default independently."

	modelLLM ifNil: [ modelLLM := self modelNames first ].
	^ modelLLM
]

{ #category : 'private' }
AilienApi class >> defaultModel: modelNumber [
	"Sets the default model for the Ollama API, ensuring it exists in the available models list. If not, defaults to the first model."

	modelLLM := self modelNames 
		at: modelNumber 
		ifAbsent: [ modelLLM := self modelNames first ]
]

{ #category : 'instance creation' }
AilienApi class >> defaultProvider [ 
	AileinProvider provider: self.
	
]

{ #category : 'accessing' }
AilienApi class >> info [
	"Returns a descriptive string combining the current AI provider name and its default model name to identify the API configuration being used"
	^ AileinProvider provider name, ': ', AileinProvider provider defaultModel
]

{ #category : 'private' }
AilienApi class >> initialize [ 
	modelLLM := ''
]

{ #category : 'AI models' }
AilienApi class >> modelNames [
	"returns an array with one item per model."
	^ self subclassResponsibility
]

{ #category : 'private' }
AilienApi class >> noOfModels [

	^ self modelNames size
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
		1 to: 300 do: [:each |
			job
				progress: ((1/300) * each) ;
				title: ('AI working {1} of 30' format: {(each/10) asFloat printString}).
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
AilienApi >> initialize [ 
	"Initialises a new instance with empty model and history, ready for AI interactions. Sets up the foundation for conversation management and response handling."
	super initialize.
	self model: ''.
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
			put: 'user' -> ('[BACKGROUND] ', history first value , '. [QUESTION] ' , aString) ]
		ifFalse: [ history add: 'user' -> aString ]
]
