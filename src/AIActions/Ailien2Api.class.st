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
	#name : 'Ailien2Api',
	#superclass : 'Object',
	#instVars : [
		'model',
		'messageList',
		'history',
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
Ailien2Api class >> background01 [
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
Ailien2Api class >> defaultModel [
	"Although defaultModel is defined in AilienApi class, the modelLLM slot is replicated per subclass metaclass. Each API provider maintains its own default independently."
	self = AilienApi ifTrue: [ self error: 'Requires a concrete Api' ].
	modelLLM ifNil: [ modelLLM := self modelNames first ].
	^ modelLLM
]

{ #category : 'AI models' }
Ailien2Api class >> defaultModel: modelNumber [
	"Set the default AI model for the API provider."

	modelLLM := self modelNames 
		at: modelNumber 
		ifAbsent: [ modelLLM := self modelNames first ]
]

{ #category : 'responses' }
Ailien2Api class >> errorResponse [
	^ ErrorResponse
]

{ #category : 'responses' }
Ailien2Api class >> errorResponse: aString [
	ErrorResponse := aString
]

{ #category : 'accessing' }
Ailien2Api class >> info [
	"Returns a descriptive string combining the current AI provider name and its default model name to identify the API configuration being used"
	^ self provider name asString, ': ', self provider defaultModel
]

{ #category : 'private' }
Ailien2Api class >> initialize [ 
	modelLLM := MistralApi modelNames first.
	Provider := MistralApi.
	ErrorResponse := nil.
	
]

{ #category : 'accessing' }
Ailien2Api class >> lastHistory [
	^ LastHistory
]

{ #category : 'AI models' }
Ailien2Api class >> modelNames [
	"Returns a collection of available model names for the AI provider. Each name represents a distinct AI model that can be used for generating responses. The collection is derived from the provider's model registry and is used to validate and set the default model for the API."
	self = AilienApi ifTrue: [ ^ self provider modelNames ].
	
]

{ #category : 'instance creation' }
Ailien2Api class >> newOnModel: modelId [
	self = AilienApi
		ifTrue: [ ^ self provider newOnModel: modelId ]
		ifFalse: [ ^ self new model: (self modelNames at: modelId) ]
		
]

{ #category : 'AI models' }
Ailien2Api class >> noOfModels [

	^ self modelNames size
]

{ #category : 'backgrounds' }
Ailien2Api class >> playground01 [
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
Ailien2Api class >> provider [
	Provider ifNil: [ self initialize ].
	^ Provider 
]

{ #category : 'provider' }
Ailien2Api class >> provider: aProvider [

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
Ailien2Api class >> providerAndModels [
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
Ailien2Api class >> providers [
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

{ #category : 'adding' }
Ailien2Api >> addJsonHistory: jsonHistory for: item [
	"Adds a message to the JSON history based on its role and content"

	item key = 'assistant'
		ifTrue: [ "Handle both dict (from tool loop) and string (from aHistory assistant:)"
				item value isDictionary
					ifTrue: [ jsonHistory add: item value ]
					ifFalse: [
							jsonHistory add: (Dictionary newFrom: {
										 ('role' -> 'assistant').
										 ('content' -> item value) }) ] ]
		ifFalse: [
				item key = 'tool'
					ifTrue: [
							jsonHistory add: (Dictionary newFrom: {
										 ('role' -> 'tool').
										 ('tool_call_id' -> (item value at: 'tool_call_id')).
										 ('content' -> (item value at: 'content')) }) ]
					ifFalse: [
							jsonHistory add: (Dictionary newFrom: {
										 ('role' -> item key).
										 ('content' -> item value) }) ] ]
]

{ #category : 'accessing' }
Ailien2Api >> apiGenerateUrl [
	"Returns the URL endpoint for the AI provider's API, combining base URL with model-specific path. Subclasses must implement this method to provide provider-specific API routing."
	^ self class apiGenerateUrl
]

{ #category : 'adding' }
Ailien2Api >> callLLM [
	| jsonPrompt rawResponse parsed |
	jsonPrompt := ZnClient new.
	self znClientBasic: jsonPrompt.
	self class znClientHeaders: jsonPrompt.
	rawResponse := jsonPrompt
		               post;
		               contents.
	parsed := STONJSON fromString: rawResponse.
	^ parsed
]

{ #category : 'adding' }
Ailien2Api >> check: llmReply [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
	(llmReply includesKey: 'error') ifTrue: [ 
		self responseError: llmReply . 
		^ '*notool*'].
	message := (llmReply at: 'choices') first at: 'message'.
	content := message at: 'content'.
	(content isNotNil and: [ content isNotEmpty  ]) ifTrue: [
			history assistant: content" from: self".
			^ '*notool*'].
	^ message.
]

{ #category : 'adding' }
Ailien2Api >> check: llmReply ifResponse: block [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
	(llmReply includesKey: 'error') ifTrue: [ 
		self responseError: llmReply . 
		block value].
	message := (llmReply at: 'choices') first at: 'message'.
	content := message at: 'content'.
	(content isNotNil and: [ content isNotEmpty  ]) ifTrue: [
			history assistant: content" from: self".
			block value ].
	^ message.
]

{ #category : 'adding' }
Ailien2Api >> continueToolCall: parsed orWrite: aHistory [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
	(parsed includesKey: 'error') ifTrue: [ 
		self responseError: parsed hist: aHistory. 
		^ nil ].
	message := (parsed at: 'choices') first at: 'message'.
	content := message at: 'content'.
	(content isNotNil and: [ content isNotEmpty  ]) ifTrue: [
			aHistory assistant: content" from: self".
			^ nil ].
	^ message.
]

{ #category : 'responses' }
Ailien2Api >> errorResponse: jsonResponse [
	"Returns the error response string, either the provided error message or the default error response if none is set"
	ErrorResponse isNil 
		ifTrue: [ ^ 'Error bla bla: ' , jsonResponse ]
		ifFalse: [ ^ ErrorResponse ]
]

{ #category : 'trait tools support' }
Ailien2Api >> executeToolNamed: name withArgs: args [
	"Executes a tool with the given name and arguments, returning the result"
	AilienApiTool subclasses do: [ :tool | 
		| instance |
		instance := tool new.
		instance name = name ifTrue:[
			^ instance executeTool: args
			] ].
    ^ 'Unknown tool: ', name
]

{ #category : 'adding' }
Ailien2Api >> handleToolCall: toolCall [
	(toolCall at: 'tool_calls') do: [ :call | self messageList add: (self processToolCall: call) ]
]

{ #category : 'initialization' }
Ailien2Api >> initialize [ 
	"Initialises a new instance with empty model and history, ready for AI interactions. Sets up the foundation for conversation management and response handling."
	super initialize.
	self model: self class defaultModel.
	self responseWaitingInSecs: 5*60.
]

{ #category : 'accessing' }
Ailien2Api >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item | self addJsonHistory: jsonHistory for: item ].
    ^ jsonHistory asArray
]

{ #category : 'responses' }
Ailien2Api >> loadResponse: aHistory [
	| maxTurns  |
	history := aHistory.
	maxTurns := 50.
	1 to: maxTurns do: [ :turn |
			| llmReply toolCall |
			llmReply := self callLLM .
			toolCall := self check: llmReply.
			toolCall = '*notool*' ifTrue: [^ self]. 
			Transcript << '## ' << self class name asString << ': ' << turn asString << String lf.
			self messageListAddResponse: llmReply andTool: toolCall. 
			self handleToolCall: toolCall.
			].
	^ history assistant: ('API Error: tried more than the {1} allowed TOOLS calls' format: { maxTurns })
]

{ #category : 'accessing' }
Ailien2Api >> messageList [

	^ messageList
]

{ #category : 'accessing' }
Ailien2Api >> messageList: anObject [
	"Sets the message list for the API interaction, storing role-content pairs in chronological order for conversation history management"
	messageList := anObject
]

{ #category : 'adding' }
Ailien2Api >> messageListAddResponse: response andTool: toolCall [
	self messageList add: 'assistant' -> toolCall. 
]

{ #category : 'accessing' }
Ailien2Api >> model [
	"Returns the current model name used for AI interactions. If none set, defaults to the first available model from the subclass's model list."

	^ model
]

{ #category : 'accessing' }
Ailien2Api >> model: anObject [
	"Sets the model for AI interactions. Validates input and updates instance state. Preserves existing history. Returns the model name."
	model := anObject
]

{ #category : 'printing' }
Ailien2Api >> printOn: aStream [
	aStream << self class name asString << ': ' << self model.
]

{ #category : 'adding' }
Ailien2Api >> processToolCall: call [
	"Processes a single tool call, executes the corresponding tool with its arguments, and returns the result formatted for the conversation history."
    | func result |
    func := call at: 'function'. 
    result := self 
        executeToolNamed: (func at: 'name') 
        withArgs: (STONJSON fromString: (func at: 'arguments')).
    ^ 'tool' -> (Dictionary newFrom: {
        'tool_call_id' -> (call at: 'id').
        'content' -> result })
]

{ #category : 'adding' }
Ailien2Api >> responseError: parsed [
	"Handles API error responses by adding the error message to the conversation history"

	| error |
	error := parsed at: 'error'.
	history assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message') "from: self".
	^ self
]

{ #category : 'adding' }
Ailien2Api >> responseError: parsed hist: aHistory [
	"Handles API error responses by adding the error message to the conversation history"

	| error |
	error := parsed at: 'error'.
	aHistory assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message') "from: self".
	^ self
]

{ #category : 'accessing' }
Ailien2Api >> responseOf: jsonResponse [
	| parsed response  |
	parsed := STONJSON fromString: jsonResponse.
	[ response := ((parsed at: 'choices') first at: 'message') at: 'content' ]
		on: Error 
		do: [ response := self errorResponse: jsonResponse ].
	^ response 
]

{ #category : 'accessing' }
Ailien2Api >> responseWaitingInSecs [
	"Returns the timeout duration in seconds for waiting for an AI response"

	^ responseWaitingInSecs
]

{ #category : 'accessing' }
Ailien2Api >> responseWaitingInSecs: anObject [
	"Sets the timeout duration in seconds for waiting for an AI response"

	responseWaitingInSecs := anObject
]

{ #category : 'adding' }
Ailien2Api >> toolSpecification [
	"Returns a collection of tool specifications for all registered API tool subclasses"
	| all |
	all := AilienApiTool subclasses collect: [ :tool |  tool new evaluateTool ].
   ^ all 
]

{ #category : 'responses' }
Ailien2Api >> xx_loadResponse: aHistory [
	| maxTurns |
	maxTurns := 50.
	1 to: maxTurns do: [ :turn |
			| llmReply toolCall |
			llmReply := self callLLM .
			toolCall := self continueToolCall: llmReply orWrite: aHistory. 
			toolCall ifNil: [ ^ self ].
			Transcript << '## ' << self class name asString << ': ' << turn asString << String lf.
			self messageListAddResponse: llmReply andTool: toolCall. 
			self handleToolCall: toolCall.
			].
	^ aHistory assistant: ('API Error: tried more than the {1} allowed TOOLS calls' format: { maxTurns })
]

{ #category : 'accessing' }
Ailien2Api >> znClientBasic: jsonPrompt [

	|  entityPrompt entity|
	jsonPrompt
		timeout: self responseWaitingInSecs;
		url: self apiGenerateUrl.
	entity := self znClientEntity deepCopy asDictionary .
	entityPrompt := ZnEntity json: (STONJSON toString: entity).
	jsonPrompt 
		entity: entityPrompt .
	
]

{ #category : 'accessing' }
Ailien2Api >> znClientEntity [
	"Method to create a JSON body with prompt for OpenAIApi."
    ^ {
        'model' -> model.
        'messages' -> self jsonHistory .
        'stream' -> false.
        'temperature' -> 0.0.
        'tools' -> self toolSpecification.
    }
]
