Class {
	#name : 'Claude2Api',
	#superclass : 'AilienApiWithTools',
	#classInstVars : [
		'lastKeyNumber'
	],
	#category : 'AIAZipArchive-AIApiArhive',
	#package : 'AIAZipArchive',
	#tag : 'AIApiArhive'
}

{ #category : 'accessing' }
Claude2Api class >> apiGenerateUrl [ 
	^ 'https://api.anthropic.com/v1/messages'
]

{ #category : 'AI models' }
Claude2Api class >> claudeKey [
	| fileName |
	lastKeyNumber ifNil: [ lastKeyNumber := 0 ].
	lastKeyNumber := lastKeyNumber + 1.
	lastKeyNumber > 2 ifTrue: [ lastKeyNumber := 0 ].
	fileName := '../../claudecode0{1}.txt' format: { lastKeyNumber }.
	^ (FileSystem disk workingDirectory / fileName ) readStream contents trimBoth.
]

{ #category : 'AI models' }
Claude2Api class >> modelNames [
	"returns an array with one item per model."
	"Look at https://docs.anthropic.com/en/docs/about-claude/models/overview to see the list"
	
	^ #(
	'claude-sonnet-4-20250514' 
	'claude-3-haiku-20240307'
	'claude-haiku-4-5-20251001' 
	'claude-opus-4-6'
	'claude-opus-4-5-20251101') 
]

{ #category : 'AI models' }
Claude2Api class >> znClientHeaders: jsonPrompt [
	jsonPrompt
		headerAt: 'x-api-key' put: self claudeKey;
		headerAt: 'anthropic-version' put: '2023-06-01';
		headerAt: 'content-type' put: 'application/json'.
]

{ #category : 'adding' }
Claude2Api >> continueToolCall: parsed orWrite: aHistory [
	"Continues tool calls writes assistant content or handles api errors"

	| message content |
	(parsed includesKey: 'error') ifTrue: [ 
		self responseError: parsed hist: aHistory.
		^ nil ].
	message := parsed at: 'content'.
	content := message select: [ :block | (block at: 'type') = 'tool_use' ].
	content isEmpty ifTrue: [
			aHistory assistant: ((message detect: [ :b | (b at: 'type') = 'text' ]) at: 'text'). " from: self"
			^ nil ].
	^ message 
]

{ #category : 'adding' }
Claude2Api >> handleToolCall: toolCall [
    (toolCall select: [ :call | (call at: 'type') = 'tool_use' ])
        do: [ :call | self messageList add: (self processToolCall: call) ]
]

{ #category : 'adding' }
Claude2Api >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item |
        item value isDictionary
            ifTrue: [ jsonHistory add: item value ]
            ifFalse: [
                jsonHistory add: (Dictionary newFrom: {
                    'role' -> item key.
                    'content' -> item value }) ] ].
    ^ jsonHistory asArray
]

{ #category : 'adding' }
Claude2Api >> loadResponse: aHistory [

	self traitLoadResponse: aHistory  
]

{ #category : 'adding' }
Claude2Api >> messageListAddResponse: response andTool: toolCall [
	self messageList add: 'assistant' -> (Dictionary newFrom: {
				 ('role' -> 'assistant').
				 ('content' -> (response at: 'content')) })
]

{ #category : 'adding' }
Claude2Api >> processToolCall: call [
    | result encoded|
    result := self 
        executeToolNamed: (call at: 'name')
        withArgs: (call at: 'input').
    encoded := 'user' -> (Dictionary newFrom: {
        'role' -> 'user'.
        'content' -> { Dictionary newFrom: {
            'type' -> 'tool_result'.
            'tool_use_id' -> (call at: 'id').
            'content' -> result } } }).
	^ encoded 
]

{ #category : 'adding' }
Claude2Api >> responseError: parsed hist: aHistory [
    | error |
    error := parsed at: 'error'.
    aHistory assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message')" from: self".
    ^ self
]

{ #category : 'accessing' }
Claude2Api >> responseOf: jsonResponse [
	"Returns the text content from the parsed Claude API JSON response by extracting the text field from the first content element in the response dictionary"
	| parsed |
	parsed := STONJSON fromString: jsonResponse.
	[ ^ (parsed at: 'content') first at: 'text'.]
		on: Error
		do: [  ^ self errorResponse: jsonResponse  ]
]

{ #category : 'adding' }
Claude2Api >> toolSpecification [
	| all |
    all := AilienApiTool subclasses collect: [ :tool |
        | openAI func params |
        openAI := tool new evaluateTool.
        func := openAI at: 'function'.
        params := func at: 'parameters'.
        Dictionary newFrom: {
            'name' -> (func at: 'name').
            'description' -> (func at: 'description').
            'input_schema' -> params } ].
	^ all
]

{ #category : 'adding' }
Claude2Api >> traitLoadResponse: aHistory [
	| maxTurns |
	maxTurns := 50.
	1 to: maxTurns do: [ :turn |
			| response toolCall |
			response := self callLLM .
			toolCall := self continueToolCall: response orWrite: aHistory. 
			toolCall ifNil: [ ^ self ].
			Transcript << '## ' << self class name asString << ': ' << turn asString << String lf.
			self messageListAddResponse: response andTool: toolCall. 
			self handleToolCall: toolCall.
			].
	^ aHistory assistant: ('API Error: tried more than the {1} allowed TOOLS calls' format: { maxTurns })
]

{ #category : 'adding' }
Claude2Api >> xx_callLLM [
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
Claude2Api >> xx_loadResponse: aHistory [

	self traitLoadResponse: aHistory  
]

{ #category : 'accessing' }
Claude2Api >> znClientBasic: jsonPrompt [

	|  entityPrompt entity foo|
	jsonPrompt
		timeout: self responseWaitingInSecs;
		url: self apiGenerateUrl.
	entity := self znClientEntity asDictionary deepCopy .
	foo := STONJSON toString: entity.
	entityPrompt := ZnEntity json: foo.
	jsonPrompt 
		entity: entityPrompt .
	
]

{ #category : 'adding' }
Claude2Api >> znClientEntity [
    ^ super znClientEntity , {
        'tools' -> self toolSpecification.
        'max_tokens' -> 4096
    }
]
