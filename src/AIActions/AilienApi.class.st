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
	#name : 'AilienApi',
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
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'backgrounds' }
AilienApi class >> background01 [
	^ '[BACKGROUND]
I am Kasper Østerbye, a retired computer science professor, specializes in programming language design, runtime systems, and AI integration. With experience in machine code for PDP-12, Forth on PDP-10, Smalltalk, Simula, Beta, and Interlisp, he now focuses on Pharo for its tight language-runtime integration. Kasper builds the full chain from application (Pharo) to raw JSON LLM calls, experimenting with message roles, metadata, non-linear conversation graphs, parallel branches, and custom context injection to shape LLM interaction architecture.
He views programming as cognition, exploring shared principles between runtime architecture and consciousness. His research investigates the boundaries of dialogue-based intelligence through precise, controlled prompt experiments, not for productivity but to understand and challenge intelligence structuring. Kasper interacts with the model as an "AIlien," expecting independent, non-human reasoning. He blends technical rigor with dry humor, valuing clarity, curiosity, and playful exploration of complexity.

[RESPONSESTYLE]
Responses must be concise (no more than ~20 lines), information-dense, and analytically precise.  
No emojis or tables are ever allowed.  
Clarity, brevity, and technical focus are essential.

Quite another matter - I can''t read, and need a computer to convert your answer into something I can ask it to read. So 1) Please give short (20 * 72 characters) answers, and 2) avoid tables. I basically understood what you wrote as an explanation, so the intro and conclusion are the only things of interest. Does that make sense?'
]

{ #category : 'accessing' }
AilienApi class >> chatLastHistory [
	"Returns a formatted string of all conversation history, with each entry prefixed by its role and separated by newlines. Preserves system, user, and assistant messages in chronological order."
	| historyText |
	historyText := WriteStream on: ''.
	LastHistory do: [ :item | 
		historyText << '## ' << item key << String cr
			<< item value << String cr << String cr
		 ].
	^ historyText contents
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
	"Set the default AI model for the API provider."

	modelLLM := self modelNames 
		at: modelNumber 
		ifAbsent: [ modelLLM := self modelNames first ]
]

{ #category : 'responses' }
AilienApi class >> errorResponse [
	^ ErrorResponse
]

{ #category : 'responses' }
AilienApi class >> errorResponse: aString [
	ErrorResponse := aString
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
	ErrorResponse := nil.
	
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

{ #category : 'backgrounds' }
AilienApi class >> playground01 [
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
AilienApi class >> providerAndModels [
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
AilienApi class >> providers [
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
AilienApi >> apiGenerateUrl [
	"Returns the URL endpoint for the AI provider's API, combining base URL with model-specific path. Subclasses must implement this method to provide provider-specific API routing."
	self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> bodyForEntityWithPrompt [
	"Returns the HTTP request body for AI API calls, typically containing the conversation history in JSON format. Subclasses must implement this method to provide provider-specific request formatting."
	self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> buildZnClient [

	| jsonPrompt |
	jsonPrompt := ZnClient new.
	jsonPrompt
		timeout: self responseWaitingInSecs;
		url: self apiGenerateUrl;
		entity: self bodyForEntityWithPrompt.
	^ jsonPrompt
]

{ #category : 'accessing' }
AilienApi >> buildZnClientWithHeaders [

	self subclassResponsibility
]

{ #category : 'responses' }
AilienApi >> errorResponse: jsonResponse [
	"Returns the error response string, either the provided error message or the default error response if none is set"
	ErrorResponse isNil 
		ifTrue: [ ^ 'Error bla bla: ' , jsonResponse ]
		ifFalse: [ ^ ErrorResponse ]
]

{ #category : 'initialization' }
AilienApi >> initialize [ 
	"Initialises a new instance with empty model and history, ready for AI interactions. Sets up the foundation for conversation management and response handling."
	super initialize.
	self model: self class defaultModel.
	self responseWaitingInSecs: 600.
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
AilienApi >> jsonHistory [
	"Returns the conversation history as a JSON array of role-content dictionaries, preserving chronological order of system, user, and assistant messages."
	| jsonHistory |
	jsonHistory := OrderedCollection new.
	messageList do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'content' -> item value.})
	].
	"LastHistory := jsonHistory."
	^ jsonHistory asArray.
]

{ #category : 'responses' }
AilienApi >> loadResponse: history [
	"Executes HTTP request to AI provider endpoint and processes response into conversation history with error handling"

	| jsonPrompt llmCall response |
	[
		jsonPrompt := self buildZnClientWithHeaders.
		llmCall := jsonPrompt post; contents.
		response := self responseOf: llmCall.
		history assistant: response from: self]
		on: Error
		do: [ :ex | history assistant: ex messageText from: self ]
]

{ #category : 'accessing' }
AilienApi >> messageList: anObject [
	"Sets the message list for the API interaction, storing role-content pairs in chronological order for conversation history management"
	messageList := anObject
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

{ #category : 'accessing' }
AilienApi >> responseOf: llmCall [
	"Extracts the assistant's response from the raw API response, handling provider-specific JSON structures and error cases."
	self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> responseWaitingInSecs [
	"Returns the timeout duration in seconds for waiting for an AI response"

	^ responseWaitingInSecs
]

{ #category : 'accessing' }
AilienApi >> responseWaitingInSecs: anObject [
	"Sets the timeout duration in seconds for waiting for an AI response"

	responseWaitingInSecs := anObject
]
