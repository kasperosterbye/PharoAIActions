Class {
	#name : 'AIA1MultiLLMPaper',
	#superclass : 'Object',
	#instVars : [
		'paperText',
		'writeResponses'
	],
	#classInstVars : [
		'paper'
	],
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'accessing' }
AIA1MultiLLMPaper class >> paper [
	paper ifNil: [ paper := self new ].
	^ paper
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMPaper >> apiFourLevels [
	^ { GeminiApi newOnModel: 2.
		TogetherApi newOnModel: 3.
		OpenAIApi newOnModel: 1.
		ClaudeApi newOnModel: 5
	 }
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMPaper >> getAppendix [
	^ AIA1MultiLLMResponseBase report summaryOfTheFour
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMPaper >> getKentBeck [
	^ 'Kent Beck says:
I will not talk about a topic area, like my distinguished fellow panelists. I will present the process I use as I am writing my papers. You can adapt it for your writing process, or you can use it as a check list for evaluating finished papers (if this is starting to sound like patterns, well, fancy that). Much of what I will say is "common sense," found in any book about writing. Having looked at hundreds of submissions, though, I can state with certainty that most of the authors don''t follow this advice.
1. Write to the program committee. Never forget that before you can write to the vast, eager, and appreciative OOPSLA audience you must first get past the program committee. Before I begin I fix in my mind a picture of a harried PC member, desk piled with papers. Mine comes to the top. I have maybe thirty seconds to grab their interest. Remember that the program committee is made up of experts in the field. Even if your topic is of broad interest to beginners, there must still be some spark in it to keep an expert reading to the end. If your topic is highly technical, it may not be in an area that they are familiar with, so it must readably present the novel aspects of the work. 
2. One startling sentence. Now that you know you are writing to the program committee, you need to find the one thing you want to say that will catch their interest. If you have been working on the world''s niftiest program night and day for five years, the temptation is to include absolutely everything about it, "The Foo System In All Its Glory." It''ll never work. I know it''s painful to ignore all those great insights, but find the most interesting thing you have done and write it down, "network garbage collection is fast and easy." You want the reader''s eyes to open wide when they realize what it is you''ve just said. I think some people are reluctant to boil their message down to one startling sentence because it opens them up to concrete criticism. If you write about the Foo System and someone says it isn''t neat, you can just reply, "Is so, nyah!" If you say network garbage collection is easy, it is a statement that is objectively true or false. You can be proven wrong. Wait! You spent five years proving it was easy. Make your case. 
3. Argument: problem, solution, defence, related work. Now that you have a startling sentence, your paper must stand as the argument for its validity. You are convincing the by-now-intrigued committee member of the truth of your amazing statement. Divide your paper into four sections. The first describes the problem to be solved. When the PC member is done reading it, they should understand why it is a problem, and believe that it is important to solve. The second section describes your problem. You are convincing the PC member that your solution really could solve the problem. This section is sometimes supplemented with a section between the defence and related work which describes implementation details. The third section is your defence of why your solution really solves the problem. The PC member reading it should be convinced that the problem is actually solved, and that you have thought of all reasonable counter arguments. The final section describes what other people have done in the area. Upon reading this section, the PC member should be convinced that what you have done is novel. 
4. Abstract. The abstract is your four sentence summary of the conclusions of your paper. Its primary purpose is to get your paper into the A pile. Most PC members sort their papers in an A pile and a B pile by reading the abstracts. The A pile papers get smiling interest, the B pile papers are a chore to be slogged through. By keeping your abstract short and clear, you greatly enhance your chances of being in the A pile. I try to have four sentences in my abstract. The first states the problem. The second states why the problem is a problem. The third is my startling sentence. The fourth states the implication of my startling sentence. An abstract for this paper done in this style would be: The rejection rate for OOPSLA papers in near 90%. Most papers are rejected not because of a lack of good ideas, but because they are poorly structured. Following four simple steps in writing a paper will dramatically increase your chances of acceptance. If everyone followed these steps, the amount of communication in the object community would increase, improving the rate of progress.  Well, I''m not sure that''s a great abstract, but you get the idea. I always feel funny writing an abstract this way. The idea I thought was so wonderful when I started writing the paper looks naked and alone sitting there with no support. I resist the temptation to argue for my conclusion in the abstract. I think it gives the reader more incentive to carefully read the rest of the paper. They want to find you how in the world you could possible say such an outrageous thing. There are my four steps to better papers. You can use them sequentially to write papers, or you can use them to evaluate papers you have already written.
'
]

{ #category : 'initialization' }
AIA1MultiLLMPaper >> initialize [ 
	writeResponses := OrderedDictionary new.
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMPaper >> paper00Title [
	paperText << '# The Turn-Taking Assumption: Cross-Provider Testing of LLM Conversation Handling' 
		<< String lf << String lf
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMPaper >> paper10Author [
	|superNumbers modelName|
	superNumbers := '¹²³⁴⁵'.
	paperText << '> Kasper Østerbye¹, Gemini AIlien², Owen AIlien³, OpenAI AIlien⁴, Anthropic AILien⁵' 
		<< String lf << '> ¹ IT University of Copenhagen (retired) <br>' << String lf.

	1 to: 4 do: [ :index | 
		modelName := (self apiFourLevels at: index) printString copyReplaceAll: 'Api' with: ''.
		paperText << '> ' << (superNumbers at: index + 1) asString << ' ' << modelName << '<br>' << String lf
		].
	paperText << String lf << String lf.
	
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMPaper >> paper20Abstract [ 
	| text name|
	name :=  'Abstract'.
	(writeResponses includes: name) ifFalse: [ self write20Abstract ].
	text := (writeResponses at: name) last.
	paperText << text << String lf << String lf.
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMPaper >> paper30Problem [
	| text name|
	name :=  'Problem'.
	(writeResponses includes: name) ifFalse: [ self write30Problem ].
	text := (writeResponses at: name) last.
	paperText << text << String lf << String lf.
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMPaper >> paper40Solution [
	| text name|
		name :=  'Solution'.
	(writeResponses includes: name) ifFalse: [ self write40Solution ].
	text := (writeResponses at: name) last.
	paperText << text << String lf << String lf.
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMPaper >> paper50Defence [
	| name text |
	name :=  'Defence'.
	(writeResponses includes: name) ifFalse: [ self write50Defence ].
	text := (writeResponses at: name) last.
	paperText << text << String lf << String lf.
]

{ #category : 'as yet unclassified' }
AIA1MultiLLMPaper >> paperBuild [
	paperText := WriteStream on: ''.
	
	self
		paper00Title;
		paper10Author;
		paper20Abstract;
		paper30Problem;
		paper40Solution;
		paper50Defence .
	
	paperText << self getAppendix .
	
	paperText := paperText contents
]

{ #category : 'accessing' }
AIA1MultiLLMPaper >> paperText [
	^ paperText
]

{ #category : 'writing' }
AIA1MultiLLMPaper >> write20Abstract [
	^ self 
		writeSection: 'Abstract' 
		withPrompt: 'write a 4-sentence Abstract following Kent Beck''s structure:
1. Problem statement
2. Why it''s a problem
3. Startling sentence (main finding)
4. Implication'.
]

{ #category : 'writing' }
AIA1MultiLLMPaper >> write30Problem [
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
5. The research gap this paper fills'.
]

{ #category : 'writing' }
AIA1MultiLLMPaper >> write40Solution [
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
5. Coverage (28 models, 7 providers)'.
]

{ #category : 'writing' }
AIA1MultiLLMPaper >> write50Defence [
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
5. Implications for production systems'.
]

{ #category : 'writing' }
AIA1MultiLLMPaper >> writeSection: section withPrompt: prompt [
	| level1 level2 level3 level4 |
	level1 := AIAHistory new.
	level1 
		api: (self apiFourLevels first);
		background: self getAppendix;
		background: self getKentBeck;
		user: prompt;
		responseType: ('Start your response with "## {1}"' format: {section});
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
		user: 'Based on the discussion, Re', prompt ;
		responseType: 'Only include the ',section, ' text in your response';
		getResponse.
	writeResponses at: section put: { level1 response. level2 response. level3 response. level4 response }.
	^ level4 response 
]
