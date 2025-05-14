"
# Class Comment for `AilienApi`

`AilienApi` is a class designed to interact with the Ailien API, providing a structured way to manage and utilize AI models. This class encapsulates the necessary attributes and methods to configure and utilize AI models, including setting the model, system prompt, and response.

## Responsibilities

- **Model Management**: Allows setting and retrieving the AI model to be used.
- **System Prompt Management**: Provides methods to set and retrieve the system prompt, which can be used to guide the AI model's behavior.
- **Response Management**: Enables setting and retrieving the response from the AI model.
- **Initialization**: Initializes the instance with default values for the model, system prompt, and response.

## Collaborators

- **Ailien API**: Interacts with the Ailien API to fetch available models and other necessary data.

## Example Usage

```smalltalk
| api |
api := AilienApi new.
api model: 'codestral-latest'.
api system: 'You are a helpful assistant.'.
api promptPrefix: 'Please provide a summary of the following text:'.
api response: 'The text is about...'.
```

## Methods

### Accessing

- `promptPrefix: anObject`: Sets the prompt prefix.
- `system`: Returns the system prompt.
- `promptPrefix`: Returns the prompt prefix.
- `response: anObject`: Sets the response.
- `model: anObject`: Sets the AI model.
- `system: anObject`: Sets the system prompt.
- `model`: Returns the AI model.
- `response`: Returns the response.

### Initialization

- `initialize`: Initializes the instance with default values.

### Printing

- `printOn: string`: Prints a string representation of the instance.

## Class Methods

### Accessing

- `models`: Returns a list of available AI models from the API (subclass responsibility).
- `modelNames`: Returns an array of model names.

## Note

This class is part of the `AIActions` package and is tagged with `AIApi`.
"
Class {
	#name : 'AilienApi',
	#superclass : 'Object',
	#instVars : [
		'model',
		'system',
		'promptPrefix',
		'response'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'ollama models' }
AilienApi class >> modelNames [
	"returns an array with one item per model."
	^ self models collect: [ :model | model at: 'name' ]
]

{ #category : 'accessing' }
AilienApi class >> models [
	"Subclasses should implement this to return a list of available models from the API"
	self subclassResponsibility
]

{ #category : 'initialization' }
AilienApi >> initialize [ 
	super initialize.
	self model: ''.
	self system: ''.
	self promptPrefix: ''.
	self response: ''
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
AilienApi >> promptPrefix [

	^ promptPrefix
]

{ #category : 'accessing' }
AilienApi >> promptPrefix: anObject [

	promptPrefix := anObject
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
