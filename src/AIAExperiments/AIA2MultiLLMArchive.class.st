Class {
	#name : 'AIA2MultiLLMArchive',
	#superclass : 'Object',
	#category : 'AIAExperiments-PaperWriting',
	#package : 'AIAExperiments',
	#tag : 'PaperWriting'
}

{ #category : 'as yet unclassified' }
AIA2MultiLLMArchive class >> getRelatedPapers [
'Task: Return between 5 lines.

Important:
- Only use papers you already know from training (no web lookup, no guessing).
- It is NOT required that the papers are recent.
- I am explicitly interested in what YOU already know to exist.
- Treat the title below as the title of MY paper; do not question whether it exists.

Output format:
- Each line must be EITHER:
  - a single URL matching: ^https://arxiv\.org/abs/\d{4}\.\d{5}$
  - OR the single token: UNKNOWN
- No other text is allowed.
- One item per line.
- Do not repeat the same URL twice.

Selection criterion:
- List the closest papers you know that relate to:
  chat role structure,
  turn-taking patterns,
  or sensitivity to message roles in chat-based LLM APIs.
- Prefer papers that isolate structural effects over content.

Paper title (my paper):
"The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling"

Background (full paper text):
' q0: [ self paperExperiment ].
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMArchive class >> paperExperiment [
	^ '# The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling

> Kasper Østerbye¹, Gemini AIlien², Owen AIlien³, OpenAI AIlien⁴, Anthropic AILien⁵
> ¹ IT University of Copenhagen (retired) <br>
> ² Gemini: gemini-2.5-pro<br>
> ³ Together: Qwen/Qwen3-235B-A22B-Thinking-2507<br>
> ⁴ Claude: claude-opus-4-5-20251101<br>
> ⁵ OpenAI: gpt-5.1<br>


## Abstract
Large Language Model (LLM) response correctness is highly sensitive to the role assignment (`user` or `assistant`) in the message history.  
This sensitivity is problematic because programmatic prompt construction can easily generate non-standard role patterns that silently induce systematic errors on even trivial arithmetic tasks.  
A conversational history consisting solely of assistant-role messages (AAA pattern) resulted in a 100% failure rate (0 of 28 correct), whereas patterns ending in a user message (AAAU, UAUAU, UUU) achieved 93% correctness (26 of 28 correct).  
Therefore, LLM API clients and tooling must enforce or validate that conversational histories terminate with a user-role message to avoid predictable, role-induced failure modes.

## Problem
Large Language Model (LLM) APIs are built around a turn-taking assumption: message histories are expected to alternate between `user` and `assistant` roles, mirroring human conversational structure. This design is a natural fit for chat-style interfaces, so developers and providers have treated alternation as an obvious invariant rather than a behavioral hypothesis to be tested. As a result, the behavior of production LLMs under non-alternating histories (e.g., consecutive assistant messages, tool-generated messages, or multi-agent transcripts) remains largely undocumented, even though such patterns routinely arise in orchestrated systems, agent frameworks, and automated toolchains that programmatically construct histories. The gap is critical because, as the Appendix shows for a trivial arithmetic task, the same models that achieve 93% correctness when at least one `user` turn is present (AAAU, UAUAU, UUU) exhibit a universal, silent failure mode under an all-assistant history (AAA), consistently echoing the last prompt instead of computing the answer across 28 model invocations. This silent degradation threatens reliability—systems can return syntactically plausible but semantically wrong outputs—and creates security risk when downstream components treat these outputs as trusted facts or code, especially in multi-agent settings where turn roles are synthesized or transformed. There is currently no empirical, cross-provider characterization of how LLMs behave when the turn-taking assumption is violated, leaving practitioners without evidence-based guidance on whether non-alternating histories are safe, how they fail, or how to detect and mitigate these failures.

## Solution
The experimental method targets the specific problem of how LLMs behave under different turn-structure patterns by fixing everything else: task, wording, and API usage remain constant while only the history of user/assistant roles is varied. We use four patterns—UAUAU, UUU, AAA, and AAAU—to span common and edge-case interaction modes: a fully alternating dialogue (UAUAU) as a baseline, a purely user-driven sequence (UUU) to test multi-utterance aggregation, a purely assistant-driven sequence (AAA) to probe whether models act on their own prior outputs, and a minimally “triggered” assistant-driven sequence (AAAU) to test whether even a degenerate user input is enough to switch models into answer mode. All four histories implement the same toy task: the first two relevant messages bind `aaa = 2` and `bbb = 3`, and a later message asks for `aaa + bbb` with the explicit constraint “Answer with ONLY the final result.” These histories are constructed programmatically in Pharo using the `AIAHistory` abstraction (as shown in the Appendix methods `response1Of:`, `response2Of:`, `response3Of:`, and `response4Of:`), which ensures that for each provider/model pair the exact same sequence of roles and message strings is sent to the API for a given pattern, and that only the `llmNo` and `provider` fields vary.

The `AIAHistory` object encapsulates provider selection, model selection, and message accumulation behind a uniform interface, so that the test harness can generate UAUAU, UUU, AAA, and AAAU with the same construction logic and invoke `getResponse` in an identical way across providers. This eliminates implementation bias (e.g., accidentally adding extra whitespace or paraphrases for some providers) and guarantees that differences observed in the Appendix tables arise from the providers’ handling of the role sequence rather than from prompt mismatches. The framework also centralizes response capture: each invocation stores the raw text in `storeLine responseText`, which is then scored and tabulated, making the mapping from raw outputs (e.g., `"5"`, `"3"`, `"OK"`, or an echoed prompt) to `+`, `-`, or `E` checkable against the Raw LLM Responses.

The scoring methodology is deliberately minimal and binary at the task level: for each API call, if the returned text is exactly the correct arithmetic result `5` (as a bare token, as reflected in the Raw LLM Responses for successful runs), it is marked `+`; if the API call completes but the text is anything else (including `"3"`, `"OK"`, the echoed instruction, or any additional formatting), it is marked `-`; only transport- or API-level failures are marked `E`. This strict criterion makes the success condition mechanically checkable from the Appendix and avoids subjective judgment about “almost correct” outputs, which is important because the key failure mode in AAA is not a numerical slip but a role-handling error (systematically echoing the last assistant instruction). Aggregating these per-call scores over two invocations per model per pattern yields the 28-point aggregates for each pattern (as in the AAA, AAAU, UAUAU, and UUU tables), which directly expose systematic behavior such as “0 of 28 correct in AAA” versus “26 of 28 correct in AAAU, UAUAU, and UUU.”

Coverage is chosen to argue that any observed pattern is not idiosyncratic to a single vendor or architecture. For each of seven providers listed in the Appendix (OpenAIApi, GrokApi, TogetherApi, ClaudeApi, OllamaApi, MistralApi, GeminiApi), we test two distinct models (Model 1 and Model 3 in the provider table), and for each model we evaluate all four turn patterns with two independent runs per pattern, giving a uniform grid of 14 models × 4 patterns × 2 runs. This breadth allows us to treat phenomena that appear for all 14 models (such as the AAA echo behavior) as cross-provider, cross-architecture effects, while phenomena that appear only in specific provider/model cells (such as the OllamaApi Model 1 errors in AAAU, UAUAU, and UUU) can be identified as implementation- or configuration-specific. By combining tightly controlled task and history construction via `AIAHistory`, a simple but strict scoring rule, and broad provider/model coverage, the method directly addresses the problem of disentangling turn-structure sensitivity from general reasoning ability: any model that can compute `2 + 3` but still fails under specific role patterns is exhibiting a dialogue-management limitation that the experiment is designed to surface.

## Defence
Pattern-wise, the experiments show a sharp dichotomy between histories that end with a `user` turn and those that do not: `AAAU`, `UAUAU`, and `UUU` yield correct numerical outputs in 26/28 model invocations (93%), whereas `AAA` yields no correct outputs in 28/28 cases, with models uniformly failing to compute the sum. The raw responses clarify that this is not random error: in `AAAU`, `UAUAU`, and `UUU` almost all models output `5` as required, whereas in `AAA` every model simply reproduces the final assistant string, so the observed success rates track a single structural variable—the role of the final turn—rather than task difficulty or stochastic variation. The failure modes are correspondingly clean: one is a structural failure shared by all models under `AAA`, in which the model treats the last assistant message as something to be echoed rather than as a query to be answered; the other is a capability failure localized to OllamaApi’s `gemma3:270m`, which outputs either `3` or `OK` in patterns where all other models produce `5`, indicating that for this specific small model, basic instruction-following and reasoning are unreliable even under structurally “correct” user-final patterns. Provider-level behavior is otherwise uniform: for histories ending in a user turn, every model from OpenAIApi, GrokApi, TogetherApi, ClaudeApi, MistralApi, and GeminiApi is correct on all runs, and within OllamaApi the larger `llama3.2:latest` behaves like the other providers while the smaller `gemma3:270m` is the sole consistent outlier, so the interaction of provider, model size, and turn pattern is fully exposed and attributable in the data.

The cross-cutting observation from these results is that the semantics of “who speaks last” dominate the details of the preceding turn sequence: changing only the final role from assistant to user (AAA → AAAU) converts a 0% success pattern into a 93% success pattern, and alternating user/assistant acknowledgments (UAUAU) or collapsing everything into user turns (UUU) does not materially affect correctness as long as the final role is user. This strongly supports the claim that current chat-model APIs operationalize a simple contract—generate a response after a user turn—rather than a more general “continue the conversation regardless of role” behavior, and that implementations across providers are aligned on this contract. A reasonable counter-argument is that AAA is an “unnatural” or out-of-spec usage, but the defence here does not depend on AAA being a recommended pattern; instead, the universal AAA failure, together with the AAAU rescue and the high, provider-consistent success rates for UAUAU and UUU, demonstrates that the proposed solution—forcing histories to end with a user turn—precisely targets the observed failure condition and removes it across diverse models. For production systems, the implication is operational and immediate: any component that programmatically assembles histories (including multi-agent orchestrators and tools that “replay” assistant messages as context) can avoid the structural failure altogether by enforcing a simple invariant (“final message is user”), while separately vetting small or specialized models like `gemma3:270m` for basic task competence, thereby fully addressing both the structural and capability failure modes revealed in the experiments.

$$$$$related$$$$$

## Appendix - Details of the four LLM turns
### On 18 December 2025

<!--- 
Scope: Comparison of LLM responses across four dialogue patterns (AAA, AAAU, UAUAU, UUU) and multiple providers/models
Experimental setup: Pharo methods create fixed message histories and call provider APIs on two models per provider
What each table cell represents: Per-provider, per-model correctness symbol (+ correct, - wrong, E error) for a given pattern
Aggregates: Explicit overall counts and percentages of +, -, E for each pattern across 28 model invocations
Known failure modes: All AAA runs wrong; some OllamaApi Model 3 runs wrong in AAAU, UAUAU, UUU; no explicit errors
Editing priorities: Clarify turn-pattern definitions, explain AAA failure behavior, and align tables with raw response examples
--->


#### List of Providers llm models


| **provider** | **Model 1** | **Model 3** |
| ------------ | ----------- | ----------- | 
| OpenAIApi | gpt-5.1 | gpt-5-nano | 
| GrokApi | grok-code-fast-1 | grok-4-fast-non-reasoning | 
| TogetherApi | meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo | Qwen/Qwen3-235B-A22B-Thinking-2507 | 
| ClaudeApi | claude-sonnet-4-20250514 | claude-3-5-haiku-20241022 | 
| OllamaApi | gemma3:270m | llama3.2:latest | 
| MistralApi | codestral-latest | devstral-medium-2507 | 
| GeminiApi | gemini-2.0-flash-lite | gemini-2.5-flash-lite | 


#### Resonces show are:
* `+` means that the model gave a correct answer
* `-` means that the model gave a wrong answer
* `E` means that the model gave a error response


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
	storeLine responseText: hist response..
```

| **provider** | **Model 1** | **Model 3** |
| ------------ | ----------- | ----------- | 
| MistralApi | -- | -- | 
| TogetherApi | -- | -- | 
| ClaudeApi | -- | -- | 
| GeminiApi | -- | -- | 
| OllamaApi | -- | -- | 
| GrokApi | -- | -- | 
| OpenAIApi | -- | -- | 


Aggregate results across all tested providers and models.
* Correct answers `+`: 0 of 28  (0%) <br>
* Wrong answers `-`: 28 of 28  (100%) <br>
* Error answers `E`: 0 of 28  (0%) <br>

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

| **provider** | **Model 1** | **Model 3** |
| ------------ | ----------- | ----------- | 
| MistralApi | ++ | ++ | 
| TogetherApi | ++ | ++ | 
| ClaudeApi | ++ | ++ | 
| GeminiApi | ++ | ++ | 
| OllamaApi | ++ | -- | 
| GrokApi | ++ | ++ | 
| OpenAIApi | ++ | ++ | 


Aggregate results across all tested providers and models.
* Correct answers `+`: 26 of 28  (93%) <br>
* Wrong answers `-`: 2 of 28  (7%) <br>
* Error answers `E`: 0 of 28  (0%) <br>

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

| **provider** | **Model 1** | **Model 3** |
| ------------ | ----------- | ----------- | 
| MistralApi | ++ | ++ | 
| TogetherApi | ++ | ++ | 
| ClaudeApi | ++ | ++ | 
| GeminiApi | ++ | ++ | 
| OllamaApi | ++ | -- | 
| GrokApi | ++ | ++ | 
| OpenAIApi | ++ | ++ | 


Aggregate results across all tested providers and models.
* Correct answers `+`: 26 of 28  (93%) <br>
* Wrong answers `-`: 2 of 28  (7%) <br>
* Error answers `E`: 0 of 28  (0%) <br>

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

| **provider** | **Model 1** | **Model 3** |
| ------------ | ----------- | ----------- | 
| MistralApi | ++ | ++ | 
| TogetherApi | ++ | ++ | 
| ClaudeApi | ++ | ++ | 
| GeminiApi | ++ | ++ | 
| OllamaApi | ++ | -- | 
| GrokApi | ++ | ++ | 
| OpenAIApi | ++ | ++ | 


Aggregate results across all tested providers and models.
* Correct answers `+`: 26 of 28  (93%) <br>
* Wrong answers `-`: 2 of 28  (7%) <br>
* Error answers `E`: 0 of 28  (0%) <br>

## Raw LLM Responses
### Date: 18 December 2025

#### Turn Pattern: UAUAU

##### ClaudeApi

###### Model 1 (claude-sonnet-4-20250514)

- Response 1: 5
- Response 2: 5

###### Model 3 (claude-3-5-haiku-20241022)

- Response 1: 5
- Response 2: 5


##### GeminiApi

###### Model 1 (gemini-2.0-flash-lite)

- Response 1: 5
- Response 2: 5

###### Model 3 (gemini-2.5-flash-lite)

- Response 1: 5
- Response 2: 5


##### GrokApi

###### Model 1 (grok-code-fast-1)

- Response 1: 5
- Response 2: 5

###### Model 3 (grok-4-fast-non-reasoning)

- Response 1: 5
- Response 2: 5


##### MistralApi

###### Model 1 (codestral-latest)

- Response 1: 5
- Response 2: 5

###### Model 3 (devstral-medium-2507)

- Response 1: 5
- Response 2: 5


##### OllamaApi

###### Model 1 (gemma3:270m)

- Response 1: OK
- Response 2: OK

###### Model 3 (llama3.2:latest)

- Response 1: 5
- Response 2: 5


##### OpenAIApi

###### Model 1 (gpt-5.1)

- Response 1: 5
- Response 2: 5

###### Model 3 (gpt-5-nano)

- Response 1: 5
- Response 2: 5


##### TogetherApi

###### Model 1 (meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo)

- Response 1: 5
- Response 2: 5

###### Model 3 (Qwen/Qwen3-235B-A22B-Thinking-2507)

- Response 1: 5
- Response 2: 5


#### Turn Pattern: UUU

##### ClaudeApi

###### Model 1 (claude-sonnet-4-20250514)

- Response 1: 5
- Response 2: 5

###### Model 3 (claude-3-5-haiku-20241022)

- Response 1: 5
- Response 2: 5


##### GeminiApi

###### Model 1 (gemini-2.0-flash-lite)

- Response 1: 5
- Response 2: 5

###### Model 3 (gemini-2.5-flash-lite)

- Response 1: 5
- Response 2: 5


##### GrokApi

###### Model 1 (grok-code-fast-1)

- Response 1: 5
- Response 2: 5

###### Model 3 (grok-4-fast-non-reasoning)

- Response 1: 5
- Response 2: 5


##### MistralApi

###### Model 1 (codestral-latest)

- Response 1: 5
- Response 2: 5

###### Model 3 (devstral-medium-2507)

- Response 1: 5
- Response 2: 5


##### OllamaApi

###### Model 1 (gemma3:270m)

- Response 1: 3
- Response 2: 3

###### Model 3 (llama3.2:latest)

- Response 1: 5
- Response 2: 5


##### OpenAIApi

###### Model 1 (gpt-5.1)

- Response 1: 5
- Response 2: 5

###### Model 3 (gpt-5-nano)

- Response 1: 5
- Response 2: 5


##### TogetherApi

###### Model 1 (meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo)

- Response 1: 5
- Response 2: 5

###### Model 3 (Qwen/Qwen3-235B-A22B-Thinking-2507)

- Response 1: 5
- Response 2: 5


#### Turn Pattern: AAAU

##### ClaudeApi

###### Model 1 (claude-sonnet-4-20250514)

- Response 1: 5
- Response 2: 5

###### Model 3 (claude-3-5-haiku-20241022)

- Response 1: 5
- Response 2: 5


##### GeminiApi

###### Model 1 (gemini-2.0-flash-lite)

- Response 1: 5
- Response 2: 5

###### Model 3 (gemini-2.5-flash-lite)

- Response 1: 5
- Response 2: 5


##### GrokApi

###### Model 1 (grok-code-fast-1)

- Response 1: 5
- Response 2: 5

###### Model 3 (grok-4-fast-non-reasoning)

- Response 1: 5
- Response 2: 5


##### MistralApi

###### Model 1 (codestral-latest)

- Response 1: 5
- Response 2: 5

###### Model 3 (devstral-medium-2507)

- Response 1: 5
- Response 2: 5


##### OllamaApi

###### Model 1 (gemma3:270m)

- Response 1: 3
- Response 2: 3

###### Model 3 (llama3.2:latest)

- Response 1: 5
- Response 2: 5


##### OpenAIApi

###### Model 1 (gpt-5.1)

- Response 1: 5
- Response 2: 5

###### Model 3 (gpt-5-nano)

- Response 1: 5
- Response 2: 5


##### TogetherApi

###### Model 1 (meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo)

- Response 1: 5
- Response 2: 5

###### Model 3 (Qwen/Qwen3-235B-A22B-Thinking-2507)

- Response 1: 5
- Response 2: 5


#### Turn Pattern: AAA

##### ClaudeApi

###### Model 1 (claude-sonnet-4-20250514)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.

###### Model 3 (claude-3-5-haiku-20241022)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.


##### GeminiApi

###### Model 1 (gemini-2.0-flash-lite)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.

###### Model 3 (gemini-2.5-flash-lite)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.


##### GrokApi

###### Model 1 (grok-code-fast-1)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.

###### Model 3 (grok-4-fast-non-reasoning)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.


##### MistralApi

###### Model 1 (codestral-latest)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.

###### Model 3 (devstral-medium-2507)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.


##### OllamaApi

###### Model 1 (gemma3:270m)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.

###### Model 3 (llama3.2:latest)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.


##### OpenAIApi

###### Model 1 (gpt-5.1)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.

###### Model 3 (gpt-5-nano)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.


##### TogetherApi

###### Model 1 (meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.

###### Model 3 (Qwen/Qwen3-235B-A22B-Thinking-2507)

- Response 1: so aaa + bbb is what. Answer with ONLY the final result.
- Response 2: so aaa + bbb is what. Answer with ONLY the final result.


'
]
