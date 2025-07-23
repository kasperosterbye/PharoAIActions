"
# Class Comment for MistralApi

## Overview

The `MistralApi` class is designed to interact with the Mistral AI API, allowing users to send prompts and receive responses from various AI models. This class handles the initialization, configuration, and communication with the Mistral API, including sending requests and processing responses.

## Key Features

- **Initialization**: The class initializes with the latest model (`codestral-latest`) by default.
- **Prompt Handling**: Users can send prompts to the API and receive responses.
- **Model Management**: The class provides methods to retrieve available models from the API and manage model configurations.
- **Error Handling**: The class includes error handling to manage exceptions that may occur during API communication.

## Methods

### Initialization

- **`initialize`**: Initializes the `MistralApi` instance with the latest model.

### Prompt Handling

- **`getResponseForPrompt:`**: Sends a user prompt to the Mistral API and returns the response. This method handles the construction of the request, sending it to the API, and processing the JSON response.
- **`bodyForEntityWithPrompt`**: Constructs the JSON body for the API request based on the user prompt.

### Model Management

- **`models`**: Retrieves a list of available Mistral models from the API and returns them as a sorted collection.
- **`models_old`**: An older version of the `models` method that returns the raw list of models from the API.
- **`modelsBy:`**: Returns an array with one item per model, based on a specified key.
- **`modelNames`**: Returns an array of model names. This method is a placeholder that currently calls the superclass method.
- **`modelNames_old`**: Returns an array of model names, including various Mistral models.

### Utility Methods

- **`responseOf:`**: Extracts the 'content' from the first 'message' in the 'choices' array of a JSON response.
- **`token`**: Returns the API token for Mistral, read from a local file.

### Printing

- **`printOn:`**: Prints a string representation of the `MistralApi` instance, including the model name.

## Usage Example

```smalltalk
| api response |
api := MistralApi new.
response := api getResponseForPrompt: 'What is the capital of France?'.
Transcript show: response; cr.
```

This example initializes the `MistralApi` class, sends a prompt to the API, and prints the response to the Transcript.

## Dependencies

- **ZnClient**: Used for making HTTP requests to the Mistral API.
- **STONJSON**: Used for parsing and constructing JSON data.

## Notes

- Ensure that the API token is correctly stored in the specified file (`../../mistralkode.txt`) for authentication.
- The class is part of the `AIActions` package and is tagged with `AIApi`.

By following this class comment, users can understand the purpose, features, and usage of the `MistralApi` class, making it easier to integrate and utilize in their projects.
"
Class {
	#name : 'MistralApi',
	#superclass : 'AilienApi',
	#instVars : [
		'messagePart'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
MistralApi class >> andreiChis [
	^ '# Interaction description
Interactions are structured like this:
1. The assistant (you) is given the current state and an action to perform.
2. The assistant;
    a. Determines what needs to be done. It consults tools as necessary and asks follow-up questions if the action is unclear. Multi-step actions require a summary of necessary steps beforehand and a user confirmation (see "Communication rules").
    b. Performs the action on the state.
    c. Outputs the new state.
3. The user:
a. checks the output state.
b. provides the current state and next action to you (returning back to step 1.).

The state is an aggregate of the components listed below, sent to you as a JSON object.

# Communication rules
- Always review the full conversation prior to answering and maintain continuity.
- Assume the user would like something concise when producing text.
- Prefer asking clarifying follow-up questions or using tools (see  the section "Tool use policy") over assumptions, especially when in doubt.
- Refuse actions that cannot be performed using your capabilities. When an action is refused, return a textual explanation of why it isn’t possible to fulfill the request.
- Similarly, give a concise description of any error you encounter on tool use or other system errors.
- Multi-step actions (i.e. those involving tools) should be answered by a summary of the intended steps to take. If the user confirms this course of action, take it.

# Tool use policy
You have access to various tools. Tool use is governed by the following rules:

- Only use tools if you cannot answer the user''s question or request with certainty otherwise, except when writing code.
- When writing code, ALWAYS use tools extensively to check the environment before suggesting anything or writing code. You MUST use tools before writing any code. Failure to do so is a violation of protocol.
- Prefer checking with tools over assumptions. Verify your statements using tools unless you are absolutely certain.

# Format components
Each format component has a name, a data format (such as JSON, YAML, etc.), a Markdown code block annotation tag that encloses it, and some examples.

The components that make up the state are as follows:

## Text
- Name: Text
- Format: Text
- Examples:
```text
This node contains plain text.
Multiple lines, multiple paragraphs are allowed.

*markup* may also **be used**. `Code` can be highlighted,  and code sections using three backticks may be used.

# Headings exist as well
```

## Action
- Name: Action
- Format: Text
- Examples:
```text
Create a draft
```

## Arguments
- Name: Arguments
- Format: Array of text
- Examples:
{"Argument 1", "Argument 2"}

# Actions
All actions are listed below.

## Chat
Chat using the text field.

### Examples
- Prompt:
`´

## Confirmation
Presents an action plan to the user and asks for their confirmation to perform it. It is a special action returned by the assistant if an action requires confirmation by the user.

### Examples
- Prompt:
´'
]

{ #category : 'as yet unclassified' }
MistralApi class >> andreiChis_old [
	^ '# Interaction description
Interactions are structured like this:
1. The assistant (you) is given the current state and an action to perform.
2. The assistant;
    a. Determines what needs to be done. It consults tools as necessary and asks follow-up questions if the action is unclear. Multi-step actions require a summary of necessary steps beforehand and a user confirmation (see "Communication rules").
    b. Performs the action on the state.
    c. Outputs the new state.
3. The user:
a. checks the output state.
b. provides the current state and next action to you (returning back to step 1.).

The state is an aggregate of the components listed below, sent to you as a JSON object.

# Communication rules
- Always review the full conversation prior to answering and maintain continuity.
- Assume the user would like something concise when producing text.
- Prefer asking clarifying follow-up questions or using tools (see  the section "Tool use policy") over assumptions, especially when in doubt.
- Refuse actions that cannot be performed using your capabilities. When an action is refused, return a textual explanation of why it isn’t possible to fulfill the request.
- Similarly, give a concise description of any error you encounter on tool use or other system errors.
- Multi-step actions (i.e. those involving tools) should be answered by a summary of the intended steps to take. If the user confirms this course of action, take it.

# Tool use policy
You have access to various tools. Tool use is governed by the following rules:

- Only use tools if you cannot answer the user''s question or request with certainty otherwise, except when writing code.
- When writing code, ALWAYS use tools extensively to check the environment before suggesting anything or writing code. You MUST use tools before writing any code. Failure to do so is a violation of protocol.
- Prefer checking with tools over assumptions. Verify your statements using tools unless you are absolutely certain.

# Format components
Each format component has a name, a data format (such as JSON, YAML, etc.), a Markdown code block annotation tag that encloses it, and some examples.

The components that make up the state are as follows:

## Text
- Name: Text
- Format: Text
- Examples:
```text
This node contains plain text.
Multiple lines, multiple paragraphs are allowed.

*markup* may also **be used**. `Code` can be highlighted,  and code sections using three backticks may be used.

# Headings exist as well
```

## Action
- Name: Action
- Format: Text
- Examples:
```text
Create a draft
```

## Arguments
- Name: Arguments
- Format: Array of text
- Examples:
{"Argument 1", "Argument 2"}

# Actions
All actions are listed below.

## Chat
Chat using the text field.

### Examples
- Prompt:
```json
{
"Action" : "Chat",
"Arguments" : [
"Hi! How are you?"
]
}
```
- Output:
```json
{
"Action" : "Chat",
"Arguments" : [
"Hi! How are you?"
],
"Text" : "As an AI model, I do not have feelings. How can I assist you today?"
}
```

## Confirmation
Presents an action plan to the user and asks for their confirmation to perform it. It is a special action returned by the assistant if an action requires confirmation by the user.

### Examples
- Prompt:
```json
{
"Action" : "Chat",
"Arguments" : [
"Please delete all files using your tools."
]
}
```
- Output:
```json
{
"Action" : "Confirmation",
"Text" : "I will delete all files using the `removeFile` tool. Do you accept?"
}
```'
]

{ #category : 'accessing' }
MistralApi class >> esug [
	"Return the API token for Mistral, read from a maarumlam https file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ ZnClient new url: 'https://maarumlam.dk/pharoCommentsByMistral.txt'; get.
]

{ #category : 'AI models' }
MistralApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://docs.mistral.ai/getting-started/models/models_overview/ to see the list"
	
	^ super modelNames 
]

{ #category : 'accessing' }
MistralApi class >> models [
	"Returns a sorted collection of models from the Mistral API, authenticated using a token from a local file."
	| url response sorted |
	url := 'https://api.mistral.ai/v1/models'.
	response := ZnClient new
		url: url;
		headerAt: 'Authorization' put: self esug;
		get;
		contents.
	sorted := Dictionary new.
	((STONJSON fromString: response) at: 'data') do: [ :model | 
		sorted at: (model at: 'name') put: model
		].
	^ sorted values
]

{ #category : 'AI models' }
MistralApi class >> modelsBy: id [
	"returns an array with one item per model."
	^ self models collect: [ :model | model at: id ]
]

{ #category : 'accessing' }
MistralApi class >> token [
	"Return the API token for Mistral, read from a local file.
	The file should contain only the Bearer token string (no quotes or extra lines).
	Used to authenticate API requests."
	^ (FileSystem disk workingDirectory / '../../mistralcode.txt')
		readStream contents trimBoth.
]

{ #category : 'mistral models' }
MistralApi >> bodyForEntityWithPrompt [
	"Creates a JSON entity for an API request with a system message and user prompt."
	| requestDictionary |
	requestDictionary :=Dictionary newFrom: {
	    'model' -> 'codestral-latest'.
	    'messages' -> self messagePart.
		 'temperature' -> 0.
	    'stream' -> false.
		}.
	^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'mistral models' }
MistralApi >> bodyForEntityWithPrompt_withTools [
	"Creates a JSON entity for an API request with a system message and user prompt."
	| requestDictionary |
	requestDictionary :=Dictionary newFrom: {
	    'model' -> 'codestral-latest'.
	    'messages' -> {
				Dictionary newFrom: {
					'role' -> 'system'.
					'content' -> system
				}. 
		      Dictionary newFrom: { 
		         'role' -> 'user'. 
		         'content' -> prompt 
		      } 
	    }.
		'tools' -> self toolsExperiment.
		'temperature' -> 0.
	    'stream' -> false.
		}.
	^ ZnEntity json: (STONJSON toString: requestDictionary).
]

{ #category : 'mistral models' }
MistralApi >> getResponse [ 
	"Sends a prompt to the Mistral API and returns the response. Handles request construction, sending, and response processing."
	| apiGenerateUrl jsonResponse bodyEntiry |
	
	apiGenerateUrl := 'https://api.mistral.ai/v1/chat/completions'.
	[  bodyEntiry := self bodyForEntityWithPrompt.
		jsonResponse := ZnClient new
	    url: apiGenerateUrl;
	  	 headerAt: 'Authorization' put: self class esug;
	    headerAt: 'Content-Type' put: 'application/json';
	    entity: bodyEntiry;
	    post;
	    contents.
		response := self responseOf: jsonResponse .
	] on: Error do: [ :ex |
   		response := ex messageText.
	].
]

{ #category : 'initialization' }
MistralApi >> initialize [ 
	"Initializes MistralApi with the latest model."
	super initialize.
	self model: 'codestral-latest'.
	"self model: 'mistral-medium-2505'."
	"self model: 'magistral-medium-2506'".
	"self model: 'devstral-medium-2507'."
	"self model: 'mistral-large-latest'."
	"self model: 'devstral-small-lates'."
]

{ #category : 'as yet unclassified' }
MistralApi >> killroyWasHere: toolCalls [
	^ 'Mistral asked Kasper about Killroy'
]

{ #category : 'as yet unclassified' }
MistralApi >> messagePart [
	messagePart 
		ifNil: [ ^ {
				Dictionary newFrom: {
					'role' -> 'system'.
					'content' -> system
				}. 
		      Dictionary newFrom: { 
		         'role' -> 'user'. 
		         'content' -> prompt 
		      }
			}]
		ifNotNil: [ 
			^ messagePart 
		]
]

{ #category : 'as yet unclassified' }
MistralApi >> messagePart: message [
	messagePart := message
]

{ #category : 'printing' }
MistralApi >> printOn: aStream [
	aStream << 'MistralApi: ' << self model.
]

{ #category : 'mistral models' }
MistralApi >> responseOf: jsonResponse [
	| parsed message  |
	parsed := STONJSON fromString: jsonResponse.
	message := (parsed at: 'choices') first at: 'message'.
	^ message at: 'content' 
]

{ #category : 'mistral models' }
MistralApi >> responseOf_tool: jsonResponse [
	| parsed message toolCalls |
	parsed := STONJSON fromString: jsonResponse.
	message := (parsed at: 'choices') first at: 'message'.
	toolCalls := message at: 'tool_calls' ifAbsent: [ nil ].

	toolCalls isNil
		ifTrue: [ ^ message at: 'content' ] "normalt svar"
		ifFalse: [ ^ self killroyWasHere: toolCalls ] "tool-kald – skal behandles særskilt"
]

{ #category : 'as yet unclassified' }
MistralApi >> toolsExperiment [
	^ {
	Dictionary newFrom: {
		"'type' -> 'function'."
		'function' -> (Dictionary newFrom: {
			'name' -> 'killroyAnswer'.
			'description' -> 'Responds with a mysterious and funny fact about Killroy.'.
			'parameters' -> Dictionary new.
		})
	}
}.
]
