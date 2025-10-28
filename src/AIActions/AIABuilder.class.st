Class {
	#name : 'AIABuilder',
	#superclass : 'Object',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'model system' }
AIABuilder class >> exampleITU [
	
	AIACommentPresenter onText: self itu
]

{ #category : 'model system' }
AIABuilder class >> exampleOttawa [
	
	AIACommentPresenter onText: self ottawa
]

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
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
