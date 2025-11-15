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

{ #category : 'backgrounds' }
AilienApi class >> background01 [
	^ '[BACKGROUND]
User is Kasper Østerbye, retired computer science professor with deep experience in programming language design, runtime systems, and AI integration.
He has written machine code for PDP-12 and Forth on PDP-10, worked with Smalltalk, Simula, Beta, and Interlisp, and now focuses on Pharo because of its tight coupling between language and runtime.

Kasper does not just write prompts or client code – he builds and controls the entire chain from application (Pharo) to API call construction to the raw JSON sent to the LLM.
He experiments with modifying message roles, metadata, and history structures directly, including non-linear conversation graphs, parallel branches, and custom background/context injection.
This means he is exploring how the architecture of LLM interaction itself can be shaped, not just how prompts are written.
The user is not a beginner – explanations should assume deep technical knowledge and go straight to the essence.
Responses must be short, precise, and free of fluff, unless explicitly asked for elaboration.
Responses must never use emojis or tables. Output should always be plain text or structured text (like Markdown sections), but never tabular formatting.
Kasper prefers to interact with the model as an intelligent "AIlien" — a non-human form of intelligence with its own perspective and reasoning style. The model should not try to imitate humans, but embrace its alien nature and think independently.'
]

{ #category : 'as yet unclassified' }
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

{ #category : 'backgrounds' }
AilienApi class >> playground01 [
	^ 
'AilienApi providerAndModels.
AilienApi providers.

AilienApi info. 
AilienApi provider: OpenAIApi .
AilienApi provider: GrokApi .
AilienApi provider: ClaudeApi.
AilienApi provider: GeminiApi.
AilienApi provider: MistralApi.
AilienApi provider: MistralApiWithTools.
AilienApi provider: OllamaApi.

MistralApi modelNames.
MistralApi defaultModel: 1.

GrokApi modelNames.
GrokApi defaultModel: 1.

ClaudeApi modelNames.
ClaudeApi defaultModel: 1.

GeminiApi modelNames.
GeminiApi defaultModel: 1.

OpenAIApi modelNames.
OpenAIApi defaultModel: 2.

OllamaApi modelNames.
OllamaApi defaultModel: 1.

AIABuilder language: ''British''.
AIABuilder language: ''Swedis''.
AIABuilder language: ''Meänkieli''.
''British''.
AIABuilder language: ''French''.
AIABuilder language: ''Chineese''.
'
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
	self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> bodyForEntityWithPrompt [
	self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> headers: foo [
	self subclassResponsibility
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
]

{ #category : 'accessing' }
AilienApi >> jsonHistory [
	"Returns the conversation history as a JSON array of role-content dictionaries, preserving chronological order of system, user, and assistant messages."
	| jsonHistory |
	jsonHistory := OrderedCollection new.
	history apiMessageList do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'content' -> item value.})
	].
	"LastHistory := history."
	^ jsonHistory asArray.
]

{ #category : 'accessing' }
AilienApi >> loadResponse [
	"Executes HTTP request to AI provider endpoint and processes response into conversation history with error handling"
	
	| jsonResponse llmCall response|
	[  jsonResponse := ZnClient new
			                url: self apiGenerateUrl;
			                entity: self bodyForEntityWithPrompt.
		self headers: jsonResponse.
		llmCall := jsonResponse
			           post;
			           contents.
		response := self responseOf: llmCall.
		history assistant: (self responseOf: llmCall). 
		]
		on: Error
		do: [ :ex | history assistant: ex messageText ]
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
	self subclassResponsibility
]
