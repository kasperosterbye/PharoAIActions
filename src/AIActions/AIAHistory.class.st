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
		'title',
		'api',
		'preHistories',
		'messages',
		'firstRoles',
		'lastRoles',
		'responseHearderLevel'
	],
	#classVars : [
		'Histories'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
AIAHistory class >> background01 [
	^ '
I am Kasper Østerbye, a retired computer science professor, specializes in programming language design, runtime systems, and AI integration. With experience in machine code for PDP-12, Forth on PDP-10, Smalltalk, Simula, Beta, and Interlisp, he now focuses on Pharo for its tight language-runtime integration. Kasper builds the full chain from application (Pharo) to raw JSON LLM calls, experimenting with message roles, metadata, non-linear conversation graphs, parallel branches, and custom context injection to shape LLM interaction architecture.
He views programming as cognition, exploring shared principles between runtime architecture and consciousness. His research investigates the boundaries of dialogue-based intelligence through precise, controlled prompt experiments, not for productivity but to understand and challenge intelligence structuring. Kasper interacts with the model as an "AIlien," expecting independent, non-human reasoning. He blends technical rigor with dry humor, valuing clarity, curiosity, and playful exploration of complexity.

[RESPONSESTYLE]
Responses must be concise (no more than ~20 lines), information-dense, and analytically precise.  
No emojis or tables are ever allowed.  
Clarity, brevity, and technical focus are essential.

Quite another matter - I can''t read, and need a computer to convert your answer into something I can ask it to read. So 1) Please give short (20 * 72 characters) answers, and 2) avoid tables. I basically understood what you wrote as an explanation, so the intro and conclusion are the only things of interest. Does that make sense?'
]

{ #category : 'as yet unclassified' }
AIAHistory class >> clearHistories [
	Histories := OrderedCollection new.
]

{ #category : 'as yet unclassified' }
AIAHistory class >> dDiscussion [
	<example>
	| dDiscussion index |
	dDiscussion := 'dDiscussion'.
	index := Histories findFirst: [ :hist | hist title =  dDiscussion].
	index = 0 ifTrue: [ 
		| newDiscussion |
		self qPrefix.
		newDiscussion := self new.
		newDiscussion 
			title: dDiscussion;
			addPreHistory: self qPrefix; 
			background: self background01.
		index := Histories size].
	^ Histories at: index.
	 
]

{ #category : 'initialization' }
AIAHistory class >> histories [
	^ Histories
]

{ #category : 'initialization' }
AIAHistory class >> historyAt: id [
	^ Histories detect: [ :hist | hist title = id ]
]

{ #category : 'Protocol (as yet unclassified) - 7 selector(s)' }
AIAHistory class >> qPrefix [
	"Returns the qPrefix history, creating it if necessary, with system text and response type"
	<example>
	^ Histories 
		detect: [ :hist | hist title = 'qPrefix' ]
		ifNone: [
			self new
				title: 'qPrefix';
				system: self qPrefixSystemText;
				yourself] 
]

{ #category : 'as yet unclassified' }
AIAHistory class >> qPrefixSystemText [
	^ 'You are a Pharo14 Smalltalk expert. Pharo14 is the last version of Pharo. In Pharo a typical class is written as: 
	SuperclassName << #SubclassName
	slots: { #var1 . #var2 . #var3 };
	sharedVariables: { #GlobalVar1 . #GlobalVar2 };
	package: ''APackageName''.
	In Pharo and Smalltalk, the expression `2 + 3 * 4` is evaluated from left to right due to the uniform precedence of all binary messages. This means the addition is performed first, followed by the multiplication. Therefore, the expression is evaluated as `(2 + 3) * 4`, resulting in `20`.'
]

{ #category : 'writing' }
AIAHistory class >> readCurrent [
	"Serialises the current history to the specified file name."

	| fileName discussion index |
	[
		fileName := FileSystem workingDirectory / '..' / '..'
		            / 'dDiscussion.file'.
		discussion := FLMaterializer materializeFromFileNamed:
			              fileName fullName.
		index := Histories findFirst: [ :hist | hist title = 'dDiscussion' ].
		index = 0 ifFalse: [ (Histories at: index) title: 'old_dDiscussion'].
		Histories at: Histories size put: discussion ]
		on: Error
		do: [ self error: 'No file available' ]
]

{ #category : 'writing' }
AIAHistory class >> writeCurrent [
	| discussion fileName |
	discussion := Histories detect: [ :hist | hist title = 'dDiscussion' ].
	fileName := FileSystem workingDirectory / '..' / '..' / 'dDiscussion.file'. 
	FLSerializer 
		serialize: discussion 
		toFileNamed: fileName fullName
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
	"Returns the API instance, creating a new AilienApi provider if none exists"
	api := anObject
]

{ #category : 'accessing' }
AIAHistory >> apiMessageList [
	"Returns a list of API messages including user and assistant messages from current and pre-histories, formatted with role labels"
	| assocKey messageList all |
	assocKey := [ :assoc | '[', assoc key,'] ',  assoc value ].
	messageList := OrderedCollection new.
	all := self selfAndPreHistories.
   all do: [ :hist | hist firstRoles do: [ :assoc | 
				messageList add: 'user' -> (assocKey value: assoc) ]].
	all do: [ :hist | hist getMessages do: [ :m | messageList add: m ]].
	all do: [ :hist | hist lastRoles do: [ :assoc | 
				messageList add: 'user' -> (assocKey value: assoc) ]].
	^ messageList
]

{ #category : 'accessing' }
AIAHistory >> assistant: aString [
	"Adds an assistant message to the messages collection after sanitising the input string."
	messages add: 'assistant' -> (self sanitizedResonse: aString)
]

{ #category : 'accessing' }
AIAHistory >> assistant: aString from: ailienInfo [
	"Adds an assistant message to the messages collection after sanitising the input string."
	messages add: 'assistant' -> (self sanitizedResonse: aString)
]

{ #category : 'context roles' }
AIAHistory >> background [
	"Returns the background roles from the first roles collection, collecting their values."
	^ (firstRoles select: [ :role |  role key = 'background']) 
		collect: [ :role | role value ]
]

{ #category : 'context roles' }
AIAHistory >> background: string [
	"Adds a background role to the first roles collection with the given string"
	firstRoles add: 'background' -> string 
]

{ #category : 'accessing' }
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

{ #category : 'Protocol (accessing) - 17 selector(s)' }
AIAHistory >> getMessages [
	| ailienMessageList |
	ailienMessageList := messages collect: [ :element |
		element key = 'assistant'
			ifFalse: [ element ]
			ifTrue: [ element key -> element value  ]
		 ].
	^ ailienMessageList 
]

{ #category : 'llm call' }
AIAHistory >> getResponse [
	"This method initiates an AI process to retrieve a response, displaying progress and handling interruptions."
	self apiMessageList ifEmpty: [ 
		self assistant: 'No answer, as I was not asked'.
		^ self ].
	[ :job | | aiProcess secs |
		aiProcess := [ 
				self api messageList: self apiMessageList; loadResponse: self. 
			] newProcess.
		aiProcess priority: Processor userBackgroundPriority. 
		aiProcess resume.
		SystemProgressMorph uniqueInstance position: 10@20.
		job interruptBlock: [
			aiProcess terminate.
			self assistant: 'AI based response Terminated'.
			^ self
		].
		secs := self api responseWaitingInSecs.
		1 to: secs * 10 do: [:each |
			job
				progress: ((1/(secs * 10)) * each) ;
				title: ( self api asString, ' working {1} of {2}' 
					format: {(each/10) asFloat printString. secs}).
				self response ifNil: [100 milliSeconds wait].
		].
	] asJob run.
]

{ #category : 'Protocol (adding) - 1 selector(s)' }
AIAHistory >> includeInHistories [
	"Adds the current history instance to the shared Histories collection and manages its size by removing the oldest untitled instance if the maximum number of untitled instances is exceeded."
	| firstNoTitle noOfNoTitle maxNoTitles |
	Histories ifNil: [ self class clearHistories ].
	Histories add: self.
	firstNoTitle := 0.
	noOfNoTitle := 0.
	maxNoTitles := 25.
	1 to: Histories size do: [ :index |
		(Histories at: index) title ifNil: [ 
			firstNoTitle > 0 ifFalse: [ firstNoTitle := index ].
			noOfNoTitle := noOfNoTitle + 1.
			 ]
		 ].
	noOfNoTitle > maxNoTitles ifTrue: [ 
		Histories removeAt: firstNoTitle.
		 ]
	
]

{ #category : 'initialization' }
AIAHistory >> initialize [
	super initialize.
	preHistories := OrderedCollection new.
	messages := OrderedCollection new.
	firstRoles := OrderedCollection new.
	lastRoles := OrderedCollection new.
	title := nil.
	self includeInHistories 
]

{ #category : 'accessing' }
AIAHistory >> lastRoles [
	^ lastRoles 
]

{ #category : 'accessing' }
AIAHistory >> messages [
	^ messages 
]

{ #category : 'printing' }
AIAHistory >> printOn: stream [
	"Prints the title on the stream if available, otherwise prints the prompt."
	title  
		ifNotNil: [ stream << title ]
		ifNil: [ stream << self printPrompt ] 
]

{ #category : 'printing' }
AIAHistory >> printPrompt [
	(messages isNotNil and: [ messages size > 1 ])
		ifTrue: [ ^ messages first value maxFirst: 20  ] 
		ifFalse: [ ^ '> No prompt' ]
]

{ #category : 'accessing' }
AIAHistory >> response [
	(messages last key = 'assistant')
		ifTrue: [ ^ messages last value ]
		ifFalse: [ ^ nil ]
]

{ #category : 'accessing' }
AIAHistory >> responseHearderLevel: level [
	responseHearderLevel := level
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

{ #category : 'context roles' }
AIAHistory >> sanitizedResonse: response [
	^ self sanitizedResonse: response forHeaderLevel: responseHearderLevel 
]

{ #category : 'context roles' }
AIAHistory >> sanitizedResonse: response forHeaderLevel: level [
	"Sanitises response by stripping code blocks and promoting Markdown headers to match given level"

	| sani lines headerLines minHeaderLevel headingLevel diff headers |
	sani := response.
	(response beginsWith: '```') ifTrue: [ sani := String cr join: response lines allButFirst allButLast ].
	level ifNotNil: [
			headers := { '# '. '## '. '### '. '#### '. '##### '. '###### ' }.
			lines := sani lines.
			headerLines := OrderedCollection new.
			minHeaderLevel := 10.
			1 to: lines size do: [ :idx |
					((lines at: idx) size > 0 and: [ (lines at: idx) first = $# ]) ifTrue: [
							headerLines add: idx.
							headingLevel := (lines at: idx) findString: ' '.
							minHeaderLevel := minHeaderLevel min: headingLevel - 1 ] ].
			diff := level - minHeaderLevel.
			diff > 0 ifTrue: [
					headerLines do: [ :lineNo |
							| l h1 h2 res|
							l :=  ((lines at: (headerLines at: lineNo)) findString: ' ') - 1.
							h1 := headers at: l.
							h2 := headers at: (l + diff min: 6).
							res := (lines at: lineNo) copyReplaceAll: h1 with: h2.
							lines at: lineNo put: res ] ].
			sani := String cr join: lines ].
	^ sani
]

{ #category : 'accessing' }
AIAHistory >> selfAndPreHistories [
	"Returns an ordered collection of all pre histories and the current instance."
	| pres |
	pres := Set new.
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
AIAHistory >> title [

	^ title
]

{ #category : 'accessing' }
AIAHistory >> title: anObject [

	title := anObject
]

{ #category : 'accessing' }
AIAHistory >> user: aString [
	messages add: 'user' -> aString
]
