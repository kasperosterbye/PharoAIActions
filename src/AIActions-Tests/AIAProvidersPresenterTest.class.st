"
Unit tests for `AIAProvidersPresenter`, which refreshes the AI provider classes from the `ailiens.txt` definition file.

The tests work against an in-memory file system and check that refreshing:

- loads model definitions from the file into the corresponding provider classes, re-reading the file on every refresh;
- leaves the image untouched when the file refers to an unknown provider;
- shows only the providers listed in the file;
- preserves the currently selected provider and model where they are still present, and falls back sensibly where they are not.
"
Class {
	#name : 'AIAProvidersPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootDirectory',
		'presenter'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'running' }
AIAProvidersPresenterTest >> setUp [
	super setUp.
	rootDirectory := FileSystem memory root / 'AIAiliensTest'.
	rootDirectory ensureCreateDirectory.
	presenter := AIAProvidersPresenter new.
	presenter ailiensDirectory: rootDirectory
]

{ #category : 'tests' }
AIAProvidersPresenterTest >> testRefreshFallsBackWhenCurrentProviderDisappears [
	"If the currently selected provider is removed from ailiens.txt,
	refreshing must select a provider that is still active."

	| ailiensFile originalProvider |

	originalProvider := AilienApi provider.
	[
		AilienApi provider: ClaudeApi.

		ailiensFile := AIAiliensFile fromString: '# MistralApi
- codestral-latest'.
		ailiensFile rootDirectory: rootDirectory.
		ailiensFile save.

		presenter refreshProviders.

		self assert: AilienApi provider equals: MistralApi
	] ensure: [
		AilienApi provider: originalProvider ]
]

{ #category : 'tests' }
AIAProvidersPresenterTest >> testRefreshFallsBackWhenSelectedModelDisappears [
	"If the currently selected model is removed from ailiens.txt,
	refreshing must select the first remaining model for that provider."

	| ailiensFile |

	ailiensFile := AIAiliensFile fromString: '# AIAiliensTestApi
- alpha
- beta'.
	ailiensFile rootDirectory: rootDirectory.
	ailiensFile save.

	presenter refreshProviders.
	AIAiliensTestApi defaultModel: 2.

	ailiensFile := AIAiliensFile fromString: '# AIAiliensTestApi
- alpha'.
	ailiensFile rootDirectory: rootDirectory.
	ailiensFile save.

	presenter refreshProviders.

	self assert: AIAiliensTestApi defaultModel equals: 'alpha'
]

{ #category : 'tests' }
AIAProvidersPresenterTest >> testRefreshKeepsCurrentProvider [
	"Refreshing model definitions must not change the currently selected
	AI provider when that provider is still present in ailiens.txt."

	| originalProvider ailiensFile |

	originalProvider := AilienApi provider.
	[
		AilienApi provider: ClaudeApi.

		ailiensFile := AIAiliensFile fromString: '# ClaudeApi
- claude-opus-5

# MistralApi
- codestral-latest'.
		ailiensFile rootDirectory: rootDirectory.
		ailiensFile save.

		presenter refreshProviders.

		self assert: AilienApi provider equals: ClaudeApi
	] ensure: [
		AilienApi provider: originalProvider ]
]

{ #category : 'tests' }
AIAProvidersPresenterTest >> testRefreshKeepsSelectedModelWhenStillPresent [
	"Refreshing must preserve the currently selected model by name,
	even if the order of models in ailiens.txt has changed."

	| ailiensFile |

	ailiensFile := AIAiliensFile fromString: '# AIAiliensTestApi
- alpha
- beta
- gamma'.
	ailiensFile rootDirectory: rootDirectory.
	ailiensFile save.

	presenter refreshProviders.
	AIAiliensTestApi defaultModel: 3.

	ailiensFile := AIAiliensFile fromString: '# AIAiliensTestApi
- gamma
- alpha
- beta'.
	ailiensFile rootDirectory: rootDirectory.
	ailiensFile save.

	presenter refreshProviders.

	self assert: AIAiliensTestApi defaultModel equals: 'gamma'
]

{ #category : 'tests' }
AIAProvidersPresenterTest >> testRefreshLoadsModelsFromFile [
	"Refreshing the presenter must load the model definitions from
	ailiens.txt and install them into the corresponding provider classes."
	| ailiensFile |

	ailiensFile := AIAiliensFile fromString: '# AIAiliensTestApi
- model-from-file'.
	ailiensFile rootDirectory: rootDirectory.
	ailiensFile save.

	presenter refreshProviders.

	self
		assert: AIAiliensTestApi modelNames
		equals: #( 'model-from-file' )
]

{ #category : 'tests' }
AIAProvidersPresenterTest >> testRefreshReloadsChangedFile [
	"Each refresh must read ailiens.txt again.
	Changes made to the file since the previous refresh must therefore
	replace the model lists currently installed in the image."
	| ailiensFile |

	ailiensFile := AIAiliensFile fromString: '# AIAiliensTestApi
- alpha'.
	ailiensFile rootDirectory: rootDirectory.
	ailiensFile save.

	presenter refreshProviders.
	self assert: AIAiliensTestApi modelNames equals: #( 'alpha' ).

	ailiensFile := AIAiliensFile fromString: '# AIAiliensTestApi
- beta
- gamma'.
	ailiensFile rootDirectory: rootDirectory.
	ailiensFile save.

	presenter refreshProviders.

	self
		assert: AIAiliensTestApi modelNames
		equals: #( 'beta' 'gamma' )
]

{ #category : 'tests' }
AIAProvidersPresenterTest >> testRefreshShowsOnlyProvidersListedInFile [
	"ailiens.txt defines which provider implementations are active.
	A provider class that exists in the image but is absent from the file
	must not be shown by the presenter."

	| ailiensFile |

	ailiensFile := AIAiliensFile fromString: '# ClaudeApi
- claude-opus-5

# MistralApi
- codestral-latest'.
	ailiensFile rootDirectory: rootDirectory.
	ailiensFile save.

	presenter refreshProviders.

	self
		assert: presenter providerRoots
		equals: {  ClaudeApi . MistralApi }.

	self assert: (Smalltalk globals includesKey: #TogetherApi)
]

{ #category : 'tests' }
AIAProvidersPresenterTest >> testRefreshWithUnknownProviderLeavesCurrentModelsUnchanged [
	"Refreshing from an invalid file must not partly modify the image.
	If the file contains an unknown provider, the previously installed
	model lists must remain unchanged."

	| validFile invalidFile |

	validFile := AIAiliensFile fromString: '# AIAiliensTestApi
- alpha'.
	validFile rootDirectory: rootDirectory.
	validFile save.

	presenter refreshProviders.
	self assert: AIAiliensTestApi modelNames equals: #( 'alpha' ).

	invalidFile := AIAiliensFile fromString: '# AIAiliensTestApi
- beta
# NoSuchApi
- gamma'.
	invalidFile rootDirectory: rootDirectory.
	invalidFile save.

	self
		should: [ presenter refreshProviders ]
		raise: Error.

	self
		assert: AIAiliensTestApi modelNames
		equals: #( 'alpha' )
]
