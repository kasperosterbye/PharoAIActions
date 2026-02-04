"
# Class Comment for MistralApiWithTools

The `MistralApiWithTools` class extends the `MistralApi` class to integrate tool execution capabilities with AI interactions. This class is designed to handle AI responses that include tool calls, execute those tools, and manage the conversation history by incorporating tool results. It supports various tools such as evaluating Pharo Smalltalk expressions, retrieving class information, browsing implementors of selectors, and searching GitHub for Smalltalk projects.

## Key Features

- **Tool Execution**: The class can execute tools based on AI responses, such as evaluating Pharo expressions, retrieving class information, and searching GitHub.
- **Conversation Management**: It manages the conversation history, including tool calls and their results, ensuring a coherent interaction flow.
- **Error Handling**: The class includes robust error handling to manage API errors and tool execution errors gracefully.
- **Tool Specification**: It provides specifications for various tools, including their names, descriptions, and parameters, which are used to guide the AI in making appropriate tool calls.

## Methods

- **loadResponse: aHistory**: Loads the AI response, processes tool calls, and updates the conversation history.
- **searchGitHubTool**: Provides the tool specification for searching GitHub for Smalltalk projects.
- **executeGitHubSearch: aQuery**: Executes a GitHub search query and returns the results.
- **executeToolCalls: toolCalls**: Executes a list of tool calls and updates the conversation history with the results.
- **processToolCall: call**: Processes a single tool call, executes the corresponding tool, and returns the result.
- **responseError: parsed hist: aHistory**: Handles API errors by updating the conversation history with error messages.
- **printOn: aStream**: Prints the MistralApiWithTools instance with its current model name for debugging and logging purposes.
- **extractContent: responseDict**: Extracts the textual content from the first message choice in the response dictionary.
- **bodyForEntityWithPrompt**: Creates the HTTP request body for AI API calls, including the conversation history and tool specifications.
- **browseImplementorsTool**: Provides the tool specification for browsing implementors of a given selector.
- **evaluateExpressionTool**: Provides the tool specification for evaluating Pharo Smalltalk expressions.
- **executeExpression: expr**: Executes a Pharo Smalltalk expression and returns the result.
- **executeGetClassInfo: className**: Retrieves class information for a given class name.
- **executeImplementors: selector**: Retrieves the list of classes implementing a given selector.
- **executeToolNamed: name withArgs: args**: Executes a tool with the given name and arguments.
- **getClassInfoTool**: Provides the tool specification for retrieving class information.
- **jsonHistory**: Converts the message list into a JSON array of role-content dictionaries.
- **toolSpecification**: Returns the specifications for the available tools.

This class is essential for integrating AI interactions with tool execution in Pharo, providing a seamless and powerful user experience.
"
Class {
	#name : 'OllamaApiWithTools',
	#superclass : 'OllamaApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'tools support' }
OllamaApiWithTools >> bodyForEntityWithPrompt [
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
OllamaApiWithTools >> executeToolNamed: name withArgs: args [
	AilienApiTool subclasses do: [ :tool | 
		| instance |
		instance := tool new.
		instance name = name ifTrue:[
			^ instance executeTool: args
			] ].
    ^ 'Unknown tool: ', name
]

{ #category : 'tools support' }
OllamaApiWithTools >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item |
			"Transcript 
					<< 'JSON key: ' << item key 
					<< ' Value: ' << (item value asString 
							copyFrom: 1 
							to: (60 min: item value asString  size)) << String lf."
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
OllamaApiWithTools >> loadResponse: aHistory [
    | maxTurns |
    maxTurns := 10.
    1 to: maxTurns do: [ :turn |
        | rawResponse parsed message toolCalls |
        rawResponse := self buildZnClientWithHeaders.
        rawResponse := rawResponse post; contents.
        parsed := STONJSON fromString: rawResponse.
		  (parsed includesKey: 'error') ifTrue: [ ^ self responseError: parsed hist: aHistory ].
        message := parsed at: 'message'.
        toolCalls := message at: 'tool_calls' ifAbsent: [ nil ].
        toolCalls ifNil: [
            aHistory assistant: (message at: 'content') from: self.
            ^ self ].
        "Add assistant's tool request to history"
        messageList add: 'assistant' -> message.

        "Execute each tool and add results"
		  toolCalls do: [ :call | messageList add: (self processToolCall: call) ] ]
]

{ #category : 'tools support' }
OllamaApiWithTools >> printOn: aStream [
	"Prints the MistralApi instance with its current model name for debugging and logging purposes."
	aStream << 'OllamaApiWithTools: ' << self model.
]

{ #category : 'tools support' }
OllamaApiWithTools >> processToolCall: call [
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

{ #category : 'tools support' }
OllamaApiWithTools >> responseError: parsed hist: aHistory [

	| error |
	error := parsed at: 'error'.
	aHistory assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message') from: self.
	^ self
]

{ #category : 'tools support' }
OllamaApiWithTools >> toolSpecification [
	| all |
	all := AilienApiTool subclasses collect: [ :tool |  tool new evaluateTool ].
   ^ all 
]
