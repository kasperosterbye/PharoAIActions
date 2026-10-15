Class {
	#name : 'AilienApiTool',
	#superclass : 'Object',
	#instVars : [
		'name',
		'required'
	],
	#category : 'AIActions-AIApiTool',
	#package : 'AIActions',
	#tag : 'AIApiTool'
}

{ #category : 'trait tools support' }
AilienApiTool class >> executeToolNamed: aName withArgs: args [
    "Find and execute a registered tool by name, returning its result
    without requiring an LLM or conversation history."

    self toolList do: [ :toolClass |
        | tool |
        tool := toolClass new.
        tool name = aName ifTrue: [
            ^ tool executeTool: args ] ].

    ^ 'Unknown tool: ', aName
]

{ #category : 'access' }
AilienApiTool class >> toolList [
	"Returns a list of API tool classes used for various functionalities"
	| list |
	"list := self subclasses."
	list := {
		        ApiToolClassInfo.
		        ApiToolExpression.
		        ApiToolGetWeather.
		        ApiToolGitHub.
		        ApiToolTextFromImage.
		        ApiToolWebReader.
		        ApiToolDefineClass.
		        ApiToolCompileMethod }.
	^ list
]

{ #category : 'evaluating' }
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

{ #category : 'evaluating' }
AilienApiTool >> evaluateToolDescription: desc properties: propsDict required: requiredNames [
	"Generic variant of evaluateTool:. propsDict maps a parameter name to either a description String (type string) or to an Array {type. description}. requiredNames is a collection of required parameter names."
	| properties |
	properties := Dictionary new.
	propsDict keysAndValuesDo: [ :pname :spec |
		properties at: pname put: (spec isString
			ifTrue: [ Dictionary newFrom: { 'type' -> 'string'. 'description' -> spec } ]
			ifFalse: [ Dictionary newFrom: { 'type' -> spec first. 'description' -> spec second } ]) ].
	^ Dictionary newFrom: {
		'type' -> 'function'.
		'function' -> (Dictionary newFrom: {
			'name' -> name.
			'description' -> desc.
			'parameters' -> (Dictionary newFrom: {
				'type' -> 'object'.
				'properties' -> properties.
				'required' -> requiredNames asArray }) }) }
]

{ #category : 'initialization' }
AilienApiTool >> executeTool: args [
	"Executes the tool with the provided arguments and logs the action to the Transcript."
	Transcript << self class name asString << ': ' << (args values first) << String lf.
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
