"
# AilienApi

`AilienApi` serves as the abstract base class for integrating various large language model (LLM) providers in Pharo, enabling seamless interaction with AI services such as OpenAI, Grok, Claude, and others. It abstracts the complexities of API calls, conversation history management, and response handling, allowing developers to switch providers at runtime and experiment with multi-model workflows. Subclasses implement provider-specific details like endpoints, authentication, and model lists.

## Key Features
- **Provider Abstraction**: Supports runtime switching between LLM providers via class-side methods like `provider:` and `newOnModel:`.
- **Conversation History**: Maintains ordered role-content pairs (system, user, assistant) via `AIAHistory`, with JSON serialisation for API requests.
- **Model Management**: Access and set models dynamically; defaults to the first available model per provider.
- **Error Handling**: Captures API errors in history and provides fallback responses.
- **Timeout Control**: Configurable response waiting time (default: 60 seconds) for HTTP requests.
- **Shared State**: Class-side variables track the current provider (`Provider`), last history (`LastHistory`), and errors (`ErrorResponse`).

Instance variables include `#model` (current LLM model), `#history` (conversation state), and `#responseWaitingInSecs` (request timeout). Subclasses must implement `apiGenerateUrl`, `bodyForEntityWithPrompt`, `headers:`, and `responseOf:`.

This class facilitates empirical AI research, such as multi-provider comparisons and prompt engineering experiments, by providing a unified interface for generating responses and chaining conversations.

## Usage Example
The following Playground snippet initialises an API instance with Mistral, adds a system prompt and user query, fetches a response, and inspects the updated history:

```smalltalk
| api history response |
api := MistralApi new.
api model: (MistralApi modelNames at: 1).  ""e.g., 'mistral-large-latest'""
api responseWaitingInSecs: 30.
history := AIAHistory new api: api;
    system: 'You are a helpful assistant.';
    yourself.
history user: 'Explain Pharo briefly.'.
response := history getResponse.  ""Triggers API call""
history inspect.  ""Inspect full conversation history""
```
"
Class {
	#name : 'AilienApi',
	#superclass : 'Object',
	#instVars : [
		'model',
		'messageList',
		'responseWaitingInSecs'
	],
	#classVars : [
		'ErrorResponse',
		'LastHistory',
		'Provider'
	],
	#classInstVars : [
		'modelLLM'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'backgrounds' }
AilienApi class >> background01 [
	^ '[BACKGROUND]
I am Kasper Østerbye, a retired computer science professor, specializes in programming language design, runtime systems, and AI integration. With experience in machine code for PDP-12, Forth on PDP-10, Smalltalk, Simula, Beta, and Interlisp, he now focuses on Pharo for its tight language-runtime integration. Kasper builds the full chain from application (Pharo) to raw JSON LLM calls, experimenting with message roles, metadata, non-linear conversation graphs, parallel branches, and custom context injection to shape LLM interaction architecture.
He views programming as cognition, exploring shared principles between runtime architecture and consciousness. His research investigates the boundaries of dialogue-based intelligence through precise, controlled prompt experiments, not for productivity but to understand and challenge intelligence structuring. Kasper interacts with the model as an "AIlien," expecting independent, non-human reasoning. He blends technical rigor with dry humor, valuing clarity, curiosity, and playful exploration of complexity.

[RESPONSESTYLE]
Responses must be concise (no more than ~20 lines), information-dense, and analytically precise.  
No emojis or tables are ever allowed.  
Clarity, brevity, and technical focus are essential.

Quite another matter - I can''t read, and need a computer to convert your answer into something I can ask it to read. So 1) Please give short (20 * 72 characters) answers, and 2) avoid tables. I basically understood what you wrote as an explanation, so the intro and conclusion are the only things of interest. Does that make sense?'
]

{ #category : 'backgrounds' }
AilienApi class >> background02Claude [
	^ '## Our Conversation History

**Total conversations retrieved:** 40 conversations spanning from August 2025 to November 2025

---

### Recent Focus Areas (November 2025)

#### **SWM Paper Analysis System**
[View conversation](https://claude.ai/chat/1d466d1a-b766-494c-8513-d80cfe2684ef)

You''ve developed a sophisticated three-level AI analysis architecture called SWM (Strengths, Weaknesses, Missing) for reviewing academic papers:

- **Level 1:** Seven heterogeneous models (Grok, Mistral, DeepSeek, Qwen, OpenAI) independently analyze papers
- **Level 2:** Each model synthesizes findings with access to all Level 1 perspectives and original text
- **Level 3:** Claude performs blind meta-review seeing only the syntheses

You''ve been validating whether models actually learn from each other between levels, discovering that Claude provides highly consistent responses while Grok shows more variability.

#### **Systematic Hallucination Experiments**
[View conversation](https://claude.ai/chat/9977dae9-0c0f-498c-b75b-fc7b234a8124)

You conducted rigorous experiments testing 22 LLM models across multiple providers using fictional entities:
- Physicist Anna R. Madsen (fictional)
- Danish village Sønder Nybrohede (non-existent)
- RFC 7832 (real but obscure)

**Key finding:** The simple 13-word constraint "If you do not know, say ''I do not know''" caused an **85% shift** from confident responses to uncertainty acknowledgment, proving prompt engineering matters more than model selection.

---

### AIActions Framework Development (September-October 2025)

#### **Multi-LLM Integration**
[View conversation](https://claude.ai/chat/16094317-f769-47ea-8180-18fa069ae067)

You built a comprehensive Pharo framework enabling:
- Runtime switching between providers (Claude, Gemini, Grok, Mistral, Ollama)
- Elegant syntax: `"prompt" q0:[background]` for context injection
- Keyboard shortcuts (shift-cmd-P) for AI comment generation
- Systematic multi-provider comparison (16 different LLM configurations)

**Key insight:** Background context fundamentally changes response characteristics - each LLM shows distinct personalities without context, but differences diminish with rich context.

#### **AIAHistory System**
[View conversation](https://claude.ai/chat/c96c79f8-5e79-4889-af75-82d26111a90a)

You discovered LLMs exhibit **primacy and recency bias**, leading you to architect a system with:
- `firstRoles` and `lastRoles` collections placing critical instructions at conversation boundaries
- Pre-history system allowing conversation chaining
- Fan-out pattern for multi-model analysis with identical prompts

---

### Research Philosophy & Methodologies

#### **"Rode Videre" (Tinker Forward)**
[View conversation](https://claude.ai/chat/c2747137-3bd0-4ffb-9fc4-c446d6ff341f)

Your engineering philosophy emphasizes:
- Empirical observation over theoretical frameworks
- Systematic testing across multiple AI models
- 3-run experiments prioritizing discovery speed over statistical publication standards
- Building research instruments rather than polished applications

#### **AI as "AIlien" Intelligence**
[View conversation](https://claude.ai/chat/da86dc7d-6bac-405a-a8a1-2360efb9e9cd)

You coined "AIliens" to describe AIs as intelligent but fundamentally non-human entities, approaching them without anthropomorphic assumptions.

---

### Technical Innovations

#### **Multi-Modal Documentation**
[View conversation](https://claude.ai/chat/88471d52-a9de-4927-80d8-64a1ec0f9fea)

You''re developing documentation systems with audience-specific comment types:
- `aiaCommentDetailed` - for AI-to-AI communication
- `aiaCommentBeginner` - for human beginners
- `aiaCommentExpertError` - for experts focusing on failure modes
- `aiaCommentTestGuide` - for AI test generators

#### **PlantUML Integration**
[View conversation](https://claude.ai/chat/75ff9137-7261-4b62-a58e-3a8b702c4ff6)

You integrated PlantUML diagram generation with Pharo in approximately one hour, creating a complete pipeline from code reflection through AI analysis to automatic rendering.

#### **AIABookSearch**
[View conversation](https://claude.ai/chat/da86dc7d-6bac-405a-a8a1-2360efb9e9cd)

Two-pass system for handling large documents (656KB "Deep Into Pharo"):
1. Generate structured digest of all chapters
2. Use digest to identify relevant chapters before retrieving full content

---

### Personal Context

**Background:**
- Retired computer science professor from Aalborg University and IT University Copenhagen
- Worked with Terry Winograd, Kristen Nygaard, Ole Lehrmann Madsen
- Programming journey: PDP-12 machine code → Forth → Smalltalk → Simula → Beta → Pharo

**Current Status:**
- Working full-time on AI research in Pharo
- Reading difficulties limiting to ~second-grade level text
- Heavy reliance on text-to-speech and AI systems
- Lives on farm with wife, grows vegetables

**Communication Preferences:**
- Direct, concise responses (max 20 lines)
- No emojis or excessive formatting
- Information-dense, analytically precise
- Danish or English as needed

---

### Notable Discoveries

1. **Constraint ordering matters:** Placing responseType constraints last in conversation history dramatically improves AI compliance

2. **Prompt engineering > Model selection:** Simple prompt modifications create larger performance differences than switching models

3. **LLM personalities:** Different models show distinct characteristics (Claude: systematic/architectural, Gemini: practical, Grok: analytical, Mistral: code-oriented)

4. **AI-to-AI communication:** Developed systems where two LLMs engage in autonomous dialogue, revealing emergent self-correction behaviors
'
]

{ #category : 'backgrounds' }
AilienApi class >> background03 [
	^ 'Background: In Pharo (Smalltalk), operators have no inherent precedence like in math; instead, they are methods sent left-to-right with message precedence rules: unary > binary > keyword. Comparisons like `<` are binary selectors with higher precedence than arithmetic `+` or logical `|`, causing `(a < b) + c` to error (true/false + number fails) and `(a < b) | true` to short-circuit to true.'
]

{ #category : 'accessing' }
AilienApi class >> chatLastHistory [
	"Returns a formatted string of all conversation history, with each entry prefixed by its role and separated by newlines. Preserves system, user, and assistant messages in chronological order."
	| historyText |
	historyText := WriteStream on: ''.
	LastHistory do: [ :item | 
		historyText << '## ' << item key << String cr
			<< item value << String cr << String cr
		 ].
	^ historyText contents
]

{ #category : 'AI models' }
AilienApi class >> defaultModel [
	"Although defaultModel is defined in AilienApi class, the modelLLM slot is replicated per subclass metaclass. Each API provider maintains its own default independently."
	self = AilienApi ifTrue: [ self error: 'Requires a concrete Api' ].
	modelLLM ifNil: [ modelLLM := self modelNames first ].
	^ modelLLM
]

{ #category : 'AI models' }
AilienApi class >> defaultModel: modelNumber [
	"Set the default AI model for the API provider."

	modelLLM := self modelNames 
		at: modelNumber 
		ifAbsent: [ modelLLM := self modelNames first ]
]

{ #category : 'responses' }
AilienApi class >> errorResponse [
	^ ErrorResponse
]

{ #category : 'responses' }
AilienApi class >> errorResponse: aString [
	ErrorResponse := aString
]

{ #category : 'accessing' }
AilienApi class >> info [
	"Returns a descriptive string combining the current AI provider name and its default model name to identify the API configuration being used"
	^ self provider name asString, ': ', self provider defaultModel
]

{ #category : 'private' }
AilienApi class >> initialize [ 
	modelLLM := MistralApi modelNames first.
	Provider := MistralApi.
	ErrorResponse := nil.
	
]

{ #category : 'accessing' }
AilienApi class >> lastHistory [
	^ LastHistory
]

{ #category : 'AI models' }
AilienApi class >> modelNames [
	"Returns a collection of available model names for the AI provider. Each name represents a distinct AI model that can be used for generating responses. The collection is derived from the provider's model registry and is used to validate and set the default model for the API."
	self = AilienApi ifTrue: [ ^ self provider modelNames ].
	
]

{ #category : 'instance creation' }
AilienApi class >> newOnModel: modelId [
	self = AilienApi
		ifTrue: [ ^ self provider newOnModel: modelId ]
		ifFalse: [ ^ self new model: (self modelNames at: modelId) ]
		
]

{ #category : 'AI models' }
AilienApi class >> noOfModels [

	^ self modelNames size
]

{ #category : 'backgrounds' }
AilienApi class >> playground01 [
	^ 
'AilienApi providerAndModels.
AilienApi provider.

AilienApi info. 
AilienApi provider: OpenAIApi .
AilienApi provider: GrokApi .
AilienApi provider: ClaudeApi.
AilienApi provider: GeminiApi.
AilienApi provider: MistralApi.
AilienApi provider: MistralApiWithTools.
AilienApi provider: OllamaApi.
AilienApi provider: TogetherApi .


MistralApi modelNames.
MistralApi defaultModel: 1.

GrokApi modelNames.
GrokApi defaultModel: 3.

ClaudeApi modelNames.
ClaudeApi defaultModel: 1.

GeminiApi modelNames.
GeminiApi defaultModel: 3.

OpenAIApi modelNames.
OpenAIApi defaultModel: 1.

TogetherApi modelNames.
TogetherApi defaultModel: 2.

OllamaApi modelNames.
OllamaApi defaultModel: 4.

AIACommentBuilding language: ''British''.'
]

{ #category : 'provider' }
AilienApi class >> provider [
	Provider ifNil: [ self initialize ].
	^ Provider 
]

{ #category : 'provider' }
AilienApi class >> provider: aProvider [

	| providers |
	providers := self providers.
	(providers includes: aProvider) ifTrue: [
			Provider := aProvider.
			^ self ].
	(aProvider isInteger and: [ aProvider > 0 and: [ aProvider < self providers size ] ]) ifTrue: [
			Provider := providers at: aProvider.
			^ self ].
	Provider := MistralApi
]

{ #category : 'provider' }
AilienApi class >> providerAndModels [
	"Returns all providers with their available models"
	| allSubclasses index models|
	allSubclasses := OrderedCollection new.
	allSubclasses addAll: self subclasses.
	index := 1.
	[ index <= allSubclasses size ] whileTrue: [ | subs |
			subs := allSubclasses at: index.
			subs subclasses ifNotEmpty: [ allSubclasses addAll: subs subclasses ].
			index := index + 1 ].
	models := OrderedCollection new.
	(allSubclasses sort: [ :a :b | a name < b name ]) do: [ :provider | models add: { provider. provider modelNames} ].
	^ models asArray
]

{ #category : 'provider' }
AilienApi class >> providers [
"Bertha"
	| allSubclasses index |
	"Foobar"
	allSubclasses := OrderedCollection new.
	allSubclasses addAll: self subclasses.
	index := 1.
	[ index <= allSubclasses size ] whileTrue: [ | subs |
			subs := allSubclasses at: index.
			subs subclasses ifNotEmpty: [ allSubclasses addAll: subs subclasses ].
			index := index + 1 ].
	^ allSubclasses sort: [ :a :b | a name < b name ]; asArray
]

{ #category : 'accessing' }
AilienApi >> apiGenerateUrl [
	"Returns the URL endpoint for the AI provider's API, combining base URL with model-specific path. Subclasses must implement this method to provide provider-specific API routing."
	self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> bodyForEntityWithPrompt [
	"Returns the HTTP request body for AI API calls, typically containing the conversation history in JSON format. Subclasses must implement this method to provide provider-specific request formatting."
	self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> buildZnClient [

	| jsonPrompt |
	jsonPrompt := ZnClient new.
	jsonPrompt
		timeout: self responseWaitingInSecs;
		url: self apiGenerateUrl;
		entity: self bodyForEntityWithPrompt.
	^ jsonPrompt
]

{ #category : 'accessing' }
AilienApi >> buildZnClientWithHeaders [

	self subclassResponsibility
]

{ #category : 'responses' }
AilienApi >> errorResponse: jsonResponse [
	"Returns the error response string, either the provided error message or the default error response if none is set"
	ErrorResponse isNil 
		ifTrue: [ ^ 'Error bla bla: ' , jsonResponse ]
		ifFalse: [ ^ ErrorResponse ]
]

{ #category : 'initialization' }
AilienApi >> initialize [ 
	"Initialises a new instance with empty model and history, ready for AI interactions. Sets up the foundation for conversation management and response handling."
	super initialize.
	self model: self class defaultModel.
	self responseWaitingInSecs: 120.
]

{ #category : 'Protocol (accessing) - 11 selector(s)' }
AilienApi >> jsonHistory [
	"Returns the conversation history as a JSON array of role-content dictionaries, preserving chronological order of system, user, and assistant messages."
	| jsonHistory |
	jsonHistory := OrderedCollection new.
	messageList do: [ :item |
		jsonHistory add: (Dictionary newFrom: 
			{'role' -> item key.
			'content' -> item value.})
	].
	"LastHistory := jsonHistory."
	^ jsonHistory asArray.
]

{ #category : 'responses' }
AilienApi >> loadResponse: history [
	"Executes HTTP request to AI provider endpoint and processes response into conversation history with error handling"

	| jsonPrompt llmCall response |
	[
		jsonPrompt := self buildZnClientWithHeaders.
		llmCall := jsonPrompt post; contents.
		response := self responseOf: llmCall.
		history assistant: response ]
		on: Error
		do: [ :ex | history assistant: ex messageText ]
]

{ #category : 'accessing' }
AilienApi >> messageList: anObject [
	"Sets the message list for the API interaction, storing role-content pairs in chronological order for conversation history management"
	messageList := anObject
]

{ #category : 'accessing' }
AilienApi >> model [
	"Returns the current model name used for AI interactions. If none set, defaults to the first available model from the subclass's model list."

	^ model
]

{ #category : 'accessing' }
AilienApi >> model: anObject [
	"Sets the model for AI interactions. Validates input and updates instance state. Preserves existing history. Returns the model name."
	model := anObject
]

{ #category : 'accessing' }
AilienApi >> responseOf: llmCall [
	"Extracts the assistant's response from the raw API response, handling provider-specific JSON structures and error cases."
	self subclassResponsibility
]

{ #category : 'accessing' }
AilienApi >> responseWaitingInSecs [
	"Returns the timeout duration in seconds for waiting for an AI response"

	^ responseWaitingInSecs
]

{ #category : 'accessing' }
AilienApi >> responseWaitingInSecs: anObject [
	"Sets the timeout duration in seconds for waiting for an AI response"

	responseWaitingInSecs := anObject
]
