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
AIAiliensFileTest >> testExportFromImageMatchesCurrentModelNames [
	"The issue asks that the current data can be saved. Every provider in
	the image must therefore appear in the export, in the same order, with
	exactly the models it answers today."
	| ailiens |
	ailiens := AIAiliensFile fromImage.
	self
		assert: ailiens providerNames
		equals: (AilienApi providers collect: [ :cls | cls name ]).
	AilienApi providers do: [ :cls |
		self
			assert: (ailiens modelNamesFor: cls name)
			equals: cls modelNames asArray ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testInstallCompilesModelNames [
	"Installing must leave the image working as today: the provider answers
	its models and their reasoning levels without reading the file again."
	(AIAiliensFile fromString: '# AIAiliensTestApi
- alpha
- beta low high') install.
	self assert: AIAiliensTestApi modelNames asArray equals: #( 'alpha' 'beta' ).
	self
		assert: (AIAiliensTestApi reasoningLevelsFor: 'beta')
		equals: #( #low #high )
]

{ #category : 'tests' }
AIAiliensFileTest >> testInstallFallsBackToFirstWhenDefaultRemoved [
	"A model removed from the file can no longer be called. The default
	must fall back to the first model rather than keep a dead name."
	(AIAiliensFile fromString: '# AIAiliensTestApi
- alpha
- beta') install.
	AIAiliensTestApi defaultModel: 2.
	(AIAiliensFile fromString: '# AIAiliensTestApi
- alpha') install.
	self assert: AIAiliensTestApi defaultModel equals: 'alpha'
]

{ #category : 'tests' }
AIAiliensFileTest >> testInstallKeepsCurrentProvider [
	"Reloading model lists is not choosing a provider. Whatever provider is
	selected, Mistral by default, must still be selected afterwards."
	| originalProvider |
	originalProvider := AilienApi provider.
	[
		AilienApi provider: MistralApi.
		(AIAiliensFile fromString: '# AIAiliensTestApi
- alpha') install.
		self assert: AilienApi provider equals: MistralApi
	] ensure: [
		AilienApi provider: originalProvider ]
]

{ #category : 'tests' }
AIAiliensFileTest >> testInstallKeepsDefaultModelByName [
	"Another image may reorder the list. The selected model must stay
	selected, not whichever model now sits at the old position."
	(AIAiliensFile fromString: '# AIAiliensTestApi
- alpha
- beta
- gamma') install.
	AIAiliensTestApi defaultModel: 3.
	(AIAiliensFile fromString: '# AIAiliensTestApi
- gamma
- alpha') install.
	self assert: AIAiliensTestApi defaultModel equals: 'gamma'
]

{ #category : 'tests' }
AIAiliensFileTest >> testInstallRejectsUnknownProviderAndChangesNothing [
	"A typo in a heading must not leave the image half updated. Install
	checks every provider first and compiles nothing if one is unknown."
	(AIAiliensFile fromString: '# AIAiliensTestApi
- alpha') install.
	self
		should: [
			(AIAiliensFile fromString: '# AIAiliensTestApi
- beta
# NoSuchApi
- gamma') install ]
		raise: Error.
	self assert: AIAiliensTestApi modelNames asArray equals: #( 'alpha' )
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
