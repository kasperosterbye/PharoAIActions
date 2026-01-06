"
# Class Comment for AIA2MultiLLMPaper

AIA2MultiLLMPaper is a class responsible for generating research papers using multiple Large Language Models (LLMs) in a structured, multi-stage process. It implements Kent Beck's writing contract to produce technical conference papers suitable for expert reviewers.

## Key Features

- **Multi-LLM Pipeline**: Uses four different LLMs (Gemini, Together, Claude, OpenAI) in sequence to refine paper sections
- **Structured Writing**: Follows Kent Beck's four-section structure (Problem, Solution, Defence, Related Work)
- **Automated Feedback**: Implements a four-level critique and revision process for each section
- **Appendix Integration**: Incorporates technical background material from the Appendix
- **Style Control**: Supports different writing styles tailored to different audiences

## Usage Example

```st
""AIA2MultiLLMPaper usage example""

""Create a new paper instance""
paper := AIA2MultiLLMPaper new.

""Build the complete paper""
paper paperBuild.

""Inspect the generated paper text""
paper paperText
```

## Design Notes

- The class maintains a history of all LLM interactions for each section
- Each section undergoes four refinement stages with increasing specificity
- The writing process strictly follows Kent Beck's guidelines for technical papers
- The class can be extended to support additional LLM providers or writing styles

This implementation provides a reproducible, automated approach to technical writing that maintains high standards of clarity and technical rigor.
"
Class {
	#name : 'AIA2MultiLLMPaper',
	#superclass : 'Object',
	#instVars : [
		'paperText',
		'writeResponses',
		'paperDict'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AIActions-AIAPaperBuilding',
	#package : 'AIActions',
	#tag : 'AIAPaperBuilding'
}

{ #category : 'examples' }
AIA2MultiLLMPaper class >> clearDefault [
	<example>
	default := nil
]

{ #category : 'accessing' }
AIA2MultiLLMPaper class >> default [
	default ifNil: [ default := self new ].
	^ default
]

{ #category : 'accessing' }
AIA2MultiLLMPaper class >> instalationInstructions [
	^ self.
"
AIA2MultiLLMStorage default.
AIA2MultiLLMStorage clearDefault.
AIA2MultiLLMStorage default makeStoreLines.

AIA2MultiLLMBuilder new build.
AIA2MultiLLMBuilder clearDefault (Should stop it from building).
		
AIA2MultiLLMWriter default buildAppendix.
	
AIA2MultiLLMPaper default paperBuild.
AIA2MultiLLMPaper paperText
"
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> apiFourLevels [
	^ { GeminiApi newOnModel: 2.
		TogetherApi newOnModel: 3.
		ClaudeApi newOnModel: 5.
		OpenAIApi newOnModel: 1.
	 }
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> getAppendix [
	^ AIA2MultiLLMWriter default appendix
]

{ #category : 'as yet unclassified' }
AIA2MultiLLMPaper >> getKentBeck [
	^ 'Kent Beck says:
I will not talk about a topic area, like my distinguished fellow panelists. I will present the process I use as I am writing my papers. You can adapt it for your writing process, or you can use it as a check list for evaluating finished papers (if this is starting to sound like patterns, well, fancy that). Much of what I will say is "common sense," found in any book about writing. Having looked at hundreds of submissions, though, I can state with certainty that most of the authors don''t follow this advice.
1. Write to the program committee. Never forget that before you can write to the vast, eager, and appreciative OOPSLA audience you must first get past the program committee. Before I begin I fix in my mind a picture of a harried PC member, desk piled with papers. Mine comes to the top. I have maybe thirty seconds to grab their interest. Remember that the program committee is made up of experts in the field. Even if your topic is of broad interest to beginners, there must still be some spark in it to keep an expert reading to the end. If your topic is highly technical, it may not be in an area that they are familiar with, so it must readably present the novel aspects of the work. 
2. One startling sentence. Now that you know you are writing to the program committee, you need to find the one thing you want to say that will catch their interest. If you have been working on the world''s niftiest program night and day for five years, the temptation is to include absolutely everything about it, "The Foo System In All Its Glory." It''ll never work. I know it''s painful to ignore all those great insights, but find the most interesting thing you have done and write it down, "network garbage collection is fast and easy." You want the reader''s eyes to open wide when they realize what it is you''ve just said. I think some people are reluctant to boil their message down to one startling sentence because it opens them up to concrete criticism. If you write about the Foo System and someone says it isn''t neat, you can just reply, "Is so, nyah!" If you say network garbage collection is easy, it is a statement that is objectively true or false. You can be proven wrong. Wait! You spent five years proving it was easy. Make your case. 
3. Argument: problem, solution, defence, related work. Now that you have a startling sentence, your paper must stand as the argument for its validity. You are convincing the by-now-intrigued committee member of the truth of your amazing statement. Divide your paper into four sections. The first describes the problem to be solved. When the PC member is done reading it, they should understand why it is a problem, and believe that it is important to solve. The second section describes your problem. You are convincing the PC member that your solution really could solve the problem. This section is sometimes supplemented with a section between the defence and related work which describes implementation details. The third section is your defence of why your solution really solves the problem. The PC member reading it should be convinced that the problem is actually solved, and that you have thought of all reasonable counter arguments. The final section describes what other people have done in the area. Upon reading this section, the PC member should be convinced that what you have done is novel. 
4. Abstract. The abstract is your four sentence summary of the conclusions of your paper. Its primary purpose is to get your paper into the A pile. Most PC members sort their papers in an A pile and a B pile by reading the abstracts. The A pile papers get smiling interest, the B pile papers are a chore to be slogged through. By keeping your abstract short and clear, you greatly enhance your chances of being in the A pile. I try to have four sentences in my abstract. The first states the problem. The second states why the problem is a problem. The third is my startling sentence. The fourth states the implication of my startling sentence. An abstract for this paper done in this style would be: The rejection rate for OOPSLA papers in near 90%. Most papers are rejected not because of a lack of good ideas, but because they are poorly structured. Following four simple steps in writing a paper will dramatically increase your chances of acceptance. If everyone followed these steps, the amount of communication in the object community would increase, improving the rate of progress.  Well, I''m not sure that''s a great abstract, but you get the idea. I always feel funny writing an abstract this way. The idea I thought was so wonderful when I started writing the paper looks naked and alone sitting there with no support. I resist the temptation to argue for my conclusion in the abstract. I think it gives the reader more incentive to carefully read the rest of the paper. They want to find you how in the world you could possible say such an outrageous thing. There are my four steps to better papers. You can use them sequentially to write papers, or you can use them to evaluate papers you have already written.
'
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> getKentBeckLLM [
	^ '[KEN BECK WRITING CONTRACT — LLM VERSION]

You are writing one section of a research paper for expert reviewers.

General rules:
- Be precise, technical, and non-fluffy.
- Make claims that can be checked against the provided Appendix.
- Do not invent results, numbers, methods, or citations.
- Prefer concrete statements over meta-talk ("this paper will…").

Section structure (the paper is an argument):
- Problem: define the problem and why it matters.
- Solution: describe the method and why it can solve the problem.
- Defence: present evidence/results and address counter-arguments.
- Related work is optional unless explicitly requested.

Abstract rule (strict):
- Write exactly 4 sentences:
  1) State the problem.
  2) State why it is a problem.
  3) State the main finding as one startling sentence.
  4) State the implication of that finding.
- No bullets, no extra sentences, no preface.

Output discipline:
- Start with the required section heading (provided separately).
- Output only the section text; no commentary about the process.'
]

{ #category : 'initialization' }
AIA2MultiLLMPaper >> initialize [ 
	writeResponses := OrderedDictionary new.
	paperDict := OrderedDictionary new.
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> old_paper80References [
   |  text  list |
	(paperText findString: '$$$$$references$$$$$') = 0 ifTrue: [ ^ self ].	
	text := WriteStream on: ''.
	text << '## References' << String lf << String lf.
	list := AIA2RelatedListBuilder default getArxivList.
	1 to: list size do: [ :elementID |
			text << '(' << elementID asString << ') ' 
				<< (list at: elementID ) getFormattedReference 
				<< String lf << String lf.
			].
	paperText := paperText copyReplaceAll:'$$$$$references$$$$$' with: text contents .
	^ text contents.
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper00Title [
	| title |
	title := 'The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling'.
	paperDict at: 0 put: { 'title'. title }.
	paperText << '# ' << title  
		<< String lf << String lf
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper10Author [

	| authors superNumbers modelName |
	
	authors := self apiFourLevels , {'Kasper Østerbye' }.
	paperDict at: 10 put: {'authors'. authors}.
	superNumbers := '¹²³⁴⁵'.
	paperText << '> Gemini AIlien¹, Owen AIlien², OpenAI AIlien³, Anthropic AILien⁴, Kasper Østerbye⁵' << String lf.

	1 to: 4 do: [ :index |
			modelName := (self apiFourLevels at: index) printString copyReplaceAll: 'Api' with: ''.
			paperText << '> ' << (superNumbers at: index) asString << ' ' << modelName << '<br>' << String lf ].

	paperText << '> ' << (superNumbers at: 5) asString << ' Kasper Østerbye, IT University of Copenhagen (retired) <br>' << '<br>'
	<< String lf.

	paperText << String lf << String lf
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper15Subpages [
	
	paperText << '$$$$$abstract$$$$$' << String lf << String lf.	
	paperText << '$$$$$problem$$$$$' << String lf << String lf.	
	paperText << '$$$$$solution$$$$$' << String lf << String lf.	
	paperText << '$$$$$defence$$$$$' << String lf << String lf.
	paperText << '$$$$$related$$$$$' << String lf << String lf.
	paperText << '$$$$$conclusion$$$$$' << String lf << String lf.
	paperText << '$$$$$references$$$$$' << String lf << String lf.	
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper20Abstract [ 
	| text name|
	(paperText findString: '$$$$$abstract$$$$$')  = 0 ifTrue: [ ^ self ].
	name :=  'Abstract'.
	(writeResponses includesKey: name) ifFalse: [ self write20Abstract ].
	text := (writeResponses at: name) last.
	paperText := paperText copyReplaceAll:'$$$$$abstract$$$$$' with: text .
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper30Problem [
	| text name|
	(paperText findString: '$$$$$problem$$$$$')  = 0 ifTrue: [ ^ self ].
	name :=  'Problem'.
	(writeResponses includes: name) ifFalse: [ self write30Problem ].
	text := (writeResponses at: name) last.
	paperText := paperText copyReplaceAll:'$$$$$problem$$$$$' with: text .
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper40Solution [
	| text name|
	(paperText findString: '$$$$$solution$$$$$')  = 0 ifTrue: [ ^ self ].
	name :=  'Solution'.
	(writeResponses includes: name) ifFalse: [ self write40Solution ].
	text := (writeResponses at: name) last.
	paperText := paperText copyReplaceAll:'$$$$$solution$$$$$' with: text .
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper45SolutionPlantUML [
	
	
"Good experience with Grok/2"
'In the background there is paper with 4 methods. Can you combine those four and results into a PlantUML code example. I want to add it next the the "Solution". Only return the PlantUML, no explanation' q0: [ paperText ]
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper50Defence [
	| name text |
	(paperText findString: '$$$$$defence$$$$$')  = 0 ifTrue: [ ^ self ].
	name :=  'Defence'.
	(writeResponses includes: name) ifFalse: [ self write50Defence ].
	text := (writeResponses at: name) last.
	paperText := paperText copyReplaceAll:'$$$$$defence$$$$$' with: text .
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper60RelatedWork [
   |  text  |
	(paperText findString: '$$$$$related$$$$$')  = 0 ifTrue: [ ^ self ].
	text := WriteStream on: ''.
	text << '## Related Work' << String lf << String lf.
	text << AIA2RelatedListBuilder default summaryOfRelatedWork << String lf << String lf.
	paperText := paperText copyReplaceAll:'$$$$$related$$$$$' with: text contents .
	^ text contents.
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper70Conclusion [
   |  text  name|
	(paperText findString: '$$$$$conclusion$$$$$')  = 0 ifTrue: [ ^ self ].
	name :=  'Conclusion'.
	(writeResponses includes: name) ifFalse: [ self write70Conclusion ].
	text := (writeResponses at: name) last.
	paperText := paperText copyReplaceAll:'$$$$$conclusion$$$$$' with: text contents .
	^ text contents.
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paper80References [
   |  text  list |
	(paperText findString: '$$$$$references$$$$$') = 0 ifTrue: [ ^ self ].	
	text := WriteStream on: ''.
	text << '## References' << String lf << String lf.
	list := AIA2RelatedPaperExtractor extractorList.
	1 to: list size do: [ :elementID |
			text << '(' << elementID asString << ') ' 
				<< (list at: elementID ) getFormattedReference 
				<< String lf << String lf.
			].
	paperText := paperText copyReplaceAll:'$$$$$references$$$$$' with: text contents .
	^ text contents.
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paperBuild [

	paperText ifNil: [
			paperText := WriteStream on: ''.

			self
				paper00Title;
				paper10Author;
				paper15Subpages.
			paperText << self getAppendix.
			paperText := paperText contents ].
	self
		paper20Abstract;
		paper30Problem;
		paper40Solution;
		paper50Defence;
		paper60RelatedWork;
		paper70Conclusion;
		paper80References
]

{ #category : 'paper build' }
AIA2MultiLLMPaper >> paperLatex [
	"Grok makes something useful"
	"But in reallity, one need to 1) Split the contents of the sections into an ordered dictionary, and 2) Define the header of the latex - eg something like.
	\documentclass[12pt]{article}
\usepackage{amsmath}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{hyperref}
\usepackage{multirow}
\usepackage{array}"
	'Can you make a Latex structure for background markdown. I have some other system that produces each "\section" part, so it is just the outer strucure for a scientific latex paper I am interested in.' q0: [  self paperText]
]

{ #category : 'accessing' }
AIA2MultiLLMPaper >> paperText [
	^ paperText
]

{ #category : 'writing' }
AIA2MultiLLMPaper >> write20Abstract [
	^ self 
		writeSection: 'Abstract' 
		withPrompt: 'write a 4-sentence Abstract following Kent Beck''s structure:
1. Problem statement
2. Why it''s a problem
3. Startling sentence (main finding)
4. Implication
Each sentence must be a single paragraph line (no blank lines).
Do not include citations, references, or URLs unless explicitly present in the Appendix.
Include at least one quantitative or directly observable result from the Appendix.'.
]

{ #category : 'writing' }
AIA2MultiLLMPaper >> write30Problem [
	^ self 
		writeSection: 'Problem' 
		withPrompt: 'Section type: Problem
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
5. The research gap this paper fills
Do not write text that is already in the backgound text, but you may reference it.
'.
]

{ #category : 'writing' }
AIA2MultiLLMPaper >> write40Solution [
	^ self 
		writeSection: 'Solution' 
		withPrompt: 'Section type: Solution
Goal: Describe the experimental method
Structure guidance from Kent Beck:
"The second section describes your solution. You are convincing the PC 
member that your solution really could solve the problem."

Your Solution section should cover:
1. The four test patterns and rationale for each
2. Implementation (AIAHistory framework)
3. Task design (aaa=2, bbb=3, sum=?)
4. Scoring methodology (+/-/error)
5. Coverage (models, providers)
Do not write text that is already in the backgound text, but you may reference it.'.
]

{ #category : 'writing' }
AIA2MultiLLMPaper >> write50Defence [
	^ self 
		writeSection: 'Defence' 
		withPrompt: 'Section type: Defence
Goal: Present results and convince reader the problem is solved
Structure guidance from Kent Beck:
"The third section is your defence of why your solution really solves 
the problem. The PC member reading it should be convinced that the 
problem is actually solved, and that you have thought of all reasonable 
counter arguments."

Your Defence section should cover:
1. Pattern-by-pattern results with success rates
2. Failure mode analysis
3. Provider-level patterns
4. Cross-cutting observations
5. Implications for production systems
Do not write text that is already in the backgound text, but you may reference it.'.
]

{ #category : 'writing' }
AIA2MultiLLMPaper >> write70Conclusion [
    ^ self 
        writeSection: 'Conclusion' 
        withPrompt: 'Section type: Conclusion
Goal: Summarize the findings and state the final implication for the field.
Structure guidance:
In the spirit of the Kent Beck writing contract, the conclusion must:
1. Reiterate the startling finding (from the Abstract) in the context of the evidence presented in the Defence.
2. Clearly state the operational recommendation for practitioners.
3. Reflect on the broader impact (e.g., for safety, reliability, or multi-agent orchestration).
4. End with a single, strong sentence about the future of robust LLM API design.

Do not introduce new data or citations not found in the previous sections or Appendix.'
]

{ #category : 'Protocol (writing) - 6 selector(s)' }
AIA2MultiLLMPaper >> writeSection: section withPrompt: prompt [
    | level1 level2 level3 level4 |
    level1 := AIAHistory new.
    level1
        api: (self apiFourLevels first);
        background: self getAppendix;
        background: self getKentBeckLLM;
        user: prompt;
        responseType: ('Start your response with "## {1}"' format: {section});
        getResponse.

    level2 := AIAHistory new.
    level2
        api: (self apiFourLevels second);
        background: self getKentBeckLLM;
        addPreHistory: level1;
        user: 'What do you see as its strengths, what do you see as its weaknesses, and what do you see as its missing areas?';
        getResponse.

    level3 := AIAHistory new.
    level3
        api: (self apiFourLevels third);
        background: self getKentBeckLLM;
        addPreHistory: level2;
        user: 'Based on the previous answer, what do you see as its strengths, what do you see as its weaknesses, and what do you see as its missing areas? Do not summarize, but include aspects you think are important.';
        getResponse.

    level4 := AIAHistory new.
    level4
        api: (self apiFourLevels fourth);
        background: self getKentBeckLLM;
        addPreHistory: level3;
        user: 'You have received feedback on strengths, weaknesses, and missing areas from previous drafts.
Your task now is to produce the FINAL version of the ', section, ' section.
Strictly follow the original guidelines in this prompt.
Do NOT continue critiquing or discussing strengths/weaknesses.
Output ONLY the section text itself, without any additional commentary or meta-text.

Original guidelines: ', prompt;
        responseType: 'Only include the ', section, ' text in your response';
        getResponse.

    writeResponses at: section put: { level1 response. level2 response. level3 response. level4 response }.
    ^ level4 response
]
