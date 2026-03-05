Class {
	#name : 'Ollama2Api',
	#superclass : 'AilienApiWithTools',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
Ollama2Api class >> apiGenerateUrl [ 
	^ 'http://localhost:11434/api/chat'.
	
]

{ #category : 'accessing' }
Ollama2Api class >> modelNames [
	"returns an array with one item per model."
	^ self models collect: [ :ollamaModel | ollamaModel at: 'name' ]
]

{ #category : 'accessing' }
Ollama2Api class >> models [
	"returns an array with one item per model. Each item has nested informations, and some arrays"
	| response  |

	response := ZnClient new get: 'http://localhost:11434/api/tags'.
	^ (STONJSON fromString: response) at: 'models'  .
]

{ #category : 'accessing' }
Ollama2Api class >> newModel: modelNumber [
	"make an instance of OllamaApi based on a specfic Ollama model installed"
	| selectedModel |
	selectedModel := self modelNames 
		at: modelNumber 
		ifAbsent: [ self modelNames at: 1 ]. "Select the first one"
	^ self new model: selectedModel 
]

{ #category : 'accessing' }
Ollama2Api class >> ollamaVersion [
	"Retrieve the Ollama version"
	| response  |
	
	response := ZnClient new get: 'http://localhost:11434/api/version'.
	^ (STONJSON fromString: response) at: 'version'  .
]

{ #category : 'accessing' }
Ollama2Api class >> znClientHeaders: foo [
	"ignore me"
]

{ #category : 'adding' }
Ollama2Api >> continueToolCall: parsed orWrite: aHistory [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
	(parsed includesKey: 'error') ifTrue: [ 
		self responseError: parsed hist: aHistory. 
		^ nil ].
	message := parsed at: 'message'.
	content := message at: 'content'.
	(content isNotNil and: [ content isNotEmpty  ]) ifTrue: [
			aHistory assistant: content" from: self".
			^ nil ].
	^ message.
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
Ollama2Api >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item | self addJsonHistory: jsonHistory for: item ].
    ^ jsonHistory asArray
]

{ #category : 'responses' }
Ollama2Api >> printOn: aStream [
	aStream << 'Ollama2Api: ' << self model.
]

{ #category : 'adding' }
Ollama2Api >> processToolCall: call [
	"Processes a single tool call, executes the corresponding tool with its arguments, and returns the result formatted for the conversation history."
    | func result |
    func := call at: 'function'.
    result := self 
        executeToolNamed: (func at: 'name') 
        withArgs: (func at: 'arguments').
    ^ 'tool' -> (Dictionary newFrom: {
        'tool_call_id' -> (call at: 'id').
        'content' -> result })
]

{ #category : 'responses' }
Ollama2Api >> znClientEntity [
	^ super znClientEntity ,  {
        'tools' -> self toolSpecification.
    } .
]
