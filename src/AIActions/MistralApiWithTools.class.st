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
	#name : 'MistralApiWithTools',
	#superclass : 'MistralApi',
	#instVars : [
		'toolExecutor'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'tools support' }
MistralApiWithTools >> bodyForEntityWithPrompt [
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
MistralApiWithTools >> browseImplementorsTool [
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> 'browseImplementors'.
            'description' -> 'Returns list of classes implementing a given selector.'.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'selector' -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> 'Method selector to find implementors of'
                    })
                }).
                'required' -> #('selector')
            })
        })
    }
]

{ #category : 'tools support' }
MistralApiWithTools >> evaluateExpressionTool [
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> 'evaluatePharoExpression'.
            'description' -> 'Evaluates Pharo Smalltalk expression. Returns printString of result. Handles arithmetic, object creation, collection operations.'.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'expression' -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> 'Pharo expression to evaluate'
                    })
                }).
                'required' -> #('expression')
            })
        })
    }
]

{ #category : 'tools support' }
MistralApiWithTools >> executeExpression: expr [
    [ ^ (OpalCompiler new evaluate: expr) printString ]
        on: Error
        do: [ :ex | ^ 'Error: ', ex messageText ]

]

{ #category : 'tools support' }
MistralApiWithTools >> executeGetClassInfo: className [
    | cls |
    cls := Smalltalk globals at: className asSymbol ifAbsent: [ ^ 'Class not found' ].
    ^ String streamContents: [ :s |
        s << '## ' << className << String cr.
        s << 'Slots: ' << (cls instVarNames joinUsing: ' ') << String cr.
        s << 'Comment: ' << (cls comment ifEmpty: [ 'None' ]) ]
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> executeGetWeather: aCityName [
    | url response |
    url := 'http://wttr.in/', aCityName urlEncoded, '?format=3'.
    [ response := ZnClient new get: url.
      ^ response trimBoth
    ] on: Error do: [ :ex |
        ^ 'Couldn''t fetch weather for ', aCityName, ': ', ex messageText ]
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> executeGitHubSearch: aQuery [
    | response url |
    "Vi tvinger Pharo/Smalltalk filteret her for at undgå støj"
    url := 'https://api.github.com/search/repositories?q=', 
           aQuery urlEncoded, 
           '+language:smalltalk'.
    
    response := ZnClient new
        get: url.
    
    ^ String streamContents: [ :s | | items |
        items := (STONJSON fromString: response) at: 'items' ifAbsent: [ #() ].
        items isEmpty ifTrue: [ s << 'Ingen resultater fundet.' ].
        (items first: (5 min: items size)) do: [ :repo |
            s << '- ' << (repo at: 'full_name') << ': ' << (repo at: 'description') << String cr ] ]
]

{ #category : 'tools support' }
MistralApiWithTools >> executeImplementors: selector [
    | implementors |
    implementors := SystemNavigation default allImplementorsOf: selector asSymbol.
    implementors ifEmpty: [ ^ 'No implementors found' ].
    ^ (implementors collect: [ :m | m methodClass name ]) joinUsing: ', '
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> executeToolCalls: toolCalls [
    toolCalls do: [ :call |
        | funcName funcArgs result |
        funcName := (call at: 'function') at: 'name'.
        funcArgs := STONJSON fromString: ((call at: 'function') at: 'arguments').
        result := self executeToolNamed: funcName withArgs: funcArgs.
        messageList add: 'tool' -> (Dictionary newFrom: {
            'tool_call_id' -> (call at: 'id').
            'content' -> result }) ]
]

{ #category : 'Protocol (tools support) - 10 selector(s)' }
MistralApiWithTools >> executeToolNamed: name withArgs: args [
    name = 'evaluatePharoExpression' ifTrue: [
        ^ self executeExpression: (args at: 'expression') ].
    name = 'getClassInfo' ifTrue: [
        ^ self executeGetClassInfo: (args at: 'className') ].
    name = 'browseImplementors' ifTrue: [
        ^ self executeImplementors: (args at: 'selector') ].
    name = 'searchGitHubSmalltalk' ifTrue: [
        ^ self executeGetClassInfo: (args at: 'query') ].
    name = 'getWeather' ifTrue: [
        ^ self executeGetWeather: (args at: 'city') ].
    ^ 'Unknown tool: ', name
]

{ #category : 'testing' }
MistralApiWithTools >> extractContent: responseDict [
	"Extracts the textual content from the first message choice."
	^ ((responseDict at: 'choices') first at: 'message') at: 'content'
]

{ #category : 'tools support' }
MistralApiWithTools >> getClassInfoTool [
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> 'getClassInfo'.
            'description' -> 'Returns class comment, instance variables, and method selectors for a Pharo class.'.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'className' -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> 'Name of the Pharo class'
                    })
                }).
                'required' -> #('className')
            })
        })
    }
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> getWeatherTool [
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> 'getWeather'.
            'description' -> 'Fetches the current weather for a city in any country. '.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'city' -> (Dictionary newFrom: {
                         'type' -> 'string'.
                         'description' -> 'The city name, e.g., London'
                     })
                }).
                'required' -> #('city')
            })
        })
    }
]

{ #category : 'tools support' }
MistralApiWithTools >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item |
        item key = 'assistant'
            ifTrue: [ jsonHistory add: item value ]  "Already a dict from API"
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

{ #category : 'Protocol (tools support) - 11 selector(s)' }
MistralApiWithTools >> loadResponse: aHistory [
    | maxTurns |
    maxTurns := 5.
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

{ #category : 'printing' }
MistralApiWithTools >> printOn: aStream [
	"Prints the MistralApi instance with its current model name for debugging and logging purposes."
	aStream << 'MistralApiWithTools: ' << self model.
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> processToolCall: call [
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

{ #category : 'as yet unclassified' }
MistralApiWithTools >> responseError: parsed hist: aHistory [

	| error |
	error := parsed at: 'error'.
	aHistory assistant: 'API Error: ' , (error at: 'type') , ' - ' , (error at: 'message').
	^ self
]

{ #category : 'as yet unclassified' }
MistralApiWithTools >> searchGitHubTool [
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> 'searchGitHubSmalltalk'.
            'description' -> 'Searching for Pharo/Smalltalk projects on GitHub based on keywords.'.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    'query' -> (Dictionary newFrom: { 
                        'type' -> 'string'. 
                        'description' -> 'Search terms (e.g. "LLM", "Graphics")' 
                    })
                }).
                'required' -> #('query')
            })
        })
    }
]

{ #category : 'tools support' }
MistralApiWithTools >> toolSpecification [
    ^ {
        self evaluateExpressionTool.
        self getClassInfoTool.
        self browseImplementorsTool.
		  self searchGitHubTool.
		  self getWeatherTool.
    }
]
