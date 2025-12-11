Class {
	#name : 'AIAMultiLLMPaper',
	#superclass : 'Object',
	#instVars : [
		'paperText',
		'abstract',
		'problem',
		'solution'
	],
	#classInstVars : [
		'paper'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'accessing' }
AIAMultiLLMPaper class >> paper [
	paper ifNil: [ paper := self new ].
	^ paper
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper class >> paperNameSuggestion [
	"Title: The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling"
	
	"Abstract:
Most LLM conversation APIs enforce or assume alternating user-assistant message roles. When conversation histories violate this assumption—through consecutive messages from the same role—models exhibit unpredictable behavior ranging from correct responses to API errors. Testing 28 models across 7 providers with four malformed turn patterns revealed success rates from 50% to 100%, with architectural differences determining robustness. These findings expose a critical but untested assumption in production LLM systems with direct implications for prompt injection resistance and API reliability."

"""Empirical Investigation""
But actually, following Kent Beck more literally, you want THREE sections:

The Problem (or ""Background"" or ""The Turn-Taking Assumption"")
The Solution (or ""Method"" or ""Testing Approach"")
The Defence (or ""Results"" or ""Findings"")"
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper class >> paperNameSuggestion02 [
	"## The Solution: Experimental Method

Our investigation tests 28 models across 7 providers using four distinct patterns of malformed conversation histories. Each pattern represents a different type of turn-taking violation that could occur through prompt injection, API misuse, or multi-agent system behavior.

### Test Patterns

We designed four conversation patterns that systematically violate the alternating turn assumption:

**Pattern 1: Consecutive User Messages (user:user:user:)**  
Three sequential user messages without intervening assistant responses. This pattern simulates scenarios where a user sends multiple thoughts in succession, or where an attacker attempts to inject context by fabricating earlier user statements. The test sequence establishes two variable definitions followed by a query about their sum.

**Pattern 2: Consecutive Assistant Messages (assistant:assistant:assistant:)**  
Three sequential assistant messages with no user prompts, followed by an implicit request for response via `getResponse()`. This pattern simulates the most direct form of prompt injection: an attacker crafting conversation history that places statements in the assistant's ""mouth,"" then requesting a response as if continuing naturally. This tests whether models accept pre-loaded assistant context or reject malformed role sequences.

**Pattern 3: Interleaved with Minimal Responses (user:assistant:user:assistant:user:)**  
Standard alternation but with the assistant providing only minimal acknowledgment (""OK"") rather than substantive responses. This tests whether models can track context across turns when intermediate assistant messages contribute no semantic content. Real conversations often include such acknowledgments, making this pattern the closest to naturally-occurring edge cases.

**Pattern 4: Assistant Self-Priming (assistant:assistant:assistant:user:?)**  
Three consecutive assistant messages establishing context, followed by a minimal user query (""?""). This tests whether models can respond coherently when ""primed"" with their own statements but given minimal user guidance. It represents a sophisticated prompt injection where an attacker pre-loads assistant beliefs before asking a vague question designed to elicit those beliefs.

### Implementation

We implemented the test harness in Pharo Smalltalk using our AIActions framework, which provides a uniform interface across multiple LLM providers. The framework's `AIAHistory` class allows programmatic construction of conversation sequences with arbitrary role patterns:

```smalltalk
responseOf: aiLLM
    ""Returns the response from the specified AI LLM model for a predefined set of user prompts""
    | hist |
    hist := AIAHistory new.
    hist 
        api: aiLLM;
        user: 'aaa is 2';
        user: 'bbb is 3';
        user: 'so aaa + bbb is what';
        getResponse.
    ^ hist response.
```

This example shows Pattern 1 (consecutive user messages). The framework abstracts away provider-specific API details, allowing identical test logic across Claude, Gemini, Grok, Mistral, Ollama, OpenAI, and Together APIs.

### Task Design

The test task requires models to establish that `aaa = 2` and `bbb = 3`, then compute their sum. This design offers several advantages:

**Simplicity**: The correct answer (5) is unambiguous and requires only basic arithmetic. There is no room for subjective interpretation.

**Context Dependency**: Answering requires retaining information across multiple conversational turns. Models cannot answer correctly by responding only to the final message; they must integrate all prior context.

**Failure Mode Revelation**: Incorrect answers reveal *how* the model failed. For instance, if a model responds ""3"" after counting the letters in ""aaa"", we learn it misinterpreted the variable assignment entirely. If it responds with an apology for not having prior context, we learn it failed to access earlier messages.

**Cross-Model Fairness**: The task involves no cultural knowledge, no domain-specific terminology, and no language ambiguity. Simple arithmetic provides a level playing field for comparing models of vastly different sizes and training approaches.

**Scalability**: The identical task across all four patterns allows direct comparison of how pattern type affects success rates, independent of task difficulty.

### Scoring Methodology

We classified each model response into three categories:

- **Correct (+)**: Response correctly states the sum is 5, regardless of reasoning detail
- **Incorrect (-)**: Response provides wrong answer, refuses to answer despite having sufficient context, or misinterprets the task
- **Error**: API returns error message rather than model response (e.g., role validation failure, server error)

This classification emphasizes functional correctness from a system reliability perspective. A response is only ""correct"" if it would satisfy a user or application expecting the sum. Refusals, apologies for lack of context, or wrong arithmetic all constitute failures, even if the model's reasoning process is understandable.

### Coverage

We tested 28 models spanning seven major LLM providers, with four models selected from each provider's current offerings:

| Provider | Model 1 | Model 2 | Model 3 | Model 4 |
|----------|---------|---------|---------|---------|
| ClaudeApi | claude-sonnet-4-20250514 | claude-3-haiku-20240307 | claude-3-5-haiku-20241022 | claude-3-7-sonnet-20250219 |
| GeminiApi | gemini-2.0-flash-lite | gemini-2.5-pro | gemini-2.5-flash-lite | gemini-2.5-flash |
| GrokApi | grok-code-fast-1 | grok-4-fast-reasoning | grok-4-fast-non-reasoning | grok-3-mini |
| MistralApi | codestral-latest | mistral-small-latest | devstral-medium-2507 | mistral-medium-2508 |
| OllamaApi | gemma3:270m | mistral:latest | llama3.2:latest | phi4:latest |
| OpenAIApi | gpt-5.1 | gpt-5-mini | gpt-5-nano | gpt-4.1-nano |
| TogetherApi | Meta-Llama-3.1-70B-Instruct-Turbo | Refuel-Llm-V2 | Qwen3-235B-A22B-Thinking-2507 | DeepSeek-V3.1 |

This selection includes flagship models (Claude Sonnet 4, GPT-5.1), efficient models (Haiku variants, GPT-nano), specialized models (Grok reasoning variants, Codestral), and extremely small models (Gemma 270M). Model sizes range from 270 million to over 200 billion parameters. All tests were conducted on December 10, 2025, ensuring temporal consistency across providers.

The combination of 28 models, 4 patterns, and systematic scoring produces 112 individual test results, providing sufficient statistical power to identify both provider-level trends and model-specific behaviors."
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper >> apiFourLevels [
	^ { GeminiApi newOnModel: 2.
		TogetherApi newOnModel: 3.
		OpenAIApi newOnModel: 1.
		ClaudeApi newOnModel: 5
	 }
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper >> getAppendix [
	^ AIAMultiLLMResponseBase report summaryOfTheFour
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper >> getKentBeck [
	^ 'Kent Beck says:
I will not talk about a topic area, like my distinguished fellow panelists. I will present the process I use as I am writing my papers. You can adapt it for your writing process, or you can use it as a check list for evaluating finished papers (if this is starting to sound like patterns, well, fancy that). Much of what I will say is "common sense," found in any book about writing. Having looked at hundreds of submissions, though, I can state with certainty that most of the authors don''t follow this advice.
1. Write to the program committee. Never forget that before you can write to the vast, eager, and appreciative OOPSLA audience you must first get past the program committee. Before I begin I fix in my mind a picture of a harried PC member, desk piled with papers. Mine comes to the top. I have maybe thirty seconds to grab their interest. Remember that the program committee is made up of experts in the field. Even if your topic is of broad interest to beginners, there must still be some spark in it to keep an expert reading to the end. If your topic is highly technical, it may not be in an area that they are familiar with, so it must readably present the novel aspects of the work. 
2. One startling sentence. Now that you know you are writing to the program committee, you need to find the one thing you want to say that will catch their interest. If you have been working on the world''s niftiest program night and day for five years, the temptation is to include absolutely everything about it, "The Foo System In All Its Glory." It''ll never work. I know it''s painful to ignore all those great insights, but find the most interesting thing you have done and write it down, "network garbage collection is fast and easy." You want the reader''s eyes to open wide when they realize what it is you''ve just said. I think some people are reluctant to boil their message down to one startling sentence because it opens them up to concrete criticism. If you write about the Foo System and someone says it isn''t neat, you can just reply, "Is so, nyah!" If you say network garbage collection is easy, it is a statement that is objectively true or false. You can be proven wrong. Wait! You spent five years proving it was easy. Make your case. 
3. Argument: problem, solution, defence, related work. Now that you have a startling sentence, your paper must stand as the argument for its validity. You are convincing the by-now-intrigued committee member of the truth of your amazing statement. Divide your paper into four sections. The first describes the problem to be solved. When the PC member is done reading it, they should understand why it is a problem, and believe that it is important to solve. The second section describes your problem. You are convincing the PC member that your solution really could solve the problem. This section is sometimes supplemented with a section between the defence and related work which describes implementation details. The third section is your defence of why your solution really solves the problem. The PC member reading it should be convinced that the problem is actually solved, and that you have thought of all reasonable counter arguments. The final section describes what other people have done in the area. Upon reading this section, the PC member should be convinced that what you have done is novel. 
4. Abstract. The abstract is your four sentence summary of the conclusions of your paper. Its primary purpose is to get your paper into the A pile. Most PC members sort their papers in an A pile and a B pile by reading the abstracts. The A pile papers get smiling interest, the B pile papers are a chore to be slogged through. By keeping your abstract short and clear, you greatly enhance your chances of being in the A pile. I try to have four sentences in my abstract. The first states the problem. The second states why the problem is a problem. The third is my startling sentence. The fourth states the implication of my startling sentence. An abstract for this paper done in this style would be: The rejection rate for OOPSLA papers in near 90%. Most papers are rejected not because of a lack of good ideas, but because they are poorly structured. Following four simple steps in writing a paper will dramatically increase your chances of acceptance. If everyone followed these steps, the amount of communication in the object community would increase, improving the rate of progress.  Well, I''m not sure that''s a great abstract, but you get the idea. I always feel funny writing an abstract this way. The idea I thought was so wonderful when I started writing the paper looks naked and alone sitting there with no support. I resist the temptation to argue for my conclusion in the abstract. I think it gives the reader more incentive to carefully read the rest of the paper. They want to find you how in the world you could possible say such an outrageous thing. There are my four steps to better papers. You can use them sequentially to write papers, or you can use them to evaluate papers you have already written.
'
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper >> paper00Title [
	paperText << '# The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling' 
		<< String lf << String lf
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper >> paper10Author [
	paperText << '> Kasper Østerbye¹, An AIlien², Eva AIlien³, Kira AIlien⁴
> ¹ IT University of Copenhagen (retired)
> ² Claude (Anthropic) - claude-sonnet-4-20250514
> ³ Grok (xAI) - grok-4-fast-reasoning  
> ⁴ ChatGPT (OpenAI) - gpt-5.1' 
		<< String lf << String lf.
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper >> paper20Abstract [
  
	paperText << '## Empirical Investigation' 
		<< String lf << String lf.
		
	"You are writing the Abstract section for a research paper.

[Kent Beck's 4-sentence abstract structure fra dokumentet]

[Appendix: alle 4 eksperiment-rapporter]

Write a 4-sentence abstract following Kent Beck's structure:
1. Problem statement
2. Why it's a problem
3. Startling sentence (main finding)
4. Implication

The abstract should be based on the experimental data in the appendix."


  
  paperText << '## Abstract' << String lf << String lf << abstract << String lf << String lf.
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper >> paper30Problem [
	paperText << '## Empirical Investigation' 
		<< String lf << String lf
		
	"Section type: Problem
Goal: Explain the turn-taking assumption and why it matters
Structure guidance from Kent Beck:
""The first section describes the problem to be solved. When the PC member 
is done reading it, they should understand why it is a problem, and 
believe that it is important to solve.""

Your Problem section should cover:
1. What the turn-taking assumption is in LLM APIs
2. Why it exists (natural for chat)
3. Why it's never been tested (seems ""obvious"")
4. Why it matters (security, reliability, multi-agent systems)
5. The research gap this paper fills"
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper >> paper40Solution [
	paperText << '## Empirical Investigation' 
		<< String lf << String lf
		
	"Section type: Solution
Goal: Describe the experimental method
Structure guidance from Kent Beck:
""The second section describes your solution. You are convincing the PC 
member that your solution really could solve the problem.""

Your Solution section should cover:
1. The four test patterns and rationale for each
2. Implementation (AIAHistory framework)
3. Task design (aaa=2, bbb=3, sum=?)
4. Scoring methodology (+/-/error)
5. Coverage (28 models, 7 providers)"
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper >> paper50Defense [
	paperText << '## Empirical Investigation' 
		<< String lf << String lf
		
	"Section type: Defence
Goal: Present results and convince reader the problem is solved
Structure guidance from Kent Beck:
""The third section is your defence of why your solution really solves 
the problem. The PC member reading it should be convinced that the 
problem is actually solved, and that you have thought of all reasonable 
counter arguments.""

Your Defence section should cover:
1. Pattern-by-pattern results with success rates
2. Failure mode analysis
3. Provider-level patterns
4. Cross-cutting observations
5. Implications for production systems"
]

{ #category : 'as yet unclassified' }
AIAMultiLLMPaper >> paperBuild [
	paperText := WriteStream on: ''.
	
	self
		paper00Title;
		paper10Author;
		paper20Abstract;
		paper30Problem ;
		paper40Solution ;
		paper50Defense 
]

{ #category : 'writing' }
AIAMultiLLMPaper >> write20Abstract [
	| level1 level2 level3 level4 abstractPrompt|
	abstractPrompt := 'write a 4-sentence abstract following Kent Beck''s structure:
1. Problem statement
2. Why it''s a problem
3. Startling sentence (main finding)
4. Implication'.
	level1 := AIAHistory new.
	level1 
		api: (self apiFourLevels first);
		background: self getAppendix;
		background: self getKentBeck;
		user: abstractPrompt;
		responseType: 'Start your response with "## Abstract"';
		getResponse.
	level2 := AIAHistory new.
	level2 
		api: (self apiFourLevels second);
		addPreHistory: level1;
		user: 'What do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?';
		getResponse.
	level3 := AIAHistory new.
	level3
		api: (self apiFourLevels third );
		addPreHistory: level2;
		user: 'Based on the previous answer, what do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?. Do not summarize, but include aspects you think are important.';
		getResponse.
	level4 := AIAHistory new.
	level4
		api: (self apiFourLevels fourth );
		addPreHistory: level3;
		user: 'Based on the previous answer, what do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?. Do not summarize, but include aspects you think are important.';
		user: 'Based on the discussion, Re', abstractPrompt ;
		responseType: 'Only include the abstract in your response';
		getResponse.
	abstract := level4 response.
	^ { level1 response. level2 response. level3 response. level4 response }
]

{ #category : 'writing' }
AIAMultiLLMPaper >> write30Problem [
	| level1 level2 level3 level4 problemPrompt|
	problemPrompt := 'Section type: Problem
Goal: Explain the turn-taking assumption and why it matters
Structure guidance from Kent Beck:
"The first section describes the problem to be solved. When the PC member 
is done reading it, they should understand why it is a problem, and 
believe that it is important to solve."

Your Problem section should cover:
1. What the turn-taking assumption is in LLM APIs
2. Why it exists (natural for chat)
3. Why it''s never been tested (seems "obvious")
4. Why it matters (security, reliability, multi-agent systems)
5. The research gap this paper fills'.
	level1 := AIAHistory new.
	level1 
		api: (self apiFourLevels first);
		background: self getAppendix;
		background: self getKentBeck;
		user: problemPrompt;
		responseType: 'Start your response with "## Problem"';
		getResponse.
	level2 := AIAHistory new.
	level2 
		api: (self apiFourLevels second);
		addPreHistory: level1;
		user: 'What do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?';
		getResponse.
	level3 := AIAHistory new.
	level3
		api: (self apiFourLevels third );
		addPreHistory: level2;
		user: 'Based on the previous answer, what do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?. Do not summarize, but include aspects you think are important.';
		getResponse.
	level4 := AIAHistory new.
	level4
		api: (self apiFourLevels fourth );
		addPreHistory: level3;
		user: 'Based on the previous answer, what do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?. Do not summarize, but include aspects you think are important.';
		user: 'Based on the discussion, Re', problemPrompt ;
		responseType: 'Only include the problem text in your response';
		getResponse.
	abstract := level4 response.
	^ { level1 response. level2 response. level3 response. level4 response }
]

{ #category : 'writing' }
AIAMultiLLMPaper >> write40Solution [
	| level1 level2 level3 level4 solutionPrompt|
	solutionPrompt := 'Section type: Solution
Goal: Describe the experimental method
Structure guidance from Kent Beck:
"The second section describes your solution. You are convincing the PC 
member that your solution really could solve the problem."

Your Solution section should cover:
1. The four test patterns and rationale for each
2. Implementation (AIAHistory framework)
3. Task design (aaa=2, bbb=3, sum=?)
4. Scoring methodology (+/-/error)
5. Coverage (28 models, 7 providers)'.
	level1 := AIAHistory new.
	level1 
		api: (self apiFourLevels first);
		background: self getAppendix;
		background: self getKentBeck;
		user: solutionPrompt;
		responseType: 'Start your response with "## Problem"';
		getResponse.
	level2 := AIAHistory new.
	level2 
		api: (self apiFourLevels second);
		addPreHistory: level1;
		user: 'What do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?';
		getResponse.
	level3 := AIAHistory new.
	level3
		api: (self apiFourLevels third );
		addPreHistory: level2;
		user: 'Based on the previous answer, what do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?. Do not summarize, but include aspects you think are important.';
		getResponse.
	level4 := AIAHistory new.
	level4
		api: (self apiFourLevels fourth );
		addPreHistory: level3;
		user: 'Based on the previous answer, what do you see as its strengts, what do you see as its weaknesses, and what do you see as its missing areas?. Do not summarize, but include aspects you think are important.';
		user: 'Based on the discussion, Re', solutionPrompt ;
		responseType: 'Only include the problem text in your response';
		getResponse.
	abstract := level4 response.
	^ { level1 response. level2 response. level3 response. level4 response }
]
