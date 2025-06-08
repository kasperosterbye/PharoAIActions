Class {
	#name : 'MistralApiTest',
	#superclass : 'TestCase',
	#instVars : [
		'mistralApi'
	],
	#category : 'AIAgent-Tests-AIAPI-Tests',
	#package : 'AIAgent-Tests',
	#tag : 'AIAPI-Tests'
}

{ #category : 'running' }
MistralApiTest >> jsonResponse [
	"returns a fixed jsonResponse"
	^ '{"id":"f5e209e379814358adbd652e8c4af086","object":"chat.completion","created":1746867952,"model":"codestral-latest","choices":[{"index":0,"message":{"role":"assistant","tool_calls":null,"content":"It seems like you''re referring to a classic internet meme. \"Killroy was here\" is a phrase that originated from World War II. It was used by American soldiers to mark their presence in occupied areas. The phrase is often associated with a fictional character named \"Killroy,\" who was said to be a spy or saboteur. The exact origin of the phrase is unclear, but it has become a popular internet meme, often used to indicate that someone has been in a particular place or has made changes."},"finish_reason":"stop"}],"usage":{"prompt_tokens":12,"total_tokens":118,"completion_tokens":106}}'
]

{ #category : 'running' }
MistralApiTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	
	mistralApi := MistralApi new.
]

{ #category : 'tests' }
MistralApiTest >> testBodyForEntityWithPrompt [
	| bodyResult |
	mistralApi system: 'Killroy was here'.
	mistralApi prompt: 'Who was here'.
	bodyResult := mistralApi bodyForEntityWithPrompt string.
	self assert: ( bodyResult  includesSubstring: mistralApi system).
	self assert: ( bodyResult  includesSubstring: mistralApi prompt).
]

{ #category : 'tests' }
MistralApiTest >> testGetResponse [
	
	mistralApi 
		system: 'Killroy was here';
		prompt:  'Who was here';
		getResponse.
	self assert: (mistralApi response includesSubstring: 'Killroy')
]

{ #category : 'tests' }
MistralApiTest >> testInitialize [
	"check that the model is set, as it it not in the superclass"
	self assert: MistralApi new model size > 1
]

{ #category : 'tests' }
MistralApiTest >> testInitilize [ 
	self assert: mistralApi model size > 1
]

{ #category : 'tests' }
MistralApiTest >> testPrintOn [
	"printOn: is implemented, but called through printString"
	self assert: (MistralApi new printString includesSubstring: 'MistralApi: ')
]

{ #category : 'tests' }
MistralApiTest >> testResponseOf [
	
	self assert: ((mistralApi responseOf: self jsonResponse ) includesSubstring: 'spy or saboteur')
]
