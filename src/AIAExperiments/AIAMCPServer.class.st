Class {
	#name : 'AIAMCPServer',
	#superclass : 'Object',
	#instVars : [
		'teapot'
	],
	#category : 'AIAExperiments-Teacup issue',
	#package : 'AIAExperiments',
	#tag : 'Teacup issue'
}

{ #category : 'examples' }
AIAMCPServer class >> start [
    <example>
    ^ self new start
]

{ #category : 'public' }
AIAMCPServer >> errorResponse: id code: code message: msg [
    ^ Dictionary newFrom: {
        'jsonrpc' -> '2.0'.
        'id' -> id.
        'error' -> (Dictionary newFrom: {
            'code' -> code.
            'message' -> msg }) }
]

{ #category : 'public' }
AIAMCPServer >> handleRequest: body [
    | method id |
    method := body at: 'method'.
    id := body at: 'id' ifAbsent: [ nil ].
    
    method = 'initialize' ifTrue: [ ^ self respondTo: id with: self initializeResult ].
    method = 'tools/list' ifTrue: [ ^ self respondTo: id with: self toolsListResult ].
    method = 'tools/call' ifTrue: [ 
        ^ self respondTo: id with: (self toolsCallResult: (body at: 'params')) ].
    
    ^ self errorResponse: id code: -32601 message: 'Method not found'
]

{ #category : 'public' }
AIAMCPServer >> initializeResult [
    ^ Dictionary newFrom: {
        'protocolVersion' -> '2024-11-05'.
        'capabilities' -> (Dictionary newFrom: {
            'tools' -> Dictionary new }).
        'serverInfo' -> (Dictionary newFrom: {
            'name' -> 'pharo-mcp'.
            'version' -> '1.0.0' }) }
]

{ #category : 'public' }
AIAMCPServer >> respondTo: id with: result [
    ^ Dictionary newFrom: {
        'jsonrpc' -> '2.0'.
        'id' -> id.
        'result' -> result }
]

{ #category : 'public' }
AIAMCPServer >> start [
    teapot := Teapot on.
    teapot POST: '/mcp' -> [ :req |
        | body response |
        body := STONJSON fromString: req body string.
        response := self handleRequest: body.
        TeaResponse ok
            body: (STONJSON toString: response);
            headerName: 'Content-Type' value: 'application/json';
            yourself ].
    teapot output: #text.
    teapot start.
    ^ teapot
]

{ #category : 'public' }
AIAMCPServer >> toolsCallResult: params [
    | toolName args result toolResult|
    toolName := params at: 'name'.
    args := params at: 'arguments'.
    
    result := AilienApiTool toolList 
        detect: [ :toolClass | toolClass new name = toolName ]
        ifNone: [ ^ Dictionary newFrom: {
            'content' -> { Dictionary newFrom: {
                'type' -> 'text'.
                'text' -> ('Unknown tool: ', toolName) } }.
            'isError' -> true } ].
    
    toolResult := result new executeTool: args.
    
    ^ Dictionary newFrom: {
        'content' -> { Dictionary newFrom: {
            'type' -> 'text'.
            'text' -> toolResult asString } } }
]

{ #category : 'public' }
AIAMCPServer >> toolsListResult [
    | tools |
    tools := AilienApiTool toolList collect: [ :toolClass |
        | t func params |
        t := toolClass new evaluateTool.
        func := t at: 'function'.
        params := func at: 'parameters'.
        Dictionary newFrom: {
            'name' -> (func at: 'name').
            'description' -> (func at: 'description').
            'inputSchema' -> params } ].
    ^ Dictionary newFrom: { 'tools' -> tools asArray }
]
