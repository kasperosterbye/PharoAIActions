# UKSTUG talk on 28 Jan 2026

Background: https://www.meetup.com/ukstug/events/311265921/

## Kasper Østerbye - AI Inside Pharo

## Abstract
This talk explores what it means to work with AI from inside a live Pharo system rather than treating AI as an external chatbot. I will demonstrate experiments where AI models are invoked directly from the Playground, including a concrete implementation of conversation history (AIAHistory) and experiments across multiple models and providers.
Rather than focusing on code generation, the emphasis is on workflows: how different conversation structures affect results, how styles and constraints can be imposed on generated comments, and how AI systems can be inspected for systematic errors and limitations. Examples include documentation support, UML generation (via PlantUML), and experiments in automated paper review.
The talk is experimental in nature and rooted in Smalltalk’s strengths: reflection, live objects, and tools that are part of the system rather than bolted on. The goal is not to present a finished framework, but to share concrete insights, failures, and possibilities for AI as a native Pharo tool.

## Background
Kasper Østerbye is a retired computer science researcher with a long background in programming languages and live systems, including decades of work with Smalltalk and Pharo. He now explores how AI models can be integrated as native tools inside a running Pharo system, focusing on conversation structure, systematic failures, and tool design rather than automation alone.

## Presentation

Presentation was *live* based on the topics of Playground below

### Playground

"Introduction of me; 
where code is on github (kasperosterbye/PharoAIActions)"
AilienApi provider: OpenAIApi .
AilienApi info. 

a00 := 'Who is Kasper Østerbye. If you have not heard about him, just say "sorry I do not know"' q0.

AilienApi provider: GeminiApi.
AilienApi info. 

a01 := 'Who is Kasper Østerbye. If you have not heard about him, just say "sorry I do not know"' q0.

(String >> #q0) inspect.

AilienApi provider: OpenAIApi .
AilienApi info. 

(String >> #q) inspect.

a02 := 'What is the essence of AIAHistory. If you have not heard about him, just say "sorry I do not know"' q.

AIASourceCodeBuilder new forTagsLike: AIAHistory.

(String >> #q:) inspect.

a03 := 'What is the essence of AIAHistory. If you have not heard about him, just say "sorry I do not know"' q: [ AIASourceCodeBuilder new forTagsLike: AIAHistory ] .

"------ PLANT UML --------"

a042 :=  'Create a PlantUML diagram for AIAHistory being called by "user:", and show the method calls involved. It must be an overview' q: [ AIASourceCodeBuilder new forTagsLike: AIAHistory ].
AIAPlantUML umlToImage: a042.

AIAHistory histories .

a051 :=  'I am making class comments. Can you show me a PlantUML diagram show which classes are used. Do not whow me the methods of each class. The key class is AIAClassComment' q: [ AIASourceCodeBuilder new for: {'AIActions'} ] .
AIAPlantUML umlToImage: a051.

"------ Details -----"
a06 :=  'I''m interested in having build a PlantUML diagram that shows them Pharo Playground/APP -> API/History -> LLM -> API/History -> APP response. If you think you understand what I''m saying, the code is in the background' q: [ AIASourceCodeBuilder new forTagsLike: AIAHistory ] .
AIAPlantUML umlToImage: a06.

(String >> #q:) inspect.
AIAHistory histories .
AIAHistory histories first apiMessageList .

'You answered: "AI based response Terminated". Why?' d.

"------ Comments ------"
(AIAPackageComment new aiaComment: 'AIActions') response.
"Use command-P on Package, Class, or method"

AIAClassComment commentTypes. 
"#('Default' 'LLM' 'Beginner' 'Detailed' 'Expert' 'TestGuide')"
AIAClassComment commentType: 2.
AIAClassComment commentType.

"Use shift-command-P on Package, Class, or method"

(AilienApi >> #jsonHistory ) haiko.



"------ LLM Tools ------"
AilienApi provider: MistralApi.

'What is the capital of Denmark' q0.

'What is 12345 ** 75' q0 .
'what is 12345 ^ 75' q0 .
AilienApi provider: MistralApiWithTools.
Transcript open.

'What is the result of 105 !' q0. 

'What is the Pharo class comment for AIAHistory' q0.

'Which Pharo classes implements papersAsString' q0.
'Which Pharo classes implements executeTool:' q0.

'What Pharo package MicroDown is stored on GitHub. What is its purpuse  and what is its GitHub link adress' q0.
'What is the key difference between ChatPharo and Pharo-Copilot in GitHub, and who is the key designer of them' q0.

'What is the current weather in Paris, Denmark' q0.
'What is the current weather in San Francisco, Copenhagen and London' q0.

"------ Workshop Paper ------"

AIA2MultiLLMPaper default paperText.
AIAPresenter onText: AIA2MultiLLMPaper default paperText.

'Markdown'.
'/Users/kasper/D/ukstug.md'.

AIA2MultiLLMPaper.
"paperBuild" 
"paper30Problem"
"write30Problem"
"writeSection:withPrompt:"


