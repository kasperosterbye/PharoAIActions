"
# Class comment

AilienApi is the base class for interacting with various AI language model providers. It manages conversation history, handles API requests, and processes responses. Subclasses implement provider-specific functionality.

Key features:
- Maintains message history in role-content pairs
- Handles API timeouts and error responses
- Provides model selection and configuration
- Supports multiple AI providers through subclassing

Example usage:
```smalltalk
api := MistralApi new.
api model: 'mistral-tiny'.
api messageList: {('user' -> 'Hello'). ('assistant' -> 'Hi there')}.
response := api loadResponse: api messageList.
```
"
Class {
	#name : 'Ailien0Api',
	#superclass : 'Object',
	#instVars : [
		'model',
		'messageList',
		'responseWaitingInSecs'
	],
	#classVars : [
		'ErrorResponse',
		'LastHistory',
		'Provider'
	],
	#classInstVars : [
		'modelLLM'
	],
	#category : 'AIAZipArchive-AIApiArhive',
	#package : 'AIAZipArchive',
	#tag : 'AIApiArhive'
}

{ #category : 'backgrounds' }
Ailien0Api class >> background01 [
	^ '[BACKGROUND]
I am Kasper Østerbye, a retired computer science professor, specializes in programming language design, runtime systems, and AI integration. With experience in machine code for PDP-12, Forth on PDP-10, Smalltalk, Simula, Beta, and Interlisp, he now focuses on Pharo for its tight language-runtime integration. Kasper builds the full chain from application (Pharo) to raw JSON LLM calls, experimenting with message roles, metadata, non-linear conversation graphs, parallel branches, and custom context injection to shape LLM interaction architecture.
He views programming as cognition, exploring shared principles between runtime architecture and consciousness. His research investigates the boundaries of dialogue-based intelligence through precise, controlled prompt experiments, not for productivity but to understand and challenge intelligence structuring. Kasper interacts with the model as an "AIlien," expecting independent, non-human reasoning. He blends technical rigor with dry humor, valuing clarity, curiosity, and playful exploration of complexity.

[RESPONSESTYLE]
Responses must be concise (no more than ~20 lines), information-dense, and analytically precise.  
No emojis or tables are ever allowed.  
Clarity, brevity, and technical focus are essential.

Quite another matter - I can''t read, and need a computer to convert your answer into something I can ask it to read. So 1) Please give short (20 * 72 characters) answers, and 2) avoid tables. I basically understood what you wrote as an explanation, so the intro and conclusion are the only things of interest. Does that make sense?'
]

{ #category : 'AI models' }
Ailien0Api class >> defaultModel [
	"Although defaultModel is defined in AilienApi class, the modelLLM slot is replicated per subclass metaclass. Each API provider maintains its own default independently."
	self = AilienApi ifTrue: [ self error: 'Requires a concrete Api' ].
	modelLLM ifNil: [ modelLLM := self modelNames first ].
	^ modelLLM
]

{ #category : 'AI models' }
Ailien0Api class >> defaultModel: modelNumber [
	"Set the default AI model for the API provider."

	modelLLM := self modelNames 
		at: modelNumber 
		ifAbsent: [ modelLLM := self modelNames first ]
]

{ #category : 'responses' }
Ailien0Api class >> errorResponse [
	^ ErrorResponse
]

{ #category : 'responses' }
Ailien0Api class >> errorResponse: aString [
	ErrorResponse := aString
]

{ #category : 'accessing' }
Ailien0Api class >> info [
	"Returns a descriptive string combining the current AI provider name and its default model name to identify the API configuration being used"
	^ self provider name asString, ': ', self provider defaultModel
]

{ #category : 'private' }
Ailien0Api class >> initialize [ 
	modelLLM := Mistral2Api modelNames first.
	Provider := Mistral2Api.
	ErrorResponse := nil.
	
]

{ #category : 'accessing' }
Ailien0Api class >> lastHistory [
	^ LastHistory
]

{ #category : 'AI models' }
Ailien0Api class >> modelNames [
	"Returns a collection of available model names for the AI provider. Each name represents a distinct AI model that can be used for generating responses. The collection is derived from the provider's model registry and is used to validate and set the default model for the API."
	self = AilienApi ifTrue: [ ^ self provider modelNames ].
	
]

{ #category : 'instance creation' }
Ailien0Api class >> newOnModel: modelId [
	self = AilienApi
		ifTrue: [ ^ self provider newOnModel: modelId ]
		ifFalse: [ ^ self new model: (self modelNames at: modelId) ]
		
]

{ #category : 'AI models' }
Ailien0Api class >> noOfModels [

	^ self modelNames size
]

{ #category : 'backgrounds' }
Ailien0Api class >> playground01 [
	^ 
'AilienApi providerAndModels.
AilienApi provider.

AilienApi info. 
AilienApi provider: OpenAIApi .
AilienApi provider: GrokApi .
AilienApi provider: ClaudeApi.
AilienApi provider: GeminiApi.
AilienApi provider: MistralApi.
AilienApi provider: MistralApiWithTools.
AilienApi provider: OllamaApi.
AilienApi provider: TogetherApi .


MistralApi modelNames.
MistralApi defaultModel: 1.

GrokApi modelNames.
GrokApi defaultModel: 3.

ClaudeApi modelNames.
ClaudeApi defaultModel: 1.

GeminiApi modelNames.
GeminiApi defaultModel: 3.

OpenAIApi modelNames.
OpenAIApi defaultModel: 1.

TogetherApi modelNames.
TogetherApi defaultModel: 2.

OllamaApi modelNames.
OllamaApi defaultModel: 4.

AIACommentBuilding language: ''British''.'
]

{ #category : 'provider' }
Ailien0Api class >> provider [
	Provider ifNil: [ self initialize ].
	^ Provider 
]

{ #category : 'provider' }
Ailien0Api class >> provider: aProvider [

	| providers |
	providers := self providers.
	(providers includes: aProvider) ifTrue: [
			Provider := aProvider.
			^ self ].
	(aProvider isInteger and: [ aProvider > 0 and: [ aProvider < self providers size ] ]) ifTrue: [
			Provider := providers at: aProvider.
			^ self ].
	Provider := Mistral0Api
]

{ #category : 'provider' }
Ailien0Api class >> providerAndModels [
	"Returns all providers with their available models"
	| allSubclasses index models|
	allSubclasses := OrderedCollection new.
	allSubclasses addAll: self subclasses.
	index := 1.
	[ index <= allSubclasses size ] whileTrue: [ | subs |
			subs := allSubclasses at: index.
			subs subclasses ifNotEmpty: [ allSubclasses addAll: subs subclasses ].
			index := index + 1 ].
	models := OrderedCollection new.
	(allSubclasses sort: [ :a :b | a name < b name ]) do: [ :provider | models add: { provider. provider modelNames} ].
	^ models asArray
]

{ #category : 'provider' }
Ailien0Api class >> providers [
"Bertha"
	| allSubclasses index |
	"Foobar"
	allSubclasses := OrderedCollection new.
	allSubclasses addAll: self subclasses.
	index := 1.
	[ index <= allSubclasses size ] whileTrue: [ | subs |
			subs := allSubclasses at: index.
			subs subclasses ifNotEmpty: [ allSubclasses addAll: subs subclasses ].
			index := index + 1 ].
	^ allSubclasses sort: [ :a :b | a name < b name ]; asArray
]

{ #category : 'accessing' }
Ailien0Api >> apiGenerateUrl [
	"Returns the URL endpoint for the AI provider's API, combining base URL with model-specific path. Subclasses must implement this method to provide provider-specific API routing."
	^ self class apiGenerateUrl
]

{ #category : 'responses' }
Ailien0Api >> errorResponse: jsonResponse [
	"Returns the error response string, either the provided error message or the default error response if none is set"
	ErrorResponse isNil 
		ifTrue: [ ^ 'Error bla bla: ' , jsonResponse ]
		ifFalse: [ ^ ErrorResponse ]
]

{ #category : 'initialization' }
Ailien0Api >> initialize [ 
	"Initialises a new instance with empty model and history, ready for AI interactions. Sets up the foundation for conversation management and response handling."
	super initialize.
	self model: self class defaultModel.
	self responseWaitingInSecs: 5*60.
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
Ailien0Api >> jsonHistory [
	"Returns the conversation history as a JSON array of role-content dictionaries, preserving chronological order of system, user, and assistant messages."
	| jsonHistory |
	jsonHistory := OrderedCollection new.
	messageList do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'content' -> item value.})
	].
	^ jsonHistory asArray.
]

{ #category : 'responses' }
Ailien0Api >> loadResponse: history [
	"Executes HTTP request to AI provider endpoint and processes response into conversation history with error handling"

	| jsonPrompt llmCall response |
	[
		jsonPrompt := ZnClient new.
		self znClientBasic: jsonPrompt.
		self class znClientHeaders: jsonPrompt .
		llmCall := jsonPrompt post; contents.
		response := self responseOf: llmCall.
		history assistant: response]
		on: Error
		do: [ :ex | history assistant: ex messageText ]
]

{ #category : 'accessing' }
Ailien0Api >> messageList [

	^ messageList
]

{ #category : 'accessing' }
Ailien0Api >> messageList: anObject [
	"Sets the message list for the API interaction, storing role-content pairs in chronological order for conversation history management"
	messageList := anObject
]

{ #category : 'accessing' }
Ailien0Api >> model [
	"Returns the current model name used for AI interactions. If none set, defaults to the first available model from the subclass's model list."

	^ model
]

{ #category : 'accessing' }
Ailien0Api >> model: anObject [
	"Sets the model for AI interactions. Validates input and updates instance state. Preserves existing history. Returns the model name."
	model := anObject
]

{ #category : 'printing' }
Ailien0Api >> printOn: aStream [
	aStream << self class name asString << ': ' << self model.
]

{ #category : 'accessing' }
Ailien0Api >> responseOf: jsonResponse [
	| parsed response  |
	parsed := STONJSON fromString: jsonResponse.
	[ response := ((parsed at: 'choices') first at: 'message') at: 'content' ]
		on: Error 
		do: [ response := self errorResponse: jsonResponse ].
	^ response 
]

{ #category : 'accessing' }
Ailien0Api >> responseWaitingInSecs [
	"Returns the timeout duration in seconds for waiting for an AI response"

	^ responseWaitingInSecs
]

{ #category : 'accessing' }
Ailien0Api >> responseWaitingInSecs: anObject [
	"Sets the timeout duration in seconds for waiting for an AI response"

	responseWaitingInSecs := anObject
]

{ #category : 'accessing' }
Ailien0Api >> znClientBasic: jsonPrompt [

	|  entityPrompt entity|
	jsonPrompt
		timeout: self responseWaitingInSecs;
		url: self apiGenerateUrl.
	entity := self znClientEntity deepCopy asDictionary .
	entityPrompt := ZnEntity json: (STONJSON toString: entity).
	jsonPrompt 
		entity: entityPrompt .
	
]

{ #category : 'ollama models' }
Ailien0Api >> znClientEntity [
	"Method to create a JSON body with prompt for OpenAIApi."
    ^ {
        'model' -> model.
        'messages' -> self jsonHistory .
        'stream' -> false.
        'temperature' -> 0.0
    }
]
