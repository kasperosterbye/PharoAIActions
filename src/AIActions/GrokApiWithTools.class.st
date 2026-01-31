"
# Class comment for GrokApiWithTools

GrokApiWithTools extends GrokApi to support tool use in AI conversations. It enables AI models to interact with external tools by:

1. Defining tool specifications in JSON format
2. Processing tool calls from AI responses
3. Executing tools and adding results to conversation history

Example usage:
```smalltalk
api := GrokApiWithTools new.
api user: 'What is the weather in London?'.
api loadResponse: api messageList.
```

Key features:
- Automatically includes tool definitions in API requests
- Handles tool execution and response formatting
- Maintains conversation history with tool interactions

The class works with AilienApiTool subclasses to provide the actual tool implementations.
"
Class {
	#name : 'GrokApiWithTools',
	#superclass : 'GrokApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'tools support' }
GrokApiWithTools >> bodyForEntityWithPrompt [
    | requestDictionary |
    requestDictionary := Dictionary newFrom: {
        'model' -> self model.
        'messages' -> self jsonHistory.
        'tools' -> self toolSpecification.
        'temperature' -> 0.0.
        'stream' -> false
    }.
    ^ ZnEntity json: (STONJSON toString: requestDictionary)
]

{ #category : 'tools support' }
GrokApiWithTools >> executeToolNamed: name withArgs: args [
	AilienApiTool subclasses do: [ :tool | 
		| instance |
		instance := tool new.
		instance name = name ifTrue:[
			^ instance executeTool: args
			] ].
    ^ 'Unknown tool: ', name
]

{ #category : 'tools support' }
GrokApiWithTools >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item |
			Transcript 
					<< 'JSON key: ' << item key 
					<< ' Value: ' << (item value asString 
							copyFrom: 1 
							to: (40 min: item value asString  size)) << String lf.
        item key = 'assistant'
            ifTrue: [ 
                "Handle both dict (from tool loop) and string (from aHistory assistant:)"
                item value isDictionary
                    ifTrue: [ jsonHistory add: item value ]
                    ifFalse: [ jsonHistory add: (Dictionary newFrom: {
                        'role' -> 'assistant'.
                        'content' -> item value }) ] ]
            ifFalse: [
                item key = 'tool'
                    ifTrue: [ jsonHistory add: (Dictionary newFrom: {
                        'role' -> 'tool'.
                        'tool_call_id' -> (item value at: 'tool_call_id').
                        'content' -> (item value at: 'content') }) ]
                    ifFalse: [ jsonHistory add: (Dictionary newFrom: {
                        'role' -> item key.
                        'content' -> item value }) ] ] ].
    ^ jsonHistory asArray
]

{ #category : 'tools support' }
GrokApiWithTools >> loadResponse: aHistory [
    | maxTurns |
    maxTurns := 10.
    1 to: maxTurns do: [ :turn |
        | rawResponse parsed message toolCalls |
        rawResponse := self buildZnClientWithHeaders.
        rawResponse := rawResponse post; contents.
        parsed := STONJSON fromString: rawResponse.
		  (parsed includesKey: 'error') ifTrue: [ ^ self responseError: parsed hist: aHistory ].

        message := (parsed at: 'choices') first at: 'message'.
        toolCalls := message at: 'tool_calls' ifAbsent: [ nil ].
        toolCalls ifNil: [
            aHistory assistant: (message at: 'content').
            ^ self ].
        "Add assistant's tool request to history"
        messageList add: 'assistant' -> message.

        "Execute each tool and add results"
		  toolCalls do: [ :call | messageList add: (self processToolCall: call) ] ]
]

{ #category : 'tools support' }
GrokApiWithTools >> printOn: aStream [
	"Prints the MistralApi instance with its current model name for debugging and logging purposes."
	aStream << 'GrokApiWithTools: ' << self model.
]

{ #category : 'tools support' }
GrokApiWithTools >> processToolCall: call [
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

{ #category : 'tools support' }
GrokApiWithTools >> responseError: parsed hist: aHistory [

	| error |
	error := parsed at: 'error'.
	aHistory assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message').
	^ self
]

{ #category : 'tools support' }
GrokApiWithTools >> toolSpecification [
	| all |
	all := AilienApiTool subclasses collect: [ :tool |  tool new evaluateTool ].
   ^ all 
]
