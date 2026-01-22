Class {
	#name : 'AIABuilder',
	#superclass : 'Object',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'model system' }
AIABuilder class >> exampleITU [
	
	AIAPresenter onText: self itu
]

{ #category : 'model system' }
AIABuilder class >> exampleLund [
	
	AIAPresenter onText: self lund
]

{ #category : 'model system' }
AIABuilder class >> exampleOttawa [
	
	AIAPresenter onText: self ottawa
]

{ #category : 'model system' }
AIABuilder class >> itu [
	
	^ 'AIATestBuilder aITestClassPostfix: ''AITest_a1'' .
AIAMistralTestBuilder new build: AIAChatBuilding >> #history.
AIAMistralTestBuilder buildAll: FuzzyMatcher.
AIATestBuilderExperiments testClass: AIAChatBuilding.

AIAGeminiTestBuilder new build: AIAChatBuilding >> #history.
AIAGeminiTestBuilder buildAll: AIAChatBuilding .

AIASourceCodeBuilder new forSuperClassesOf: AIAMistralTestBuilder .
AIASourceCodeBuilder new forClass: FuzzyMatcher .

(AIAMistralTestBuilder new build: (SpMillerColumnPresenter >> #traverseInFocusOrderDo:excluding:);chatBuilder) chatAllHistory .

AIACommentBuilding ailienApi: ClaudeApi.
AIACommentBuilding ailienApi: MistralApi.
AIACommentBuilding ailienApi: GeminiApi.
AIACommentBuilding ailienApi: OllamaApi.
AIACommentBuilding ailienApi.


''What does Andrzej Wasowski do'' q.
''Which of the universities in Copenhagen is the best'' i.
''What does Paulo Tell do'' i.
''Where do I find a horse'' l.
AIASlotComment for: AIAChatBuilding.

AIACommentBuilding allInstVarNames.

AIAMistralTestBuilder allInstVarNames.

AIAMistralTestBuilder allSelectorsBelow: AIABuilder .

(AIATestBuilder >> #promptGenerator) methodClass.
(AIATestBuilder >> #promptGenerator) selector asString.

AIATestBuilder name.
AIATestBuilder class isMeta .
AIATestBuilder class instVarNames size .'
]

{ #category : 'model system' }
AIABuilder class >> lund [
	^ '" ---- APP - API - LLM ---- "
''What is my name'' q0.
''My name is Kasper'' q0.
''What is my name'' q0.

''What is my name'' d.
''My name is Kasper'' d.
''What is my name'' d.

AIAHistory dDiscussion .


" ---- Are they different ---- "

''Who is the Computer Scientist Lars Bendix. No guessing, if you do not know, just say "I do not know"'' q0.

" ---- Comment generation ---- "
" See Browswe "

" ---- PlantUML -----"
pack := ''Can you make a PlantUML sequence diagram for all the classes in the Pharo package for package AIActions. Only include the PlantUML result, no explanation. no fence'' q: [ AIASourceCodeBuilder new for: {''AIActions''}] .

meth := ''Can you make a PlantUML sequence diagram for the method `forClass:` starting in the call in `AIASourceCodeBuilder new forClass: AIASourceCodeBuilder` . Only include the result, no explanation. no fence'' q: [   AIASourceCodeBuilder new forClass: AIASourceCodeBuilder] .

" ---- "
''I am interested in UML for showing the inner functions of Pharo. Not for how it is used by users. Which are the most important UML types for this'' q.

" ---- Biblatex ----"
bib1 := ''Please produce a biblatex format for the paper. Please use it references as well as its own format'' q0: [(FileSystem disk root / ''Users'' / ''kasper'' / ''D'' / ''Pharo'' / ''images'' / ''AIActions03'' / ''Papers'' / ''Comment120.txt'' ) readStream contents trimBoth].

bib2 := ''Please produce a biblatex format for the paper with a note from its conclusion or abstract. If possible, just return the biblatex format, and no explanation'' q0: [(FileSystem disk root / ''Users'' / ''kasper'' / ''D'' / ''Pharo'' / ''images'' / ''AIActions03'' / ''Papers'' / ''Comment120.txt'' ) readStream contents trimBoth].

AIABibLaTex biblatex.'
]

{ #category : 'model system' }
AIABuilder class >> ottawa [
	^ 'AilienApi providers.

AilienApi info.
AilienApi modelNames.
AilienApi provider: ClaudeApi.
AilienApi provider: GeminiApi.
AilienApi provider: MistralApi.
AilienApi newOnModel: 2.

MistralApi modelNames.
MistralApi defaultModel.
MistralApi defaultModel: 2.
foo := MistralApi newOnModel: 3.

GeminiApi modelNames.
GeminiApi defaultModel.
GeminiApi defaultModel: 1.
foo := GeminiApi newOnModel: 1.

''What was the name of the Ottawa region before europeans arrived'' q0.'
]

{ #category : 'model system' }
AIABuilder class >> paperBuilder [
	'AIASourceCodeBuilder new forClasses: {AIACommentBuilding . AIAClassComment. AIAMethodComment. AIAPackageComment } .

AIASourceCodeBuilder new for: { ''AIActions'' } .

AIASourceCodeBuilder new forClass: AIAHistory .

AIASlotComment for: AIA2MultiLLMStoreLine.
AIASlotComment for: AIA2MultiLLMWriter.


AIA2MultiLLMStorage default.
AIA2MultiLLMStorage clearDefault .
AIA2MultiLLMStorage default makeStoreLines.

AIA2MultiLLMBuilder new build .
AIA2MultiLLMBuilder clearDefault.

AIA2MultiLLMWriter default .
AIA2MultiLLMWriter default appendixWrite.


AIA2MultiLLMPaper default.
AIA2MultiLLMPaper default paperBuild .
AIA2MultiLLMPaper default paperText .


AIA2MultiLLMStorage default.
AIA2MultiLLMStorage clearDefault.
AIA2MultiLLMStorage default makeStoreLines.

AIA2MultiLLMBuilder new build.
AIA2MultiLLMBuilder clearDefault "Should stop it from building".
		
AIA2MultiLLMWriter default buildAppendix.
	
AIA2MultiLLMPaper default paper10Author .
AIA2MultiLLMPaper default paperText




'
]

{ #category : 'as yet unclassified' }
AIABuilder class >> plantUMLDemo [
	^ 'You are analysing a Pharo system that integrates LLMs.

Create a PlantUML overview diagram that shows the end-to-end flow from:

Playground / Application → AIAHistory → AilienApi (provider) → LLM → AilienApi → AIAHistory → Application response.

Constraints:
	•	This is an architectural overview, not a full design.
	•	Show key classes only, no methods, no instance variables.
	•	Emphasise data flow and responsibility, not inheritance details.
	•	AIAHistory must be shown as the central coordinator.
	•	AilienApi must be shown as an abstract provider with concrete examples (e.g. GeminiApi, OpenAIApi).
	•	Show where tool calls (if any) conceptually occur, without provider-specific JSON.
	•	Do not include HTTP, JSON, or UI details.
	•	The diagram should help a human understand “what talks to what, and why” in under 30 seconds.

Output:
	•	Only PlantUML code
	•	No explanation text.'
]

{ #category : 'model system' }
AIABuilder class >> ukSmall01 [
	
	^ '
AilienApi provider: OpenAIApi .
AilienApi info. 

a00 := ''Who is Kasper Østerbye. If you have not heard about him, just say "sorry I do not know"'' q0.

AilienApi provider: GeminiApi.
AilienApi info. 

a01 := ''Who is Kasper Østerbye. If you have not heard about him, just say "sorry I do not know"'' q0.

(String >> #q0) inspect.

AilienApi provider: OpenAIApi .
AilienApi info. 

(String >> #q) inspect.

a02 := ''What is the essence of AIAHistory. If you have not heard about him, just say "sorry I do not know"'' q.

AIASourceCodeBuilder new forTagsLike: AIAHistory.
(String >> #q:) inspect.
a03 := ''What is the essence of AIAHistory. If you have not heard about him, just say "sorry I do not know"'' q: [ AIASourceCodeBuilder new forTagsLike: AIAHistory ] .

"------ PLANT UML --------"

AIAPlantUML umlToImage: (a04 :=  ''Create a PlantUML diagram for AIAHistory being called by "user:", and show the method calls involved. It must be an overview'' q: [ AIASourceCodeBuilder new forTagsLike: AIAHistory ]) .
AIAPlantUML umlToImage: a04.

AIAHistory histories .

AIAPlantUML umlToImage: (a05 :=  ''I am making class comments. Can you show me a PlantUML diagram show which classes are used. Do not whow me the methods of each class. The key class is AIAClassComment'' q: [ AIASourceCodeBuilder new for: {''AIActions''} ]) .
AIAPlantUML umlToImage: a05.

"------ Details -----"


"------ Comments ------"

"------ Workshop Paper ------"

'
]
