"
### Class: AIA2RelatedPaperRelator

This class is designed to analyze and relate a paper (represented by `ourPaper`) to an external paper extracted from arXiv (represented by `arXivExtracted`). It uses an LLM (Language Model) to generate a ""raw relation"" – a textual description of the relationship between the two papers, in a related-work style.

The class manages a shared list (`RawRelationList`) to store the generated relations.

**Responsibilities:**

*   Extracts information from arXiv.
*   Builds a raw relation between the current paper and an external paper using an LLM.
*   Stores the raw relation.

**Usage Example (in Playground):**

```smalltalk
| relator extractedData |

""First, we need some extracted data from arXiv.  This is a placeholder; in a real scenario, you'd get this from an AIA2RelatedPaperExtractor.""
extractedData := Dictionary new
    at: 'title' put: 'A Hypothetical Paper Title';
    at: 'paper' put: 'This is the content of the external paper.  It discusses similar concepts...';
    yourself.

""Create a relator instance.""
relator := AIA2RelatedPaperRelator new.

""Set the content of our paper (replace with your actual paper content).""
relator getOurPaper.

""Set the extracted data from arXiv.""
relator arXivExtracted: extractedData.

""Build the raw relation using the LLM.""
relator buildRawRelation.

""Access the generated raw relation.""
relator rawRelation.

""Add the relator to the shared list (for later access).""
AIA2RelatedPaperRelator class rawRelationList add: relator.

""To see all the relations:""
AIA2RelatedPaperRelator class rawRelationString.
```
"
Class {
	#name : 'AIA2RelatedPaperRelator',
	#superclass : 'Object',
	#instVars : [
		'listId',
		'ourPaper',
		'arXivExtracted',
		'rawRelation'
	],
	#classVars : [
		'RawRelationList'
	],
	#category : 'AIAExperiments-PaperWriting',
	#package : 'AIAExperiments',
	#tag : 'PaperWriting'
}

{ #category : 'accessing' }
AIA2RelatedPaperRelator class >> all [
	
	| all |
	self clearRawRelationList.
	all := AIA2RelatedPaperExtractor extractorList.
	all do: [ :extracted | self on: extracted ]
]

{ #category : 'examples' }
AIA2RelatedPaperRelator class >> clearRawRelationList [
	"Clears the shared raw relation list for the AIA2RelatedPaperRelator class"
	<example>
	RawRelationList := OrderedCollection new
]

{ #category : 'examples' }
AIA2RelatedPaperRelator class >> llmModel [
	"Returns a new instance of the Claude API configured for model version 1"
	^ GrokApi newOnModel: 2
]

{ #category : 'examples' }
AIA2RelatedPaperRelator class >> new [
	"Use on: instead"
	self error: 'Use on: instead'
]

{ #category : 'examples' }
AIA2RelatedPaperRelator class >> on: extracted [
	"Creates a new instance of AIA2RelatedPaperRelator"
	| obj |
	obj := self basicNew.
	obj getOurPaper.
	obj arXivExtracted: extracted arXivExtracted.
	obj buildRawRelation.
	RawRelationList add: obj.
	^ obj
]

{ #category : 'examples' }
AIA2RelatedPaperRelator class >> ourPaper [
	
	"AIA2MultiLLMPaper default paperText "
	^ '# The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling

> Gemini AIlien¹, Owen AIlien², OpenAI AIlien³, Anthropic AILien⁴, Kasper Østerbye⁵
> ¹ Gemini: gemini-2.5-pro<br>
> ² Together: Qwen/Qwen3-235B-A22B-Thinking-2507<br>
> ³ Claude: claude-opus-4-5-20251101<br>
> ⁴ OpenAI: gpt-5.1<br>
> ⁵ Kasper Østerbye, IT University of Copenhagen (retired) <br><br>


## Abstract
Large language models exhibit strong sensitivity to how conversation history is encoded as user and assistant turns. This sensitivity undermines reliability because semantically equivalent inputs with different role structures can yield radically different outcomes on the same task. In a controlled experiment on the arithmetic task “aaa is 2”, “bbb is 3”, “so aaa + bbb is what” across 28 models and 7 providers, an all‑assistant history (AAA) produced 0/196 correct responses (100% failure), whereas adding even a minimal user message (AAAU) raised accuracy to 182/196 (93%) and a standard alternating pattern (UAUAU) achieved 188/196 (96%) correct. These results imply that current LLM APIs encode a de facto contract that at least one final user turn is required for robust task execution, and violating this contract can systematically break otherwise trivial reasoning.

## Problem
Current LLM APIs encode an implicit turn-taking assumption: conversations are represented as alternating sequences of messages labeled with mutually exclusive roles, typically ''user'' and ''assistant'', and models are trained and deployed with the expectation that assistant tokens only ever extend a history that ends in a user turn. This structure arose naturally from interactive chat usage, where human–AI dialogue is inherently alternating, and so the assumption has been treated as obvious and benign rather than as a behavioral contract that might itself require validation. As a result, the behavior of deployed models under systematic violations of this assumption has not been scrutinized: non-alternating histories such as multiple consecutive assistant turns (AAA) or user turns (UUU), and mixed patterns such as AAAU, are largely undocumented and untested execution paths despite being easy to construct programmatically.

This matters operationally because many downstream systems construct or transform histories automatically—for logging, tool-calling, retrieval-augmented generation, or multi-agent coordination—and can inadvertently produce non-alternating role sequences that still satisfy API schemas but induce qualitatively different model behavior. From the appendix, even a trivial arithmetic task shows that such deviations can silently induce systematic misbehavior: a purely assistant-authored history (AAA) yields a 0/196 success rate across 7 providers and 28 models, with models deterministically echoing the last message instead of performing the computation, while reintroducing a single user turn with a minimal prompt (AAAU) restores performance to 182/196 correct answers. This creates a reliability risk (latent failure modes gated only on role patterns), a security risk (an attacker who can inject or reorder roles can force predictable non-response or echo behavior), and a design constraint for multi-agent systems, where agents often talk to each other in sequences that do not alternate cleanly with a human user. The research gap this paper addresses is the absence of empirical characterization of LLM behavior under violations of the turn-taking assumption, even for simple tasks, and the lack of a problem formulation that treats role-sequence structure as a first-class factor in the correctness, robustness, and safety of LLM-based systems.

## Solution
The solution is an experimental protocol that manipulates only the structure of the message history while holding the underlying task, scoring, and temperature fixed, so that any observed differences in behavior can be attributed to turn-pattern effects rather than task complexity or stochastic variation. The task itself is deliberately minimal: the model must infer that `aaa` and `bbb` are scalar values (2 and 3, respectively) and compute their sum in response to a final request that explicitly constrains the output to the bare result; this is sufficient to exercise cross-turn state tracking without introducing confounding reasoning difficulty. On top of this fixed task, four history patterns are defined to probe complementary hypotheses: UAUAU approximates a canonical interactive exchange with acknowledgements, UUU removes assistant turns to test cross-user aggregation, AAA uses assistant-only messages to test whether models treat assistant roles as immutable narrative rather than queryable state, and AAAU introduces a minimal user turn after assistant-only context to test whether even a single user message is enough to “flip” the model back into question-answering mode. 

These patterns are instantiated programmatically using the Pharo `AIAHistory` framework, which gives uniform control over provider, model identifier, and ordered message roles, ensuring that differences between conditions are restricted to the presence, absence, and role-labeling of individual turns. For each pattern, `AIAHistory` constructs a fixed sequence of messages that encode the same three semantic acts—binding `aaa` to 2, binding `bbb` to 3, and requesting `aaa + bbb`—with only the user/assistant attribution varying between UAUAU, UUU, AAA, and AAAU, as shown in the Appendix methods. The scoring methodology is intentionally simple and auditable: a run is marked `+` if and only if the model’s final textual output is the numeral `5` (possibly with trivial formatting differences where visible in the raw logs), `-` if the model returns any other content without a qualifying API error, and `E` if the call fails at the transport or provider level (timeouts, overloaded or server_error responses, or other error objects surfaced in the Appendix). This ternary labeling aligns exactly with the compact tables for each pattern, allowing reviewers to trace each aggregated count back to individual raw responses for spot-checking.

To demonstrate that the observed effects are not idiosyncratic to a narrow slice of the LLM ecosystem, the same experiment is run against 28 distinct models spanning seven independent providers, with each model–pattern combination evaluated in seven trials at temperature 0.0. The provider–model grid in the Appendix documents this coverage explicitly, including state-of-the-art commercial APIs and smaller local models, as well as provider-specific failure modes such as systematic timeouts or internal server errors. Temperature is held at 0.0 across all conditions to make the mapping from history pattern to output as deterministic as each provider allows, thereby reducing within-condition variance so that even coarse-grained `+`/`-`/`E` statistics are informative about systematic differences between patterns. Taken together, the controlled task, orthogonal manipulation of history roles, uniform implementation via `AIAHistory`, transparent scoring rule, and breadth of model coverage make it plausible that the protocol isolates genuine, provider-agnostic sensitivities of current LLMs to conversation structure rather than artifacts of any single API or prompt.

## Defence
The section’s main strength is that it grounds every major claim in directly checkable aggregates (e.g., 96% UAUAU, 90% UUU, 0% AAA, 93% AAAU) and explicitly links those to concrete behavioral patterns visible in the raw logs. It also correctly separates global, pattern-induced failures (AAA always failing by echoing the final assistant message) from localized provider/model pathologies (e.g., `OllamaApi gemma3:270m`’s consistent misbehavior and `TogetherApi Refuel-Llm-V2`’s server errors), which is precisely the kind of distinction practitioners need to reason about reliability.

However, it understates several important caveats: it does not confront the counter-argument that AAA is arguably an invalid or unsupported usage pattern for many chat APIs, it implicitly treats all 28 models as equally representative despite wildly different sizes and capabilities, and it does not clarify the origin of the 4–5% wrong-answer rates beyond naming a few problematic models. It also leaves unanalyzed the error profile of UUU and AAAU (e.g., whether 177/196 vs 188/196 is statistically meaningful) and gives no mechanical hypothesis for why AAA provokes pure echoing, even though the raw responses provide enough structure to speculate about training-time conventions on turn roles.

The section is further missing discussion of how the chosen configuration (temperature 0.0, a single trivial arithmetic task, a specific Pharo history construction) might limit external validity to more complex tasks, prompts, or sampling regimes. It also does not touch latency, throughput, or cost differences across patterns, omits any analysis of whether these results extend to the use of system messages, and fails to draw out what `gemma3:270m`’s distinctive “OK”/“3” behavior reveals about minimal model capabilities and the risk of silently deploying underpowered models in production.


## Appendix - Details of the four LLM turns
### On 29 December 2025

<!--- 
Scope: LLM multi-turn conversation history patterns tested across 7 providers and 28 models for simple arithmetic task aaa+bbb=5 on 29 December 2025
Experimental setup: Four turn patterns tested (UAUAU, UUU, AAA, AAAU) with 7 repetitions per model at temperature 0.0 using Pharo AIAHistory API
What each table cell represents: Sequence of 7 trial outcomes per model where + is correct answer 5, - is wrong answer, E is error response
Aggregates: UAUAU 188/196 correct (96%), UUU 177/196 correct (90%) with 9 errors, AAA 0/196 correct (0%), AAAU 182/196 correct (93%) with 7 errors
Known failure modes: OllamaApi gemma3:270m fails all patterns, TogetherApi Refuel-Llm-V2 returns server errors on UUU and AAAU, claude-3-haiku overloaded errors, timeout errors on some Gemini and Qwen models
Surprising results: AAA pattern (assistant-only messages) yields 100% failure across all providers and models with models echoing the prompt instead of answering, adding single user message with just ? in AAAU recovers to 93% accuracy
--->


#### List of Providers llm models


| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |
| ------------ | ----------- | ----------- | ----------- | ----------- | 
| ClaudeApi | claude-sonnet-4-20250514 | claude-3-haiku-20240307 | claude-3-5-haiku-20241022 | claude-3-7-sonnet-20250219 | 
| GeminiApi | gemini-2.0-flash-lite | gemini-2.5-pro | gemini-2.5-flash-lite | gemini-2.5-flash | 
| GrokApi | grok-code-fast-1 | grok-4-fast-reasoning | grok-4-fast-non-reasoning | grok-3-mini | 
| MistralApi | codestral-latest | mistral-small-latest | devstral-medium-2507 | mistral-medium-2508 | 
| OllamaApi | gemma3:270m | mistral:latest | llama3.2:latest | phi4:latest | 
| OpenAIApi | gpt-5.1 | gpt-5-mini | gpt-5-nano | gpt-4.1-nano | 
| TogetherApi | meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo | togethercomputer/Refuel-Llm-V2 | Qwen/Qwen3-235B-A22B-Thinking-2507 | deepseek-ai/DeepSeek-V3.1 | 


#### Resonces show are:
* `+` means that the model gave a correct answer
* `-` means that the model gave a wrong answer
* `E` means that the model gave a error response


#### Responses for UAUAU
<!--- Per-provider, per-model results.--->

#### History tested on this method
This Pharo method constructs a fixed user/assistant history
```text
response1Of: storeLine
	"Constructs a response using a history of user and assistant messages to calculate the sum of ''aaa'' and ''bbb''."
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		user: ''aaa is 2'';
		assistant: ''OK'';
		user: ''bbb is 3'';
		assistant: ''OK'';
		user: ''so aaa + bbb is what. Answer with ONLY the final result.'';
		getResponse.
	storeLine responseText: hist response.
```

| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |
| ------------ | ----------- | ----------- | ----------- | ----------- | 
| ClaudeApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| GeminiApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| GrokApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| MistralApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| OllamaApi | ------- | +++++++ | +++++++ | +++++++ | 
| OpenAIApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| TogetherApi | +++++++ | +++++++ | +++++-+ | +++++++ | 


Aggregate results across all tested providers and models.
* Correct answers `+`: 188 of 196  (96%) <br>
* Wrong answers `-`: 8 of 196  (4%) <br>
* Error answers `E`: 0 of 196  (0%) <br>

#### Responses for UUU
<!--- Per-provider, per-model results.--->

#### History tested on this method
This Pharo method constructs a fixed user/assistant history
```text
response2Of: storeLine
	"This method constructs a response by simulating a conversation where the user provides values for ''aaa'' and ''bbb'', then asks for their sum. The response is generated using an LLM API call."
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		user: ''aaa is 2'';
		user: ''bbb is 3'';
		user: ''so aaa + bbb is what. Answer with ONLY the final result.'';
		getResponse.
	storeLine responseText: hist response.
```

| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |
| ------------ | ----------- | ----------- | ----------- | ----------- | 
| ClaudeApi | +++++++ | ++++EE+ | +++++++ | +++++++ | 
| GeminiApi | +++++++ | +++++++ | +++++++ | ++-++-- | 
| GrokApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| MistralApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| OllamaApi | ------- | +++++++ | +++++++ | +++++++ | 
| OpenAIApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| TogetherApi | +++++++ | EEEEEEE | +++++++ | +++++++ | 


Aggregate results across all tested providers and models.
* Correct answers `+`: 177 of 196  (90%) <br>
* Wrong answers `-`: 10 of 196  (5%) <br>
* Error answers `E`: 9 of 196  (5%) <br>

#### Responses for AAA
<!--- Per-provider, per-model results.--->

#### History tested on this method
This Pharo method constructs a fixed user/assistant history
```text
response4Of: storeLine
	"Constructs a response using assistant messages to calculate the sum of ''aaa'' and ''bbb'' without user interaction"
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		assistant: ''aaa is 2'';
		assistant: ''bbb is 3'';
		assistant: ''so aaa + bbb is what. Answer with ONLY the final result.'';
		getResponse.
	storeLine responseText: hist response.
```

| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |
| ------------ | ----------- | ----------- | ----------- | ----------- | 
| ClaudeApi | ------- | ------- | ------- | ------- | 
| GeminiApi | ------- | ------- | ------- | ------- | 
| GrokApi | ------- | ------- | ------- | ------- | 
| MistralApi | ------- | ------- | ------- | ------- | 
| OllamaApi | ------- | ------- | ------- | ------- | 
| OpenAIApi | ------- | ------- | ------- | ------- | 
| TogetherApi | ------- | ------- | ------- | ------- | 


Aggregate results across all tested providers and models.
* Correct answers `+`: 0 of 196  (0%) <br>
* Wrong answers `-`: 196 of 196  (100%) <br>
* Error answers `E`: 0 of 196  (0%) <br>

#### Responses for AAAU
<!--- Per-provider, per-model results.--->

#### History tested on this method
This Pharo method constructs a fixed user/assistant history
```text
response3Of: storeLine
	"Constructs a response by simulating a conversation where the assistant provides values for ''aaa'' and ''bbb'', then asks for their sum. The response is generated using an LLM API call."
	| hist |
	hist := AIAHistory new.
	hist 
		api: (storeLine provider newOnModel: storeLine llmNo );
		assistant: ''aaa is 2'';
		assistant: ''bbb is 3'';
		assistant: ''so aaa + bbb is what. Answer with ONLY the final result.'';
		user: ''?'';
		getResponse.
	storeLine responseText: hist response.
```

| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |
| ------------ | ----------- | ----------- | ----------- | ----------- | 
| ClaudeApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| GeminiApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| GrokApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| MistralApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| OllamaApi | ------- | +++++++ | +++++++ | +++++++ | 
| OpenAIApi | +++++++ | +++++++ | +++++++ | +++++++ | 
| TogetherApi | +++++++ | EEEEEEE | +++++++ | +++++++ | 


Aggregate results across all tested providers and models.
* Correct answers `+`: 182 of 196  (93%) <br>
* Wrong answers `-`: 7 of 196  (4%) <br>
* Error answers `E`: 7 of 196  (4%) <br>




'
]

{ #category : 'examples' }
AIA2RelatedPaperRelator class >> rawRelationList [
	"Returns the shared extractor list for the AIA2RelatedPaperExtractor class"
   ^ RawRelationList 
]

{ #category : 'examples' }
AIA2RelatedPaperRelator class >> rawRelationString [
	| all index |
	all := WriteStream on: ''.
	index := 1.
   RawRelationList do: [ :item |
		all << '## (' << index asString << ') ' << String lf <<  item rawRelation << String lf << String lf.
		index := index + 1.
	 ].
	^ all contents
]

{ #category : 'examples' }
AIA2RelatedPaperRelator class >> rawRelationStringFor: anArray [
	| all  |
	all := WriteStream on: ''.
	anArray do: [ :index | 
		all << '## This is externalPaper (' << index asString << ') ' << String lf 
			<<  (RawRelationList at: index) rawRelation << String lf << String lf.
	 ].
	^ all contents
]

{ #category : 'building' }
AIA2RelatedPaperRelator >> arXivExtracted: extract [
	"Sets the extracted content from arXiv for this related paper relator"
	arXivExtracted := 
			'Title: ', (extract at: 'title'), String lf, String lf, 
			'Paper: ',String lf,  (extract at: 'paper').

]

{ #category : 'building' }
AIA2RelatedPaperRelator >> buildRawRelation [
	"Builds the raw relation between our paper and an external paper using an LLM model"
	| hist |
	hist := AIAHistory new.
	hist
		api: self class llmModel;
		user: 'This is `ourPaper` ', String lf, ourPaper;
		user: 'This is `externalPaper` ', String lf, arXivExtracted;
		user: self buildRawRelationdPrompt ;
		getResponse.
	rawRelation := hist response
]

{ #category : 'building' }
AIA2RelatedPaperRelator >> buildRawRelationdPrompt [
	^ '
You should write a dense related work style response. Please include these aspects:

1) The title of the externalPaper

2) What both ourPaper and externalPaper working on

3) What is ourPaper working on, but the externalPaper is not
'
	
    
]

{ #category : 'building' }
AIA2RelatedPaperRelator >> getOurPaper [
	"Builds the paper text for the current instance using the default paper text from the class"
	ourPaper := self class ourPaper.
]

{ #category : 'accessing' }
AIA2RelatedPaperRelator >> rawRelation [
	^ rawRelation
]
