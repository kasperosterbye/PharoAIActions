"
# AIABuilder

A builder for constructing and manipulating classes in a fluid, programmatic manner. This class provides a flexible API for defining classes with instance variables, shared variables, tags, and package assignments, while supporting both anonymous and named class creation.

## Key Features

- **Fluid Syntax**: Supports method chaining for concise class definition
- **Dual Installation**: Can build classes without installation or install them directly
- **Comparison**: Can compare existing classes with new configurations
- **Extensibility**: Designed to be extended with custom builder enhancers

## Usage Example

```smalltalk
""Create and inspect an anonymous class builder""
builder := AIABuilder new
    name: #MyAnonymousClass;
    slots: { #x . #y };
    sharedVariables: { #SharedVar };
    tag: 'Examples';
    package: 'MyPackage'.

""Build the class without installation (returns a class)""
builtClass := builder build.

""Install the class in the system""
builder install.

""Inspect the built class""
builtClass
```

## Design Decisions

1. **Scripting Support**: Designed for interactive use in the Playground
2. **Builder Pattern**: Returns a builder instance for method chaining
3. **Dual Build/Install**: Separates class construction from installation
4. **Class Information**: Handles both instance and class-side information
5. **Future Considerations**: API may evolve to better align with Pharo's class defaults

## Notes

- For production use, consider using `ShiftClassInstaller` for proper class installation
- Can be extended with custom enhancers (see `ShDefaultBuilderEnhancer`)
- Currently handles class comparison for change calculation
"
Class {
	#name : 'AIABuilder',
	#superclass : 'Object',
	#classVars : [
		'AilienApix',
		'CommentLanguage'
	],
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

{ #category : 'accessing' }
AIABuilder class >> language [
	CommentLanguage ifNil: [ CommentLanguage := 'British' ].
	^ CommentLanguage 
]

{ #category : 'accessing' }
AIABuilder class >> language: language [
	CommentLanguage := language
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
