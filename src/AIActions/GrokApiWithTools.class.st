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
	#traits : 'AilienTool',
	#classTraits : 'AilienTool classTrait',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'tools support' }
GrokApiWithTools >> jsonHistory [
    | jsonHistory |
    jsonHistory := OrderedCollection new.
    messageList do: [ :item | self addJsonHistory: jsonHistory for: item ].
    ^ jsonHistory asArray
]

{ #category : 'tools support' }
GrokApiWithTools >> loadResponse: aHistory [

	self traitLoadResponse: aHistory  
]

{ #category : 'tools support' }
GrokApiWithTools >> printOn: aStream [
	aStream << 'GrokApiWithTools: ' << self model.
]

{ #category : 'tools support' }
GrokApiWithTools >> znClientEntity [
	"Returns the body of an entity with a given prompt by sending a POST request to the Ollama API."
	^ super znClientEntity union:  {
        'tools' -> self toolSpecification.
    } .
]
