"
A `GeminiApi` instance serves as a dedicated client for interacting with the Google Gemini API, extending the foundational capabilities provided by `AilienApi`. This class specialises in handling the specifics of the Gemini platform, including API endpoint construction, authentication via an API key, and the precise formatting of request bodies and parsing of responses.

It manages a chronological `messageList` representing the conversation history, which is crucial for maintaining context in multi-turn interactions. `GeminiApi` ensures that messages are correctly structured according to the Gemini API's `role` and `parts` schema. Furthermore, it provides specific background context (`geminiBackground`) at the class level to guide the LLM's responses, particularly concerning Pharo Smalltalk syntax and semantics, addressing potential knowledge latency in the model's training data.

**Usage Example (Pharo Playground):**

```pharo
| geminiApi |
""NOTE: This example requires a 'geminicode.txt' file containing your Gemini API key
to be located two directories up from your Pharo working directory.""

""Initialise a new Gemini API client.""
geminiApi := GeminiApi new.

""Ensure the message list is clear for a new conversation.""
geminiApi messageList: OrderedCollection new.

""Add an initial user message to the conversation history.""
geminiApi messageList add: 'user' -> 'Hello, Gemini!'.

""Send a new prompt to the Gemini API. The loadResponse: method will
add this prompt to the history, send the full conversation, and
then append the assistant's response to the message list.""
geminiApi loadResponse: 'Could you tell me a bit about the Pharo programming language?'.

""Inspect the last message in the conversation, which should be the assistant's reply.""
geminiApi messageList last value
```
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
	"Constructs the specific API endpoint URL for the selected Gemini model to generate content"
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
	"Adds the Gemini API key and JSON content type headers to the HTTP request"

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
	messageList do: [ :item |
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
	"Parses Gemini API JSON response to extract assistant's text, handling errors gracefully"
	| parsed message |
	parsed := STONJSON fromString: jsonResponse.
	[
		message := (parsed at: 'candidates') first at: 'content'.
		^ (message at: 'parts') first at: 'text' ]
		on: Error
		do: [ ^ self errorResponse: jsonResponse ]
]
