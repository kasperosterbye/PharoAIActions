"
# Class Comment for AilienApiTool

# AilienApiTool

A tool for interacting with AI APIs in a structured way.

## Key Features

- **Tool Configuration**: Manages API tool configurations including name and required parameters
- **Tool Evaluation**: Converts tool descriptions into a standardized dictionary format
- **Tool Execution**: Handles the execution of API tools with proper argument passing

## Example Usage

```smalltalk
""Create a new tool""
tool := AilienApiTool new
    name: 'weather_check';
    required: 'location'.

""Evaluate the tool with descriptions""
config := tool evaluateTool: {
    'Check the current weather'.
    'The city name to check weather for'
}.

""Execute the tool with arguments""
tool executeTool: (Dictionary with: 'location' -> 'Paris').
```

## Key Methods

- `name` - Returns the tool's name
- `required` - Returns the required parameter
- `evaluateTool:` - Converts tool descriptions to a function dictionary
- `executeTool:` - Runs the tool with provided arguments

This class provides a bridge between AI tool definitions and their execution, making it easier to work with API-based tools in a structured manner.
```
"
Class {
	#name : 'AilienApiTool',
	#superclass : 'Object',
	#instVars : [
		'name',
		'required'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
AilienApiTool >> evaluateTool: descs [
	"Evaluates the tool with the given descriptions and returns a dictionary representation of the tool's configuration."
	| desc desc1|
	desc := descs first.
	desc1 := descs second.
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> name.
            'description' -> desc.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    required -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> desc1
                    })
                }).
                'required' -> {required} 
            })
        })
    }
]

{ #category : 'initialization' }
AilienApiTool >> executeTool: args [
	"Executes the tool with the provided arguments and logs the action to the Transcript."
	Transcript << self class name asString << ': ' << (args values first) << String cr.
]

{ #category : 'accessing' }
AilienApiTool >> name [
	"Returns the name of the tool"
	^ name
]

{ #category : 'accessing' }
AilienApiTool >> required [
	"Returns the required parameter for the tool"
	^ required
]
