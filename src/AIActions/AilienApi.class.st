"
### Class Comment for `AilienApi`

The `AilienApi` class is designed to interact with AI models, allowing users to set and retrieve various parameters such as the model, system, prompt, and response. This class is part of the `AIActions` package and is tagged with `AIApi`.

#### Usage Example

The following example demonstrates how to create and use an instance of `AilienApi` in the Pharo Playground. This example sets the model, system, prompt, and response, and then retrieves the response.

```smalltalk
| api |
api := AilienApi new.
api model: 'gpt-3.5-turbo'.
api system: 'You are a helpful assistant.'.
api prompt: 'What is the capital of France?'.
api response: 'The capital of France is Paris.'.
api response
```

#### Design Decisions

- **Interactive Scripting**: The code snippet above should be usable for scripting interactively.
- **Class Builder**: The code snippet must return a class builder.
- **Class Builder Messages**:
  - `build`: Returns a class but does not install it.
  - `install`: Installs the class in the system.
- **Class Side Slots and Traits**: The class builder manages both instance and class side information.
- **Future Improvements**: The need for fluid class builders and the API of the class builder will be revisited to reduce conversions and align with class default values.

#### Methods

- **Accessing**:
  - `model`: Returns the current model.
  - `model: anObject`: Sets the model to `anObject`.
  - `response`: Returns the current response.
  - `response: anObject`: Sets the response to `anObject`.
  - `system`: Returns the current system.
  - `system: anObject`: Sets the system to `anObject`.
  - `prompt`: Returns the current prompt.
  - `prompt: anObject`: Sets the prompt to `anObject`.

- **Initialization**:
  - `initialize`: Initialises the instance variables `model`, `system`, `prompt`, and `response` to empty strings.

#### Class Methods

- **AI Models**:
  - `modelNames`: Returns an array of model names.

- **Accessing**:
  - `models`: Subclasses should implement this to return a list of available models from the API.

This class is designed to be extended and can be used directly to create instances for interacting with AI models.
"
Class {
	#name : 'AilienApi',
	#superclass : 'Object',
	#instVars : [
		'model',
		'system',
		'prompt',
		'response'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'AI models' }
AilienApi class >> modelNames [
	"returns an array with one item per model."
	^ self models collect: [ :model | model at: 'name' ]
]

{ #category : 'accessing' }
AilienApi class >> models [
	"Subclasses should implement this to return a list of available models from the API"
	self subclassResponsibility
]

{ #category : 'ollama models' }
AilienApi >> getResponse [
	"This method initiates an AI process to retrieve a response, displaying progress and handling interruptions."

	[ :job | | aiProcess |
		aiProcess := [ self loadResponse ] newProcess.
		aiProcess priority: Processor userBackgroundPriority. 
		aiProcess resume.
		SystemProgressMorph uniqueInstance position: 10@20.
		job interruptBlock: [ 
			aiProcess terminate.
			self response: 'AI based response Terminated'.
			^ self
		].
		1 to: 300 do: [:each |
			job
				progress: ((1/300) * each) ;
				title: ('AI working {1} of 30' format: {(each/10) asFloat printString}).
				self response ifEmpty: [100 milliSeconds wait].
		].
	] asJob run.
]

{ #category : 'initialization' }
AilienApi >> initialize [ 
	"Initialises the instance variables model, system, prompt, and response to empty strings. Ensures the object is ready for use."
	super initialize.
	self model: ''.
	self system: ''.
	self prompt: ''.
	self response: ''
]

{ #category : 'mistral models' }
AilienApi >> loadResponse [
		self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> model [

	^ model
]

{ #category : 'accessing' }
AilienApi >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
AilienApi >> prompt [

	^ prompt
]

{ #category : 'accessing' }
AilienApi >> prompt: anObject [

	prompt := anObject
]

{ #category : 'accessing' }
AilienApi >> response [

	^ response
]

{ #category : 'accessing' }
AilienApi >> response: anObject [

	response := anObject
]

{ #category : 'accessing' }
AilienApi >> system [

	^ system
]

{ #category : 'accessing' }
AilienApi >> system: anObject [

	system := anObject
]
