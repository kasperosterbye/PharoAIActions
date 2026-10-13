"
Unit tests for `AIAiliensFile`, the markdown-style file that holds the list of AI providers, their models, reasoning levels and comments shared between images.

The tests cover parsing the file format (providers, models, reasoning levels and comment lines in order), round-tripping through save and load, exporting the current image's model lists, installing a file into the image (compiling model names, preserving the default model by name, falling back when it has been removed, rejecting unknown providers atomically and leaving the current provider untouched), and recording the model selection history.
"
Class {
	#name : 'AIAiliensFileTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'running' }
AIAiliensFileTest >> setUp [ 
	super setUp.
	rootDirectory := FileSystem memory root / 'AIAiliensFileTest'.
	rootDirectory ensureCreateDirectory
]

{ #category : 'tests' }
AIAiliensFileTest >> testCurrentReturnsSameInstance [
    | first second |
    first := AIAiliensFile current.
    second := AIAiliensFile current.
    self assert: first identicalTo: second
]

{ #category : 'tests' }
AIAiliensFileTest >> testParseCommentLinesBelongToTheirProvider [
	"Comment text in the file replaces the comments now written inside each
	modelNames method. Lines that are neither headings nor models must
	therefore be kept, in order, with the provider they appear under."
	| ailiens |
	ailiens := AIAiliensFile fromString: '# ClaudeApi
Look at https://docs.anthropic.com/en/docs/about-claude/models/overview
Haiku is the cheap one
- claude-haiku-4-5-20251001
# MistralApi
- codestral-latest'.
	self
		assert: (ailiens commentFor: #ClaudeApi)
		equals: 'Look at https://docs.anthropic.com/en/docs/about-claude/models/overview'
			, String cr , 'Haiku is the cheap one'.
	self assert: (ailiens commentFor: #MistralApi) isEmpty.
	self
		assert: (ailiens modelNamesFor: #ClaudeApi)
		equals: #( 'claude-haiku-4-5-20251001' )
]

{ #category : 'tests' }
AIAiliensFileTest >> testParseProvidersAndModelsInOrder [
	"Order in the file is the order shown in the presenter and used by defaultModel: index."
	| ailiens |
	ailiens := AIAiliensFile fromString: '# ClaudeApi
Look at https://docs.anthropic.com/en/docs/about-claude/models/overview
- claude-haiku-4-5-20251001
- claude-opus-5
# OpenAIApi
- gpt-5.5
- gpt-5.6-luna none low medium high xhigh max'.
	self
		assert: ailiens providerNames
		equals: #( #ClaudeApi #OpenAIApi ).
	self
		assert: (ailiens modelNamesFor: #ClaudeApi)
		equals: #( 'claude-haiku-4-5-20251001' 'claude-opus-5' ).
	self
		assert: (ailiens modelNamesFor: #OpenAIApi)
		equals: #( 'gpt-5.5' 'gpt-5.6-luna' )
]

{ #category : 'tests' }
AIAiliensFileTest >> testParseReasoningLevels [
	"Reasoning levels follow the model name on the same line. The result has
	the same shape as OpenAIApi class>>modelNamesAndReasoning, so the
	compiled method can be generated directly from it. A model without
	levels answers an empty array."
	| ailiens |
	ailiens := AIAiliensFile fromString: '# OpenAIApi
- gpt-5.5
- gpt-5.6-luna none low medium high xhigh max'.
	self
		assert: (ailiens modelNamesAndReasoningFor: #OpenAIApi)
		equals: {
			'gpt-5.5' -> #().
			'gpt-5.6-luna' -> #( #none #low #medium #high #xhigh #max ) }
]

{ #category : 'tests' }
AIAiliensFileTest >> testProviderReadsCurrentConfiguration [
    "A provider must obtain its models from the active configuration."
    | original |
    original := AIAiliensFile current.
    [
        AIAiliensFile current:
            (AIAiliensFile fromString: '# AIAiliensTestApi
- beta low high
- gamma').

        self
            assert: AIAiliensTestApi modelNames
            equals: #( 'beta' 'gamma' ).

        self
            assert: (AIAiliensTestApi reasoningLevelsFor: 'beta')
            equals: #( #low #high )
    ] ensure: [
        AIAiliensFile current: original ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testReloadDoesNotCompileModelNames [
    "Changing the active configuration must update models and reasoning
    levels without modifying compiled methods."
    | original methodBefore methodAfter |
    original := AIAiliensFile current.
    methodBefore := AilienApi class
        compiledMethodAt: #modelNamesAndReasoning.

    [
        AIAiliensFile current:
            (AIAiliensFile fromString: '# AIAiliensTestApi
- alpha
- beta low high').

        self
            assert: AIAiliensTestApi modelNames
            equals: #( 'alpha' 'beta' ).

        self
            assert: (AIAiliensTestApi reasoningLevelsFor: 'beta')
            equals: #( #low #high ).

        methodAfter := AilienApi class
            compiledMethodAt: #modelNamesAndReasoning.

        self assert: methodBefore identicalTo: methodAfter
    ] ensure: [
        AIAiliensFile current: original ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testReloadFallsBackToFirstWhenDefaultRemoved [
    "When the selected model disappears, use the first available model."
    | original |
    original := AIAiliensFile current.
    [
        AIAiliensFile current:
            (AIAiliensFile fromString: '# AIAiliensTestApi
- alpha
- beta').

        AIAiliensTestApi defaultModel: 2.

        AIAiliensFile current:
            (AIAiliensFile fromString: '# AIAiliensTestApi
- gamma
- alpha').

        self
            assert: AIAiliensTestApi defaultModel
            equals: 'gamma'
    ] ensure: [
        AIAiliensFile current: original ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testReloadIsAtomic [
    "A failed reload must preserve the entire active configuration."
    | original file |
    original := AIAiliensFile current.
    file := rootDirectory / AIAiliensFile fileName.
    [
        file writeStreamDo: [ :stream |
            stream nextPutAll: '# MistralApi
- changed-model
# NoSuchApi
- invalid-model' ].

        self
            should: [ AIAiliensFile reloadFrom: rootDirectory ]
            raise: Error.

        self assert: AIAiliensFile current identicalTo: original
    ] ensure: [
        AIAiliensFile current: original ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testReloadKeepsCurrentProvider [
    "Changing the model configuration must not change the selected provider."
    | originalConfiguration originalProvider |
    originalConfiguration := AIAiliensFile current.
    originalProvider := AilienApi provider.
    [
        AilienApi provider: MistralApi.
        AIAiliensFile current:
            (AIAiliensFile fromString: '# AIAiliensTestApi
- alpha').

        self assert: AilienApi provider equals: MistralApi
    ] ensure: [
        AIAiliensFile current: originalConfiguration.
        AilienApi provider: originalProvider ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testReloadKeepsDefaultModelByName [
    "Reloading a reordered model list must preserve the selected model by name."
    | original |
    original := AIAiliensFile current.
    [
        AIAiliensFile current:
            (AIAiliensFile fromString: '# AIAiliensTestApi
- alpha
- beta
- gamma').

        AIAiliensTestApi defaultModel: 3.

        AIAiliensFile current:
            (AIAiliensFile fromString: '# AIAiliensTestApi
- gamma
- alpha').

        self
            assert: AIAiliensTestApi defaultModel
            equals: 'gamma'
    ] ensure: [
        AIAiliensFile current: original ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testReloadMissingFileUsesDefault [
    "A missing file must load the default configuration."
    | original |
    original := AIAiliensFile current.
    [
        AIAiliensFile reloadFrom: rootDirectory.
        self
            assert: AIAiliensFile current providerNames
            equals: AIAiliensFile default providerNames.
        self
            assert: (AIAiliensFile current modelNamesFor: #MistralApi)
            equals: (AIAiliensFile default modelNamesFor: #MistralApi)
    ] ensure: [
        AIAiliensFile current: original ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testReloadReadsUpdatedFile [
    "Reload must replace the shared configuration with the current file contents."
    | original file |
    original := AIAiliensFile current.
    file := rootDirectory / AIAiliensFile fileName.
    [
        file writeStreamDo: [ :stream |
            stream nextPutAll: '# MistralApi
- model-one' ].

        AIAiliensFile reloadFrom: rootDirectory.
        self
            assert: (AIAiliensFile current modelNamesFor: #MistralApi)
            equals: #( 'model-one' ).

        file ensureDelete.
        file writeStreamDo: [ :stream |
            stream nextPutAll: '# MistralApi
- model-two' ].

        AIAiliensFile reloadFrom: rootDirectory.
        self
            assert: (AIAiliensFile current modelNamesFor: #MistralApi)
            equals: #( 'model-two' )
    ] ensure: [
        AIAiliensFile current: original ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testReloadRejectsUnknownProvider [
    "An unknown provider must not replace the active configuration."
    | original file |
    original := AIAiliensFile current.
    file := rootDirectory / AIAiliensFile fileName.
    [
        file writeStreamDo: [ :stream |
            stream nextPutAll: '# NoSuchApi
- model-one' ].
        self
            should: [
                AIAiliensFile reloadFrom: rootDirectory ]
            raise: Error.
        self assert: AIAiliensFile current identicalTo: original
    ] ensure: [
        AIAiliensFile current: original ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testReloadReplacesCurrent [
	"Ensures that reloading the AIAiliensFile replaces the current instance with a new one"
    | original |
    original := AIAiliensFile current.
    [
        AIAiliensFile reload.
        self deny: AIAiliensFile current identicalTo: original
    ] ensure: [
        AIAiliensFile current: original ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testSaveThenLoadPreservesContent [
	"The file is the shared truth between images. Whatever one image saves,
	another must load unchanged: providers, models, levels and comments."
	| original loaded |
	original := AIAiliensFile fromString: '# OpenAIApi
See https://platform.openai.com/docs/models
- gpt-5.5
- gpt-5.6-luna none low medium high xhigh max
# MistralApi
- codestral-latest'.
	original rootDirectory: rootDirectory.
	original save.
	loaded := AIAiliensFile loadFrom: rootDirectory.
	self assert: loaded providerNames equals: original providerNames.
	self
		assert: (loaded modelNamesAndReasoningFor: #OpenAIApi)
		equals: (original modelNamesAndReasoningFor: #OpenAIApi).
	self
		assert: (loaded commentFor: #OpenAIApi)
		equals: (original commentFor: #OpenAIApi)
]

{ #category : 'tests' }
AIAiliensFileTest >> testSelectionIsAppendedToHistory [
	"Each selection of a model is recorded with time, provider and model,
	and survives being read back by another image."
	| ailiens history |
	ailiens := AIAiliensFile new rootDirectory: rootDirectory.
	ailiens recordSelection: #MistralApi model: 'codestral-latest'.
	ailiens recordSelection: #ClaudeApi model: 'claude-opus-5'.
	history := (AIAiliensFile new rootDirectory: rootDirectory) selectionHistory.
	self assert: history size equals: 2.
	self assert: history last providerName equals: #ClaudeApi.
	self assert: history last modelName equals: 'claude-opus-5'.
	self assert: history first timestamp <= history last timestamp
]
