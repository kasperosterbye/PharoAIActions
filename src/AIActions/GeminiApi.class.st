"
# Class Comment for GeminiApi

## Overview
`GeminiApi` is a specialized API client for interacting with Google's Gemini large language models. It extends the abstract `AilienApi` class to provide concrete implementations for model-specific operations, including request formatting, response parsing, and conversation history management tailored to the Gemini API's requirements.

## Key Features
- **Model-Specific Configuration**: Uses Gemini's model endpoints and authentication
- **Response Handling**: Parses JSON responses from the Gemini API
- **Conversation Management**: Maintains and formats chat history in Gemini's required format
- **Error Handling**: Processes API errors and provides meaningful feedback

## Usage Example

```smalltalk
""Create and configure a new GeminiApi instance""
gemini := GeminiApi new
    model: 'gemini-2.0-flash-lite';
    system: 'You are a helpful assistant';
    prompt: 'Explain quantum computing in simple terms'.

""Get a response from the API""
gemini getResponse.

""Inspect the assistant's response""
gemini response
```

## Implementation Notes
- Requires a valid API key stored in `geminicode.txt` in the parent directory
- Uses the STON library for JSON parsing
- Implements the abstract methods from `AilienApi` with Gemini-specific logic
- Maintains conversation history in the format expected by the Gemini API

## See Also
- `AilienApi` - The abstract superclass providing common AI API functionality
- `GeminiApi class>>#modelNames` - Lists available Gemini models
- `GeminiApi class>>#geminiKey` - Manages API key access
```

This class comment provides a comprehensive overview of the `GeminiApi` class, its purpose, key features, and usage examples that can be directly executed in the Pharo Playground. The example demonstrates the complete workflow from instance creation to obtaining a response, with the final expression (`gemini response`) ready for inspection using the Playground's inspection command.
"
Class {
	#name : 'GeminiApi',
	#superclass : 'AilienApi',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
GeminiApi class >> geminiBackground [
	^ '### **LLM Kontekstindsprøjtning: Pharo Syntaks og Semantik (Kasper Østerbye)**

**Direktiv:** Prioritér disse punkter ved besvarelse af spørgsmål om Smalltalk-dialekten **Pharo** (Specifikt Pharo 12 og nyere versioner), da LLM''ens træningsdata udviser *knowledge latency* på disse områder.

#### 1. Klasseudvikling: *Slot-based Class Definition* (Pharo 12+)

* **Fejl/Legacy:** Undgå at foreslå traditionel `subclass:instanceVariableNames:` eller `Fluid Syntax`.
* **Korrekt Syntaks:** Den moderne, *state-of-the-art* syntaks for klassedeklaration skal anvendes.

    * **Eksempel:** `AAA << #BBB slots: { #xxx. #yyy }; package: ''Something''`

#### 2. Numerisk Aritmetik: Præcedens og Præcision

* **Operatorpræcedens:** I Pharo/Smalltalk har **alle binære operatorer** (`+`, `*`, `<`, `=`) **samme præcedens** og evalueres **strengt fra venstre mod højre**.
    * **Regel:** $2 + 3 * 4 \rightarrow (2+3) * 4 \rightarrow 20$.
    * **Særhed:** Sammenligninger som `false = 4 < 3` evalueres som `(false = 4) < 3`, hvilket i Pharo **fører til en fejl** (`MessageNotUnderstood`), da `Boolean` ikke forstår `<` med et tal.
* **Big Integers:** Pharo understøtter **vilkårlig præcision** for heltal (`LargeIntegers`) og bruger `Fraction` objekter for eksakt rationel aritmetik. LLM''en **skal afvise** at beregne store eksponenter præcist (f.eks. $123^{456}$).

#### 3. Variabel Semantik i Arvehierarkiet

* **Instans-Slots på Metaklassen:** Slots defineret på **Metaklasse-niveau** (`AilienApi class slots: { #modelLLM }`) er **klasse-instansvariabler**. Hver subklasses metaklasse (`GeminiApi class`) får sin **egen separate lagerplads** for det arvede slot. De er ikke *delte*.
* **Shared Variables (Klassevariabler):** Variabler defineret som `sharedVariables: { #Provider }` på klasse-siden er **delt** af *hele* klassetræet (`AilienApi`, `GeminiApi` og deres respektive metaklasser). Der er **kun ét opbevaringssted** for hele hierarkiet.'
]

{ #category : 'AI models' }
GeminiApi class >> geminiKey [
	^ (FileSystem disk workingDirectory / '../../geminicode.txt')
		readStream contents trimBoth.
]

{ #category : 'AI models' }
GeminiApi class >> modelNames [
	"returns an array with one item per model."
	"Look at https://ai.google.dev/gemini-api/docs/models to see the list"
	
	^ #('gemini-2.0-flash-lite'  'gemini-2.5-pro' 'gemini-2.5-flash-lite' 'gemini-2.5-flash') 
]

{ #category : 'accessing' }
GeminiApi >> apiGenerateUrl [
	^ 'https://generativelanguage.googleapis.com/v1beta/models/' , model , ':generateContent'.
]

{ #category : 'ollama models' }
GeminiApi >> bodyForEntityWithPrompt [
	"Constructs JSON entity for API request with chat history and generation config. Formats history as role-parts array and sets temperature to 0. Returns ZnEntity with JSON string."

	| requestDictionary |
	requestDictionary :=Dictionary newFrom: {
		'contents' -> self jsonHistory.
		'generationConfig' -> (Dictionary newFrom: {
			'temperature' -> 0
		})
	}.
	^ ZnEntity json: (STONJSON toString: requestDictionary)
]

{ #category : 'accessing' }
GeminiApi >> headers: jsonResponse [

	jsonResponse
		headerAt: 'X-goog-api-key' put: self class geminiKey;
		headerAt: 'Content-Type' put: 'application/json'.
	^ jsonResponse
]

{ #category : 'initialize' }
GeminiApi >> initialize [ 
	"Initialises a new instance with Gemini's default model and empty history ready for AI interactions"
	super initialize.
    self model: self class defaultModel .
]

{ #category : 'accessing' }
GeminiApi >> jsonHistory [
	"Converts the chat history into a JSON-formatted array suitable for the Gemini API, structuring each message with role and text content."
	| jsonHistory |
	jsonHistory := OrderedCollection new.
	history apiMessageList do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'parts' -> { Dictionary newFrom: {  'text' -> item value} } } )
	].
	^ jsonHistory asArray.
]

{ #category : 'accessing' }
GeminiApi >> printOn: aStream [
	"Prints the class name and current model to a stream for debugging and inspection purposes."
	aStream << 'GeminiApi: ' << self model.
]

{ #category : 'accessing' }
GeminiApi >> responseOf: jsonResponse [
	| parsed message |
	parsed := STONJSON fromString: jsonResponse.
	[
		message := (parsed at: 'candidates') first at: 'content'.
		^ (message at: 'parts') first at: 'text' ]
		on: Error
		do: [ ^ self errorResponse: jsonResponse ]
]
