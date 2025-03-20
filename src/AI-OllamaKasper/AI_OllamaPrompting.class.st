"
Asking a ollama model a prompt and get a response.

It is possible to set two variables:
* system: part of the information given to the model before the query is actually asked.
* promptPrefix: fixed prefix that is set before any actual prompt
These two can be set using the class side operation newSystem:promptPrefix:
In addition is this
* model - which ollama model is used, which is set in the initialize method

also this exist:
* semaphore, which is just a way to prevent the system to halt while asking prompts


"
Class {
	#name : 'AI_OllamaPrompting',
	#superclass : 'Object',
	#instVars : [
		'model',
		'system',
		'promptPrefix',
		'response',
		'semaphore'
	],
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'instance creation' }
AI_OllamaPrompting class >> newSystem: synstemText promptPrefix: promptPrefixText [
	| prompter |
	prompter := self new.
	prompter system: synstemText.
	prompter promptPrefix: promptPrefixText.
	^ prompter 
]

{ #category : 'ollama models' }
AI_OllamaPrompting >> askPrompt: promptString [
	"Asks the promptString, the result will be awailable after a while in getResponse"
	| ollamaProcess  |

	semaphore := Semaphore new.
	response := nil.
	ollamaProcess := [ 
		"Perform the actual Ollama request"
		response := self promptAndResponseSemaphore: promptString.
		"Transcript show: (promptString , ' -> ', response); cr."

		"Signal that the process is done"
		semaphore signal.
	] newProcess.

	ollamaProcess resume.
]

{ #category : 'ollama models' }
AI_OllamaPrompting >> getResponse [
	"returns the responce. If the response is nil, and semaphore not nil, waits for result"
	response ifNil: [ 
		semaphore ifNotNil: [ semaphore wait ] ].

	^ response
]

{ #category : 'initialization' }
AI_OllamaPrompting >> initialize [ 
	model := 'phi4'.
	system := ''.
	promptPrefix := ''.
]

{ #category : 'accessing' }
AI_OllamaPrompting >> model [
	^ model
]

{ #category : 'accessing' }
AI_OllamaPrompting >> model: aValue [
	model	:=	aValue.
]

{ #category : 'ollama models' }
AI_OllamaPrompting >> old_promptAndResponse: promptString [
	| ollamaProcess  |

	semaphore := Semaphore new.
	response := nil.
	ollamaProcess := [ 
		"Perform the actual Ollama request"
		response := self promptAndResponseSemaphore: promptString.

		"Signal that the process is done"
		semaphore signal.
	] newProcess.

	ollamaProcess resume.
	"Wait until the process finishes"
	semaphore wait.

	^ response
]

{ #category : 'ollama models' }
AI_OllamaPrompting >> ollamaList [
	"Ask ollama for its list of model names, return them"
	| res |
	res := (LibC resultOfCommand: 'ollama list') lines allButFirst.
	^res collect: [:resItem | resItem copyUpToSubstring: ' ' ].
]

{ #category : 'ollama models' }
AI_OllamaPrompting >> promptAndResponseSemaphore: prompt [
	"Sends a prompt to an API, receives JSON response, and extracts the 'response' value"
	| url jsonResponse requestBody|
	url := 'http://localhost:11434/api/generate'.

	requestBody := STONJSON toString: { 
	    #model -> model.
	    #system -> system.
	    #prompt -> (promptPrefix , ' ', prompt).
	    #stream -> false.
    	 #temperature -> 0.
	} asDictionary.

	jsonResponse := ZnClient new
	    url: url;
	    entity: (ZnEntity with: requestBody);
	    post;
	    contents.
	response := (STONJSON fromString: jsonResponse) at: 'response'.
	^ response.
]

{ #category : 'accessing' }
AI_OllamaPrompting >> promptPrefix [
	^ promptPrefix .
]

{ #category : 'accessing' }
AI_OllamaPrompting >> promptPrefix: aValue [
	promptPrefix	:=	aValue.
]

{ #category : 'accessing' }
AI_OllamaPrompting >> response [
	^ response .
]

{ #category : 'accessing' }
AI_OllamaPrompting >> responses: aValue [
	response	 :=	aValue.
]

{ #category : 'accessing' }
AI_OllamaPrompting >> system [
	^ system .
]

{ #category : 'accessing' }
AI_OllamaPrompting >> system: aValue [
	system	 :=	aValue.
]

{ #category : 'accessing' }
AI_OllamaPrompting >> terminatePrompt [
	semaphore terminate.
]
