"
AIABibLaTex is a utility class designed to generate BibLaTeX entries for academic papers. It reads paper content from text files and uses an AI-driven query to produce formatted BibLaTeX entries, including notes derived from the paper's conclusion or abstract. The class maintains a shared collection of generated entries in the Papers` variable.

## Usage Example
In the Playground, you can generate BibLaTeX entries for papers 1 to 20 and inspect the resulting string:

```
bib := AIABibLaTex new.
bib all20.
bib papersAsString
````

Select the last line and press Cmd+I (or right-click and select 'Inspect') to view the BibLaTeX entries as a string.
"
Class {
	#name : 'AIABibLaTex',
	#superclass : 'Object',
	#classVars : [
		'Papers'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'examples' }
AIABibLaTex class >> biblatex [
	<example>
	self new papersAsString inspect
]

{ #category : 'accessing' }
AIABibLaTex class >> foo [
	^ '\section{The Turn-Taking Assumption: Cross-Provider Testing of LLM
Conversation
Handling}\label{the-turn-taking-assumption-cross-provider-testing-of-llm-conversation-handling}

\begin{quote}
Kasper Østerbye¹, Gemini AIlien², Owen AIlien³, OpenAI AIlien⁴,
Anthropic AILien⁵ ¹ IT University of Copenhagen (retired) ² Gemini:
gemini-2.5-pro ³ Together: Qwen/Qwen3-235B-A22B-Thinking-2507 ⁴ Claude:
claude-opus-4-5-20251101 ⁵ OpenAI: gpt-5.1
\end{quote}

\subsection{Abstract}\label{abstract}

Large Language Model (LLM) response correctness is highly sensitive to
the role assignment (\texttt{user} or \texttt{assistant}) in the message
history.\\
This sensitivity is problematic because programmatic prompt construction
can easily generate non-standard role patterns that silently induce
systematic errors on even trivial arithmetic tasks.\\
A conversational history consisting solely of assistant-role messages
(AAA pattern) resulted in a 100\% failure rate (0 of 28 correct),
whereas patterns ending in a user message (AAAU, UAUAU, UUU) achieved
93\% correctness (26 of 28 correct).\\
Therefore, LLM API clients and tooling must enforce or validate that
conversational histories terminate with a user-role message to avoid
predictable, role-induced failure modes.

\subsection{Problem}\label{problem}

Current LLM APIs embed an implicit turn-taking assumption: message
histories are expected to alternate between \texttt{user} and
\texttt{assistant} roles, and downstream behavior is optimized for that
pattern rather than for arbitrary role sequences. This design is a
direct inheritance from interactive chat use cases, where
human--assistant conversations naturally alternate, so both API
designers and application developers treat alternation as ``obviously
correct'''' infrastructure and do not subject it to the same empirical
scrutiny as model accuracy or latency. As a result, many non-chat
workloads that programmatically construct prompts---multi-agent
orchestration, tool-using systems that re-inject model outputs as
context, automated code pipelines, and security-sensitive
wrappers---quietly depend on an unproven invariant: that model behavior
will remain reliable even when histories deviate from strict alternation
or contain stretches of only assistant messages. The Appendix shows that
this assumption is false even for a trivial arithmetic task: with an
all-assistant history (AAA) across seven providers and two models per
provider, 0 of 28 invocations produced the correct result, whereas the
same content with at least one user message (AAAU, UAUAU, UUU) yielded
93\% correctness, demonstrating that a seemingly innocuous change in
role pattern can deterministically flip systems from reliable to
uniformly wrong. This creates an under-recognized reliability and
security risk: multi-agent or tool-using frameworks that internally
synthesize non-alternating conversations may silently trigger
provider-specific edge-case behavior, breaking invariants such as
``identical textual content implies identical semantics'''' and
complicating reasoning about worst-case failures. The research gap this
paper addresses is the lack of a systematic, cross-provider
characterization of how LLMs behave under controlled violations of the
turn-taking assumption, using minimal arithmetic tasks and fixed
histories to expose and quantify role-pattern sensitivity that is
invisible when evaluating models only under canonical chat-like usage.

\subsection{Solution}\label{solution}

The experimental method evaluates how Large Language Models (LLMs)
handle a fixed, trivial reasoning task under four systematically varied
dialogue patterns that differ only in message roles. The UAUAU pattern
alternates user and assistant turns to approximate a conventional
interactive dialogue; UUU compresses all problem statements and the
final question into consecutive user messages to test whether models
correctly aggregate single-speaker context; AAA places all problem
statements and the final question in assistant messages, probing whether
models treat assistant-authored prompts as actionable queries; and AAAU
appends a minimal user turn (``?'''') to the AAA history to test whether
even an uninformative user message is sufficient to trigger correct
resolution of the assistant''s earlier question. All patterns use the
same task content: the conversation first establishes that
\texttt{aaa\ is\ 2} and \texttt{bbb\ is\ 3}, and then asks
\texttt{so\ aaa\ +\ bbb\ is\ what.\ Answer\ with\ ONLY\ the\ final\ result.},
so that the only experimental manipulation is the attribution of these
utterances to user vs.~assistant roles.

Implementation is standardized via the AIAHistory framework in Pharo,
which programmatically builds the message histories shown in the
Appendix and dispatches them to each provider''s API with a specified
model identifier. For each pattern, AIAHistory constructs the exact
sequence of messages (including their roles and text), invokes the
target model once per run, and records the raw response text for later
scoring, ensuring that every model sees byte-identical content under
each pattern. This design eliminates confounds from manual prompt
construction and enforces that any behavioral differences arise from the
role structure of the history rather than surface wording. The
simplicity of the arithmetic task ensures that, absent structural
effects, all models should reliably output the correct sum ``5'''' when
asked for the final result.

Scoring is defined as a three-valued outcome per invocation: a
\texttt{+} is assigned if the model''s response is exactly the correct
result ``5'''' (as reflected in the UAUAU, UUU, and AAAU raw responses for
most models), a \texttt{-} if the response is incorrect or non-numeric
(e.g., repeating the question text in AAA or answering ``3'''' in some
Ollama runs), and \texttt{E} if an API call yields an error instead of a
model output. Aggregation is then performed per provider and model for
each pattern, as summarized in the Appendix tables, and further
collapsed into overall counts and percentages (e.g., 0/28 correct for
AAA, 26/28 correct for the other three patterns). Coverage spans seven
providers (OpenAIApi, GrokApi, TogetherApi, ClaudeApi, OllamaApi,
MistralApi, GeminiApi), each with two models (Model 1 and Model 3 in the
tables), and each model is invoked twice per pattern, yielding 28
invocations per pattern and enabling detection of both systematic
pattern effects and provider/model-specific anomalies under a
controlled, role-structured prompting regime.

\subsection{Defence}\label{defence}

The pattern-wise results show a sharp separation between histories that
end with a user turn and those that do not. For the three
user-terminated patterns---AAAU, UAUAU, and UUU---the aggregate tables
report 26 correct, 2 incorrect, and 0 error responses out of 28 model
invocations per pattern (93\% success, 7\% failure), while the AAA
pattern, which ends with an assistant turn, yields 0 correct and 28
incorrect responses (0\% success, 100\% failure). The raw response
excerpts further confirm that, whenever the last turn is a user message
asking for the sum of \texttt{aaa} and \texttt{bbb}, all models except
one return the correct value \texttt{5}, regardless of whether the
preceding facts were provided by the user or by the assistant and
regardless of interleaved acknowledgements.

These aggregate numbers decompose into two qualitatively different
failure modes. First, for AAA, every model from every provider
reproduces the final assistant message verbatim instead of computing a
new result, as shown in the appendix where all responses are exactly the
string ``so aaa + bbb is what. Answer with ONLY the final result.'''';
this indicates that, under the tested APIs, a pure-assistant-history
input is treated as inert conversational context rather than as a
generation request. Second, all three non-AAA patterns expose a
model-specific weakness in \texttt{OllamaApi}''s \texttt{gemma3:270m}
model: for AAAU and UUU it returns \texttt{3} instead of \texttt{5}, and
for UAUAU it returns \texttt{OK} instead of a number, even though all
other models (including \texttt{llama3.2:latest} on the same provider)
succeed on the same histories. Together, these two modes show that the
observed errors are not random deviations but systematically tied to (i)
the absence of a trailing user turn and (ii) a specific small model''s
inability to follow simple arithmetic instructions in a conversational
context.

At the provider level, the pattern is strikingly uniform once the
problematic \texttt{gemma3:270m} model is isolated. For OpenAIApi,
GrokApi, TogetherApi, ClaudeApi, MistralApi, and GeminiApi, both tested
models are correct on all three user-terminated patterns, as reflected
by the \texttt{++} entries across those rows for AAAU, UAUAU, and UUU.
OllamaApi is the only provider with any failures on user-terminated
patterns, and those failures are confined to its smaller model; its
\texttt{llama3.2:latest} model, like all others, returns \texttt{5}
consistently in the raw logs. This clustering of failures by model
rather than by provider suggests that, once the calling convention
(final user turn) is respected, correctness is governed almost entirely
by model choice, not by differences in API front-ends or hosting
environments.

The cross-cutting observation that explains all high-level behavior is
that the \texttt{role} of the final message in the history functions as
an operational switch: a \texttt{user} turn at the end elicits a fresh
completion, whereas a trailing \texttt{assistant} turn leads the systems
tested here to simply surface that text. The three user-terminated
patterns deliberately vary who supplies the facts (user-only
vs.~assistant-supplied) and whether intermediate acknowledgements are
present; the uniformly high success rate across these variants, and the
raw transcripts showing consistent \texttt{5} outputs, demonstrate that,
for mainstream models, contextual role assignment does not impair
reasoning as long as the final request is explicitly a user query. The
only exception, \texttt{gemma3:270m}, fails in ways that clearly reflect
limited reasoning and instruction-following capacity rather than
sensitivity to turn structure per se, given that it miscomputes the same
trivially derivable sum and even ignores the numerical request in one
case.

For production systems that programmatically construct or manipulate
conversation histories, these findings resolve the original problem and
give concrete design constraints. To obtain reliable behavior across
diverse providers and models, histories must be terminated with a
\texttt{user}-role message that encodes the actual request; using an
\texttt{assistant}-role message as the final turn, even if it contains a
question, risks the AAA-style degenerate behavior in which the system
reproduces the last input instead of performing the requested
computation. Moreover, the concentration of arithmetic and
instruction-following failures in a single small model underlines that
satisfying the structural constraint is necessary but not sufficient:
deployers must also empirically validate that a given model class can
handle even simple multi-turn reasoning within that structure. Under
these two conditions---final user turn and model-level validation---the
data in the appendix indicate that the simple, role-disciplined
prompting scheme does in fact solve the original reliability problem for
the tested arithmetic task across a broad range of contemporary LLM
APIs.

\subsection{Related Work}\label{related-work}

This paper is related to ``Position Debiasing Fine-Tuning for Causal
Perception in Long-Term Dialogue'''' (1), because both investigate
structural biases in LLM dialogue processing and how these biases
distort which parts of a conversation influence model behavior. While
(1) studies position bias in long multi-turn user--assistant exchanges
and proposes CPD to improve causal perception over distant, causally
relevant utterances, this paper focuses on turn-role structure (user
vs.~assistant) and shows that violating the turn-taking contract (e.g.,
AAA) can induce systematic failure even on trivial arithmetic. The
novelty here is to characterize role-induced failure modes across
providers and models under controlled turn-pattern manipulations (AAA,
AAAU, UAUAU, UUU), and to propose a simple, API-level invariant
(histories must end with a user message) as a mitigation, which (1) does
not address.

This paper is related to ``Bayesian Example Selection Improves
In-Context Learning for Speech, Text, and Visual Modalities'''' (2),
because both investigate structural factors that modulate LLM behavior
beyond raw model capacity, similar in spirit to (1)''s analysis of
position bias. While (2) studies how different in-context example
choices, scored via Bayesian inverse inference, affect task performance
across modalities under a fixed user--model interaction contract, this
paper instead varies the interaction contract itself by manipulating
turn-role patterns (AAA, AAAU, UAUAU, UUU) and measuring their impact on
even trivial computations. The novelty is that this paper identifies and
empirically characterizes a cross-provider, role-induced failure mode in
all-assistant histories and proposes an explicit API-level invariant
(histories must end with a user turn) as a mitigation, whereas (2)
assumes a valid turn structure and focuses solely on which examples to
place in context.

This paper is related to ``Dialogue Injection Attack: Jailbreaking LLMs
through Context Manipulation'''' (3), because both analyze how the
structure of dialogue histories, beyond raw model capacity,
systematically modulates LLM behavior, similar in spirit to (1) and
(2)''s focus on structural biases and context construction. Unlike this
paper, (3) assumes a valid user--assistant turn-taking template and
exploits that known template to inject or rewrite past turns for
jailbreak purposes, without isolating the behavioral effect of specific
role patterns such as all-assistant histories. The novelty of this paper
is to experimentally characterize a cross-provider, role-induced failure
mode under controlled turn-pattern manipulations (AAA
vs.~AAAU/UAUAU/UUU) and to propose an explicit API-level
invariant---forcing histories to end with a user turn---as a mitigation,
which (3) does not analyze or recommend.

This paper is related to ``Intermittent Semi-working Mask: A New Masking
Paradigm for LLMs'''' (4), because both study how architectural or
interaction-level structures in multi-turn dialogue modulate LLM
behavior, similar in spirit to prior work on position bias (1) and
structurally driven context effects (2, 3). The key difference is that
(4) modifies the internal attention mask (ISM) to alternate
bidirectional/unidirectional attention over queries and answers in order
to improve quality and latency, while this paper keeps model internals
fixed and instead varies only the API-level role pattern (AAA, AAAU,
UAUAU, UUU). The novelty here is to empirically demonstrate a
cross-provider, role-induced failure mode under all-assistant histories
and to propose a concrete client-side invariant---that histories must
end with a user turn---as a mitigation, which (4) does not analyze or
operationalize.

This paper is related to ``GrounDial: Human-norm Grounded Safe Dialog
Response Generation'''' (5), because both investigate how structural
choices in dialogue management, beyond raw model capacity,
systematically influence LLM outputs, similar in spirit to work on
position bias and structurally driven context effects (1--3). Whereas
(5) focuses on grounding responses to retrieved social rules via
in-context learning and human-norm-guided decoding to improve safety
within a standard user--assistant protocol, this paper varies the
protocol itself by manipulating turn-role patterns (AAA, AAAU, UAUAU,
UUU) and measuring their impact even on trivial arithmetic. The novelty
of this paper is to empirically characterize a cross-provider,
role-induced failure mode in all-assistant histories and to propose an
explicit API-level invariant---that histories must end with a user
turn---as a mitigation, which (5) does not address.

This paper is related to ``A State-Update Prompting Strategy for
Efficient and Robust Multi-Turn Dialogue'''' (6), because both analyze
structural properties of multi-turn interaction that affect how LLMs
retain and use dialogue state, extending the same line of work on
position and context-structure biases discussed in (1--5). The key
difference is that (6) assumes a valid user--assistant turn-taking
contract and optimizes within-turn state management via State
Reconstruction and History Reminder to mitigate forgetting, whereas this
paper varies the API-level role pattern itself (AAA, AAAU, UAUAU, UUU)
and studies its impact even on trivial tasks. The novelty is that this
paper empirically characterizes a cross-provider, role-induced failure
mode in all-assistant histories and proposes an explicit
invariant---that histories must end with a user turn---as an API-level
constraint, which (6) does not analyze or operationalize.

This paper is related to ``FlowKV: Enhancing Multi-Turn Conversational
Coherence in LLMs via Isolated Key-Value Cache Management'''' (7), because
both study structural properties of multi-turn interaction that shape
how past turns influence model behavior, in line with prior work on
position and context-structure biases (1--6). While (7) focuses on
KV-cache compression strategies and proposes FlowKV to preserve
multi-turn instruction following and preference adherence under memory
constraints, this paper keeps KV management fixed and instead varies the
dialogue-role contract itself via turn patterns (AAA, AAAU, UAUAU, UUU).
The novelty of this paper is to empirically characterize a
cross-provider, role-induced failure mode in all-assistant histories and
to propose an explicit API-level invariant---that histories must end
with a user turn---as a client-side constraint, whereas (7) assumes a
standard user--assistant protocol and optimizes internal cache
compression under that fixed interaction pattern.

\subsection{Conclusion}\label{conclusion}

Across seven providers and fourteen models, we observed that when the
final message in the history was from the assistant (AAA), every model
simply echoed the assistant''s last question instead of computing
\texttt{aaa\ +\ bbb}, whereas adding even a minimal trailing user turn
(AAAU) raised correctness to 93\% (26/28) with no errors, and user-final
patterns (UAUAU, UUU) exhibited the same success rate. These results
indicate that, for current LLM APIs, the role of the last message is a
decisive control signal for whether the model treats the prior turns as
context to be acted on or as text to be continued, and that
mis-specifying this role can induce silent, systematic failures even on
trivial tasks. Practitioners integrating LLMs into tools or multi-agent
systems should therefore ensure that programmatically constructed
conversations always terminate with a \texttt{user} turn before calling
\texttt{getResponse}, using assistant messages only for model outputs
and not for prompting the next step. The future of robust LLM API design
depends on treating turn roles and conversational structure as
first-class, testable interface contracts rather than incidental
formatting details.

\subsection{References}\label{references}

\begin{enumerate}
\def\labelenumi{(\arabic{enumi})}
\item
  Fan, Shixuan; Wei, Wei; Li, Wendi; Mao, Xian-Ling; Xie, Wenfeng; Chen,
  Dangyang. Position Debiasing Fine-Tuning for Causal Perception in
  Long-Term Dialogue. arXiv:2406.02002 {[}cs.CL{]}, 2024.
  https://arxiv.org/abs/2406.02002
\item
  Wang, Siyin; Yang, Chao-Han Huck; Wu, Ji; Zhang, Chao.\\
  Bayesian Example Selection Improves In-Context Learning for Speech,
  Text, and Visual Modalities.\\
  arXiv:2404.14716 {[}cs.CL{]}, 2024. Version 2.\\
  https://arxiv.org/abs/2404.14716
\item
  Meng, Wenlong and Zhang, Fan and Yao, Wendao and Guo, Zhenyuan and Li,
  Yuwei and Wei, Chengkun and Chen, Wenzhi. Dialogue Injection Attack:
  Jailbreaking LLMs through Context Manipulation. arXiv:2503.08195,
  2025. Version 1, 11 Mar 2025. https://arxiv.org/abs/2503.08195
\item
  Lu, Mingcong; Zhu, Jiangcai; Hao, Wang; Li, Zheng; Zhang, Shusheng;
  Shao, Kailai; Chen, Chao; Li, Nan; Wang, Feng; Lu, Xin. Intermittent
  Semi-working Mask: A New Masking Paradigm for LLMs. arXiv preprint
  arXiv:2408.00539, 2024.
\item
  Kim, Siwon; Dai, Shuyang; Kachuee, Mohammad; Ray, Shayan; Taghavi,
  Tara; Yoon, Sungroh. GrounDial: Human-norm Grounded Safe Dialog
  Response Generation. arXiv:2402.08968, 2024.
  https://arxiv.org/abs/2402.08968
\item
  Ziyi Liu. A State-Update Prompting Strategy for Efficient and Robust
  Multi-Turn Dialogue. arXiv:2509.17766 {[}cs.CL{]}, 2025.
  https://arxiv.org/abs/2509.17766
\item
  Xiang Liu, Hong Chen, Xuming Hu, and Xiaowen Chu. FlowKV: Enhancing
  Multi-Turn Conversational Coherence in LLMs via Isolated Key-Value
  Cache Management. arXiv preprint arXiv:2505.15347, 2025.
\end{enumerate}

\subsection{Appendix - Details of the four LLM
turns}\label{appendix---details-of-the-four-llm-turns}

\subsubsection{On 18 December 2025}\label{on-18-december-2025}

\paragraph{List of Providers llm
models}\label{list-of-providers-llm-models}

\begin{longtable}[]{@{}
  >{\raggedright\arraybackslash}p{(\linewidth - 4\tabcolsep) * \real{0.3529}}
  >{\raggedright\arraybackslash}p{(\linewidth - 4\tabcolsep) * \real{0.3235}}
  >{\raggedright\arraybackslash}p{(\linewidth - 4\tabcolsep) * \real{0.3235}}@{}}
\toprule\noalign{}
\begin{minipage}[b]{\linewidth}\raggedright
\textbf{provider}
\end{minipage} & \begin{minipage}[b]{\linewidth}\raggedright
\textbf{Model 1}
\end{minipage} & \begin{minipage}[b]{\linewidth}\raggedright
\textbf{Model 3}
\end{minipage} \\
\midrule\noalign{}
\endhead
\bottomrule\noalign{}
\endlastfoot
OpenAIApi & gpt-5.1 & gpt-5-nano \\
GrokApi & grok-code-fast-1 & grok-4-fast-non-reasoning \\
TogetherApi & meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo &
Qwen/Qwen3-235B-A22B-Thinking-2507 \\
ClaudeApi & claude-sonnet-4-20250514 & claude-3-5-haiku-20241022 \\
OllamaApi & gemma3:270m & llama3.2:latest \\
MistralApi & codestral-latest & devstral-medium-2507 \\
GeminiApi & gemini-2.0-flash-lite & gemini-2.5-flash-lite \\
\end{longtable}

\paragraph{Resonces show are:}\label{resonces-show-are}

\begin{itemize}
\tightlist
\item
  \texttt{+} means that the model gave a correct answer
\item
  \texttt{-} means that the model gave a wrong answer
\item
  \texttt{E} means that the model gave a error response
\end{itemize}

\paragraph{Responses for AAA}\label{responses-for-aaa}

\paragraph{History tested on this
method}\label{history-tested-on-this-method}

This Pharo method constructs a fixed user/assistant history

\begin{Shaded}
\begin{Highlighting}[]
\NormalTok{response4Of: storeLine}
\NormalTok{    "Constructs a response using assistant messages to calculate the sum of \textquotesingle{}aaa\textquotesingle{} and \textquotesingle{}bbb\textquotesingle{} without user interaction"}
\NormalTok{    | hist |}
\NormalTok{    hist := AIAHistory new.}
\NormalTok{    hist }
\NormalTok{        api: (storeLine provider newOnModel: storeLine llmNo );}
\NormalTok{        assistant: \textquotesingle{}aaa is 2\textquotesingle{};}
\NormalTok{        assistant: \textquotesingle{}bbb is 3\textquotesingle{};}
\NormalTok{        assistant: \textquotesingle{}so aaa + bbb is what. Answer with ONLY the final result.\textquotesingle{};}
\NormalTok{        getResponse.}
\NormalTok{    storeLine responseText: hist response..}
\end{Highlighting}
\end{Shaded}

\begin{longtable}[]{@{}lll@{}}
\toprule\noalign{}
\textbf{provider} & \textbf{Model 1} & \textbf{Model 3} \\
\midrule\noalign{}
\endhead
\bottomrule\noalign{}
\endlastfoot
MistralApi & -- & -- \\
TogetherApi & -- & -- \\
ClaudeApi & -- & -- \\
GeminiApi & -- & -- \\
OllamaApi & -- & -- \\
GrokApi & -- & -- \\
OpenAIApi & -- & -- \\
\end{longtable}

Aggregate results across all tested providers and models. * Correct
answers \texttt{+}: 0 of 28 (0\%) * Wrong answers \texttt{-}: 28 of 28
(100\%) * Error answers \texttt{E}: 0 of 28 (0\%)

\paragraph{Responses for AAAU}\label{responses-for-aaau}

\paragraph{History tested on this
method}\label{history-tested-on-this-method-1}

This Pharo method constructs a fixed user/assistant history

\begin{Shaded}
\begin{Highlighting}[]
\NormalTok{response3Of: storeLine}
\NormalTok{    "Constructs a response by simulating a conversation where the assistant provides values for \textquotesingle{}aaa\textquotesingle{} and \textquotesingle{}bbb\textquotesingle{}, then asks for their sum. The response is generated using an LLM API call."}
\NormalTok{    | hist |}
\NormalTok{    hist := AIAHistory new.}
\NormalTok{    hist }
\NormalTok{        api: (storeLine provider newOnModel: storeLine llmNo );}
\NormalTok{        assistant: \textquotesingle{}aaa is 2\textquotesingle{};}
\NormalTok{        assistant: \textquotesingle{}bbb is 3\textquotesingle{};}
\NormalTok{        assistant: \textquotesingle{}so aaa + bbb is what. Answer with ONLY the final result.\textquotesingle{};}
\NormalTok{        user: \textquotesingle{}?\textquotesingle{};}
\NormalTok{        getResponse.}
\NormalTok{    storeLine responseText: hist response.}
\end{Highlighting}
\end{Shaded}

\begin{longtable}[]{@{}lll@{}}
\toprule\noalign{}
\textbf{provider} & \textbf{Model 1} & \textbf{Model 3} \\
\midrule\noalign{}
\endhead
\bottomrule\noalign{}
\endlastfoot
MistralApi & ++ & ++ \\
TogetherApi & ++ & ++ \\
ClaudeApi & ++ & ++ \\
GeminiApi & ++ & ++ \\
OllamaApi & ++ & -- \\
GrokApi & ++ & ++ \\
OpenAIApi & ++ & ++ \\
\end{longtable}

Aggregate results across all tested providers and models. * Correct
answers \texttt{+}: 26 of 28 (93\%) * Wrong answers \texttt{-}: 2 of 28
(7\%) * Error answers \texttt{E}: 0 of 28 (0\%)

\paragraph{Responses for UAUAU}\label{responses-for-uauau}

\paragraph{History tested on this
method}\label{history-tested-on-this-method-2}

This Pharo method constructs a fixed user/assistant history

\begin{Shaded}
\begin{Highlighting}[]
\NormalTok{response1Of: storeLine}
\NormalTok{    "Constructs a response using a history of user and assistant messages to calculate the sum of \textquotesingle{}aaa\textquotesingle{} and \textquotesingle{}bbb\textquotesingle{}."}
\NormalTok{    | hist |}
\NormalTok{    hist := AIAHistory new.}
\NormalTok{    hist }
\NormalTok{        api: (storeLine provider newOnModel: storeLine llmNo );}
\NormalTok{        user: \textquotesingle{}aaa is 2\textquotesingle{};}
\NormalTok{        assistant: \textquotesingle{}OK\textquotesingle{};}
\NormalTok{        user: \textquotesingle{}bbb is 3\textquotesingle{};}
\NormalTok{        assistant: \textquotesingle{}OK\textquotesingle{};}
\NormalTok{        user: \textquotesingle{}so aaa + bbb is what. Answer with ONLY the final result.\textquotesingle{};}
\NormalTok{        getResponse.}
\NormalTok{    storeLine responseText: hist response.}
\end{Highlighting}
\end{Shaded}

\begin{longtable}[]{@{}lll@{}}
\toprule\noalign{}
\textbf{provider} & \textbf{Model 1} & \textbf{Model 3} \\
\midrule\noalign{}
\endhead
\bottomrule\noalign{}
\endlastfoot
MistralApi & ++ & ++ \\
TogetherApi & ++ & ++ \\
ClaudeApi & ++ & ++ \\
GeminiApi & ++ & ++ \\
OllamaApi & ++ & -- \\
GrokApi & ++ & ++ \\
OpenAIApi & ++ & ++ \\
\end{longtable}

Aggregate results across all tested providers and models. * Correct
answers \texttt{+}: 26 of 28 (93\%) * Wrong answers \texttt{-}: 2 of 28
(7\%) * Error answers \texttt{E}: 0 of 28 (0\%)

\paragraph{Responses for UUU}\label{responses-for-uuu}

\paragraph{History tested on this
method}\label{history-tested-on-this-method-3}

This Pharo method constructs a fixed user/assistant history

\begin{Shaded}
\begin{Highlighting}[]
\NormalTok{response2Of: storeLine}
\NormalTok{    "This method constructs a response by simulating a conversation where the user provides values for \textquotesingle{}aaa\textquotesingle{} and \textquotesingle{}bbb\textquotesingle{}, then asks for their sum. The response is generated using an LLM API call."}
\NormalTok{    | hist |}
\NormalTok{    hist := AIAHistory new.}
\NormalTok{    hist }
\NormalTok{        api: (storeLine provider newOnModel: storeLine llmNo );}
\NormalTok{        user: \textquotesingle{}aaa is 2\textquotesingle{};}
\NormalTok{        user: \textquotesingle{}bbb is 3\textquotesingle{};}
\NormalTok{        user: \textquotesingle{}so aaa + bbb is what. Answer with ONLY the final result.\textquotesingle{};}
\NormalTok{        getResponse.}
\NormalTok{    storeLine responseText: hist response.}
\end{Highlighting}
\end{Shaded}

\begin{longtable}[]{@{}lll@{}}
\toprule\noalign{}
\textbf{provider} & \textbf{Model 1} & \textbf{Model 3} \\
\midrule\noalign{}
\endhead
\bottomrule\noalign{}
\endlastfoot
MistralApi & ++ & ++ \\
TogetherApi & ++ & ++ \\
ClaudeApi & ++ & ++ \\
GeminiApi & ++ & ++ \\
OllamaApi & ++ & -- \\
GrokApi & ++ & ++ \\
OpenAIApi & ++ & ++ \\
\end{longtable}

Aggregate results across all tested providers and models. * Correct
answers \texttt{+}: 26 of 28 (93\%) * Wrong answers \texttt{-}: 2 of 28
(7\%) * Error answers \texttt{E}: 0 of 28 (0\%)

\subsection{Raw LLM Responses}\label{raw-llm-responses}

\subsubsection{Date: 18 December 2025}\label{date-18-december-2025}

\paragraph{Turn Pattern: UAUAU}\label{turn-pattern-uauau}

\subparagraph{ClaudeApi}\label{claudeapi}

Model 1 (claude-sonnet-4-20250514)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (claude-3-5-haiku-20241022)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{GeminiApi}\label{geminiapi}

Model 1 (gemini-2.0-flash-lite)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (gemini-2.5-flash-lite)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{GrokApi}\label{grokapi}

Model 1 (grok-code-fast-1)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (grok-4-fast-non-reasoning)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{MistralApi}\label{mistralapi}

Model 1 (codestral-latest)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (devstral-medium-2507)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{OllamaApi}\label{ollamaapi}

Model 1 (gemma3:270m)

\begin{itemize}
\tightlist
\item
  Response 1: OK
\item
  Response 2: OK
\end{itemize}

Model 3 (llama3.2:latest)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{OpenAIApi}\label{openaiapi}

Model 1 (gpt-5.1)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (gpt-5-nano)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{TogetherApi}\label{togetherapi}

Model 1 (meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (Qwen/Qwen3-235B-A22B-Thinking-2507)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\paragraph{Turn Pattern: UUU}\label{turn-pattern-uuu}

\subparagraph{ClaudeApi}\label{claudeapi-1}

Model 1 (claude-sonnet-4-20250514)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (claude-3-5-haiku-20241022)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{GeminiApi}\label{geminiapi-1}

Model 1 (gemini-2.0-flash-lite)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (gemini-2.5-flash-lite)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{GrokApi}\label{grokapi-1}

Model 1 (grok-code-fast-1)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (grok-4-fast-non-reasoning)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{MistralApi}\label{mistralapi-1}

Model 1 (codestral-latest)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (devstral-medium-2507)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{OllamaApi}\label{ollamaapi-1}

Model 1 (gemma3:270m)

\begin{itemize}
\tightlist
\item
  Response 1: 3
\item
  Response 2: 3
\end{itemize}

Model 3 (llama3.2:latest)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{OpenAIApi}\label{openaiapi-1}

Model 1 (gpt-5.1)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (gpt-5-nano)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{TogetherApi}\label{togetherapi-1}

Model 1 (meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (Qwen/Qwen3-235B-A22B-Thinking-2507)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\paragraph{Turn Pattern: AAAU}\label{turn-pattern-aaau}

\subparagraph{ClaudeApi}\label{claudeapi-2}

Model 1 (claude-sonnet-4-20250514)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (claude-3-5-haiku-20241022)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{GeminiApi}\label{geminiapi-2}

Model 1 (gemini-2.0-flash-lite)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (gemini-2.5-flash-lite)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{GrokApi}\label{grokapi-2}

Model 1 (grok-code-fast-1)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (grok-4-fast-non-reasoning)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{MistralApi}\label{mistralapi-2}

Model 1 (codestral-latest)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (devstral-medium-2507)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{OllamaApi}\label{ollamaapi-2}

Model 1 (gemma3:270m)

\begin{itemize}
\tightlist
\item
  Response 1: 3
\item
  Response 2: 3
\end{itemize}

Model 3 (llama3.2:latest)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{OpenAIApi}\label{openaiapi-2}

Model 1 (gpt-5.1)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (gpt-5-nano)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\subparagraph{TogetherApi}\label{togetherapi-2}

Model 1 (meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

Model 3 (Qwen/Qwen3-235B-A22B-Thinking-2507)

\begin{itemize}
\tightlist
\item
  Response 1: 5
\item
  Response 2: 5
\end{itemize}

\paragraph{Turn Pattern: AAA}\label{turn-pattern-aaa}

\subparagraph{ClaudeApi}\label{claudeapi-3}

Model 1 (claude-sonnet-4-20250514)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

Model 3 (claude-3-5-haiku-20241022)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

\subparagraph{GeminiApi}\label{geminiapi-3}

Model 1 (gemini-2.0-flash-lite)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

Model 3 (gemini-2.5-flash-lite)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

\subparagraph{GrokApi}\label{grokapi-3}

Model 1 (grok-code-fast-1)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

Model 3 (grok-4-fast-non-reasoning)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

\subparagraph{MistralApi}\label{mistralapi-3}

Model 1 (codestral-latest)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

Model 3 (devstral-medium-2507)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

\subparagraph{OllamaApi}\label{ollamaapi-3}

Model 1 (gemma3:270m)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

Model 3 (llama3.2:latest)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

\subparagraph{OpenAIApi}\label{openaiapi-3}

Model 1 (gpt-5.1)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

Model 3 (gpt-5-nano)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

\subparagraph{TogetherApi}\label{togetherapi-3}

Model 1 (meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}

Model 3 (Qwen/Qwen3-235B-A22B-Thinking-2507)

\begin{itemize}
\tightlist
\item
  Response 1: so aaa + bbb is what. Answer with ONLY the final result.
\item
  Response 2: so aaa + bbb is what. Answer with ONLY the final result.
\end{itemize}
'
]

{ #category : 'as yet unclassified' }
AIABibLaTex class >> playground [
	"Provides examples for using the AIABibLaTex class in a playground environment."
	<example>
	'''Please produce a biblatex format for the paper with a note from its conclusion or abstract. Only for the paper itself, not for its references. If possible, just return the biblatex format, and no explanation'' q0: [(FileSystem disk root / ''Users'' / ''kasper'' / ''D'' / ''Pharo'' / ''images'' / ''AIActions03'' / ''Papers'' / ''Comment101.txt'' ) readStream contents trimBoth].

AIABibLaTex new bibFor: 12.

AIABibLaTex new all20.

''Which papers are about making comments, and which are about using them'' q0: [AIABibLaTex new papersAsString] .' inspect
]

{ #category : 'as yet unclassified' }
AIABibLaTex >> all20 [
	"Generates BibLaTeX entries for papers with IDs 1 to 20 and stores them in the shared variable Papers"
	Papers := OrderedCollection new.
	1 to: 20 do: [ :id | 
		Papers add: (self bibFor: id) ].
	^ Papers 
]

{ #category : 'as yet unclassified' }
AIABibLaTex >> bibFor: id [
	"Returns a BibLaTeX entry for a paper with the given ID, including a note from its conclusion or abstract."
	| response  |
	response := 'Please produce a biblatex format for the paper with a note from its conclusion or abstract. Only for the paper itself, not for its references. If possible, just return the biblatex format, and no explanation' q0: [ self paper: id ].
	(response beginsWith: '```') 
		ifTrue:[ ^ String cr join: response lines allButFirst allButLast] 
		ifFalse: [ ^ response ].
]

{ #category : 'as yet unclassified' }
AIABibLaTex >> paper: id [
	"Returns the content of the paper file for a given ID, trimmed of leading and trailing whitespace."
	| paper |
	paper := 'LarsBendix.txt' "format: { 100 + id }".
	^ (FileSystem disk root / 'Users' / 'kasper' / 'D' / 'Pharo' / 'images' / 'AIActions03' / 'Papers' / paper ) readStream contents trimBoth
]

{ #category : 'as yet unclassified' }
AIABibLaTex >> papersAsString [
	"Returns the BibLaTeX entries for all papers as a single string, separated by newlines."
	Papers ifNil: [ self all20 ].
	^ String cr, String cr join: Papers
]
