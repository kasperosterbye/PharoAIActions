Class {
	#name : 'AI_OllamaPromptingTest',
	#superclass : 'TestCase',
	#instVars : [
		'ollamaPrompte',
		'askPrompt'
	],
	#category : 'AI-OllamaKasper',
	#package : 'AI-OllamaKasper'
}

{ #category : 'tests' }
AI_OllamaPromptingTest >> a_testAskPrompt [
	"test that the connection to the model works"

	| res |
	res := AI_OllamaPrompting
		       newSystem: 'Give respose of maximum 50 characters. Never more than 50 characters, and less is good. 
								Absolutely no code example may be given in response. '
		       promptPrefix: 'Pharo question - what would be a comment for '.
	res askPrompt: 'promptAndResponse: prompt
			| url jsonResponse requestBody response|
			url := ''http://localhost:11434/api/generate''.

			requestBody := STONJSON toString: { 
			    #model -> model.
			    #system -> system.
			    #prompt -> (promptPrefix , '' '', prompt).
			    #stream -> false.
		    	 #temperature -> 0.
			} asDictionary.

			jsonResponse := ZnClient new
			    url: url;
			    entity: (ZnEntity with: requestBody);
			    post;
			    contents.

			response :=(STONJSON fromString: jsonResponse) at: ''response''.
			^response.
		'.
	self assert: (res getResponse size between: 1 and: 100).
	
	Transcript show: res getResponse; cr.
]

{ #category : 'running' }
AI_OllamaPromptingTest >> defaultTimeout [
	^ 120. "Timeout in seconds"
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> old_testPromptAndResponse [
	"test that the connection to the model works"

	ollamaPrompte promptAndResponse: 'promptAndResponse: prompt
			| url jsonResponse requestBody response|
			url := ''http://localhost:11434/api/generate''.

			requestBody := STONJSON toString: { 
			    #model -> model.
			    #system -> system.
			    #prompt -> (promptPrefix , '' '', prompt).
			    #stream -> false.
		    	 #temperature -> 0.
			} asDictionary.

			jsonResponse := ZnClient new
			    url: url;
			    entity: (ZnEntity with: requestBody);
			    post;
			    contents.

			response :=(STONJSON fromString: jsonResponse) at: ''response''.
			^response.
		'.
	self assert: (ollamaPrompte response size between: 1 and: 100).
	
	Transcript show: ollamaPrompte response; cr.
]

{ #category : 'running' }
AI_OllamaPromptingTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	ollamaPrompte := AI_OllamaPrompting
		       newSystem: 'Give respose of maximum 50 characters. Never more than 50 characters, and less is good. 
								Absolutely no code example may be given in response. '
		       promptPrefix: 'Pharo question - what would be a comment for '.
	askPrompt := 'promptAndResponse: prompt
			| url jsonResponse requestBody response|
			url := ''http://localhost:11434/api/generate''.

			requestBody := STONJSON toString: { 
			    #model -> model.
			    #system -> system.
			    #prompt -> (promptPrefix , '' '', prompt).
			    #stream -> false.
		    	 #temperature -> 0.
			} asDictionary.

			jsonResponse := ZnClient new
			    url: url;
			    entity: (ZnEntity with: requestBody);
			    post;
			    contents.

			response :=(STONJSON fromString: jsonResponse) at: ''response''.
			^response.
		'.
]

{ #category : 'running' }
AI_OllamaPromptingTest >> setUp2 [
	super setUp.

	"Put here a common initialization logic for tests"
	
	ollamaPrompte := AI_OllamaPrompting new.
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> testAskPrompt [
	"test that the connection to the model works"
 	
	ollamaPrompte askPrompt: askPrompt.
	self assert: (ollamaPrompte getResponse size between: 1 and: 100).
	
	Transcript show: ollamaPrompte getResponse; cr.
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> testGetResponse [
	"test that the connection to the model works"

	ollamaPrompte askPrompt: askPrompt.
	self assert: ollamaPrompte response isNil.
	self assert: ollamaPrompte getResponse isNotNil
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> testOllamaList [
	"check at the list function works, and is larger than 0"
	| res |
	res := AI_OllamaPrompting ollamaList.
	self assert: res size >= 1
	
]

{ #category : 'tests' }
AI_OllamaPromptingTest >> testPromptAndResponseSemaphore [
	"tests if promptAndResponseSemaphore: is returning a result"
	| result |
	result := AI_OllamaPrompting new promptAndResponseSemaphore: 'What is your name. Just name. Only one line.'.
	self assert: (result includesSubstring: 'Phi')
]
