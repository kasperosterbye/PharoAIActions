"
# Class Comment for AIAHistory

`AIAHistory` is a class designed to manage and maintain conversation history between a user and an AI assistant. It provides functionality to store, retrieve, and format messages exchanged in a chat session, while also supporting contextual roles such as system messages and response types.

## Key Features

- **Message Management**: Stores and retrieves messages in chronological order, distinguishing between user and assistant messages.
- **Contextual Roles**: Supports system messages and response type definitions to provide context for AI responses.
- **API Integration**: Works with an AI API provider (e.g., `AilienApi`) to generate and retrieve responses.
- **Progress Tracking**: Includes visual progress indicators for long-running AI processes.
- **Formatted Output**: Generates formatted chat history suitable for display or logging.

## Usage Example

```st
""Create and configure a new AIAHistory instance""
history := AIAHistory new
    system: 'You are a helpful assistant.';
    background: 'The user is learning about AI.';
    user: 'What is the capital of France?';
    yourself.

""Get a response from the AI""
history getResponse.

""Inspect the formatted chat history""
history chatHistory
```

This class is particularly useful for applications requiring persistent conversation management, such as chatbots, virtual assistants, or AI-powered support systems.
"
Class {
	#name : 'AIAHistory',
	#superclass : 'Object',
	#instVars : [
		'api',
		'preHistories',
		'messages',
		'firstRoles',
		'lastRoles'
	],
	#classVars : [
		'Histories'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
AIAHistory class >> dDiscussion [
	<example>
	| dDiscussion  |
	dDiscussion := 'dDiscussion'.
	(Histories includesKey: dDiscussion) ifFalse: [ 
		| newDiscussion |
		newDiscussion := self new.
		self setHistory: dDiscussion to: newDiscussion. ].
	^ self historyAt: dDiscussion.
	 
]

{ #category : 'initialization' }
AIAHistory class >> histories [
	^ Histories
]

{ #category : 'initialization' }
AIAHistory class >> historyAt: id [
	^ Histories at: id ifAbsent: [ self error ]
]

{ #category : 'as yet unclassified' }
AIAHistory class >> qHistory [
	<example>
	| qHist |
	qHist := self new.
	qHist system: 'You are a Pharo12 Smalltalk expert. In Pharo12 and later, a typical class is written as: 
	Object << #AilienApi
	slots: { #model . #messagesx . #history };
	sharedVariables: { #LastHistoryx . #Provider };
	tag: ''AIApi'';
	package: ''AIActions''.
	In Pharo, operations, comparison operators, or in general  binary selectors are evaluated left to right without operator precedence. True and False er NOT numbers, but booleans.'.
	qHist responseType: 'Please response in ', AIACommentBuilding language.
	self setHistory: 'qPrefix' to: qHist.
	^ qHist 
]

{ #category : 'as yet unclassified' }
AIAHistory class >> readCurrentTo: fileName [
	"Serialises the current history to the specified file name."
	FLMaterializer 
		materializeFromFileNamed: (FileSystem workingDirectory / fileName) fullName
]

{ #category : 'initialization' }
AIAHistory class >> setHistory: idName to: hist [
	Histories ifNil: [ Histories := Dictionary new ].
	Histories at: idName put: hist
]

{ #category : 'as yet unclassified' }
AIAHistory class >> writeCurrentTo [
	"Serialises the current history to the specified file name."
	| fileName timePart |
	timePart := (DateAndTime now asString copyUpTo: $.)copyReplaceAll: ':' with: '_'.
	
	FLSerializer 
		serialize: self currentHistory 
		toFileNamed: (FileSystem workingDirectory / fileName) fullName
]

{ #category : 'accessing' }
AIAHistory >> addPreHistory: pre [
	"Adds a previous history instance to the collection of pre-histories"
	preHistories add: pre.
]

{ #category : 'accessing' }
AIAHistory >> api [
	"Returns the API instance, creating a new AilienApi provider if none exists"
	api ifNil: [ ^ AilienApi provider new ].
	^ api
]

{ #category : 'accessing' }
AIAHistory >> api: anObject [

	api := anObject
]

{ #category : 'accessing' }
AIAHistory >> apiMessageList [
	| assocKey messageList all |
	assocKey := [ :assoc | '[', assoc key,'] ',  assoc value ].
	messageList := OrderedCollection new.
	all := self selfAndPreHistories.
   all do: [ :hist | hist firstRoles do: [ :assoc | 
				messageList add: 'user' -> (assocKey value: assoc) ]].
	all do: [ :hist | hist messages do: [ :m | messageList add: m ]].
	all do: [ :hist | hist lastRoles do: [ :assoc | 
				messageList add: 'user' -> (assocKey value: assoc) ]].
	^ messageList
]

{ #category : 'initialization' }
AIAHistory >> assistant: aString [
	messages add: 'assistant' -> aString
]

{ #category : 'context roles' }
AIAHistory >> background [
	^ (firstRoles select: [ :role |  role key = 'background']) 
		collect: [ :role | role value ]
]

{ #category : 'context roles' }
AIAHistory >> background: string [
	firstRoles add: 'background' -> string 
]

{ #category : 'initialization' }
AIAHistory >> chatHistory [
	"Returns formatted chat history excluding system message, with numbered entries for user and assistant messages. Preserves chronological order."
	| historyText counter |
	historyText := WriteStream on: ''.
	counter := 1.
	self apiMessageList do: [ :item | 
		historyText << '## ['<< counter asString << '] ' << item key << String cr
			<< item value << String cr << String cr.
			counter := counter + 1.
		 ].
	^ historyText contents
]

{ #category : 'accessing' }
AIAHistory >> firstRoles [
	^ firstRoles
]

{ #category : 'ollama models' }
AIAHistory >> getResponse [
	"This method initiates an AI process to retrieve a response, displaying progress and handling interruptions."
	self apiMessageList ifEmpty: [ 
		self assistant: 'No answer, as I was not asked'.
		^ self ].
	[ :job | | aiProcess |
		aiProcess := [ self api history: self; loadResponse ] newProcess.
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
AIAHistory >> initialize [
	super initialize.
	"api := AilienApi provider".
	preHistories := OrderedCollection new.
	messages := OrderedCollection new.
	firstRoles := OrderedCollection new.
	lastRoles := OrderedCollection new.
]

{ #category : 'accessing' }
AIAHistory >> lastRoles [
	^ lastRoles 
]

{ #category : 'accessing' }
AIAHistory >> messages [
	^ messages 
]

{ #category : 'accessing' }
AIAHistory >> response [
	(messages last key = 'assistant')
		ifTrue: [ ^ messages last value ]
		ifFalse: [ ^ nil ]
]

{ #category : 'context roles' }
AIAHistory >> responseType [
	^ (lastRoles select: [ :role |  role key = 'responseType']) 
		collect: [ :role | role value ]
]

{ #category : 'context roles' }
AIAHistory >> responseType: string [
	lastRoles add: 'responseType' -> string 
]

{ #category : 'accessing' }
AIAHistory >> selfAndPreHistories [
	| pres |
	pres := OrderedCollection new.
	preHistories do: [ :preModel |
		pres addAll: preModel selfAndPreHistories.
		 ].
	pres add: self.
	^ pres
]

{ #category : 'context roles' }
AIAHistory >> system [
	^ (firstRoles select: [ :role |  role key = 'system']) 
		collect: [ :role | role value ]
	

]

{ #category : 'context roles' }
AIAHistory >> system: string [
	firstRoles add: 'system' -> string 
]

{ #category : 'accessing' }
AIAHistory >> user: aString [
	messages add: 'user' -> aString
]
