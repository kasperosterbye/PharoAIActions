Class {
	#name : 'OpenAIApi',
	#superclass : 'Object',
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'ollama models' }
OpenAIApi >> getResponseForPrompt: prompt [
	"Sends a prompt to an API, receives JSON response, and extracts the 'response' value"
	"Split the method into parts, it is a bit too long now..."
	| apiGenerateUrl jsonResponse requestDictionary requestBody|
	"apiGenerateUrl := 'https://api.openai.com/v1/chat/completions'."
	apiGenerateUrl := 'https://api.openai.com/v1/completions'.
	requestDictionary := Dictionary newFrom:  { 
		"#system -> self system.
		#prompt -> (self promptPrefix , ' ', prompt)."
		#stream -> false.
	} .
	requestBody := (STONJSON toString: requestDictionary).
	[jsonResponse := ZnClient new.
	 jsonResponse 
	    url: apiGenerateUrl.
	jsonResponse 
    	 headers at: 'Content-Type' put: 'application/json';
	    entity: (ZnEntity with: requestBody);
	    post;
	    contents.
		self response: ((STONJSON fromString: jsonResponse) at: 'response') contents .
	] on: Error do: [ :ex |
   		self response: ex messageText.
	].
	^ self response.
]
