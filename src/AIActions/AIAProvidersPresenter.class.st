"
# Class Comment for AIAProvidersPresenter

The `AIAProvidersPresenter` class is a presenter designed to manage and display AI providers and their associated models within a Pharo application. It extends `SpPresenter` and is part of the `AIActions` package, tagged with 'AIApi'.

## Design Intent

The primary intent of `AIAProvidersPresenter` is to provide a user interface for browsing and selecting AI providers and their models. It allows users to view a hierarchical list of providers and their models, select a default model for a provider, and refresh the list of providers. The presenter ensures that the window is unclosable to maintain a consistent user experience.

## Invariants

- The `providers` instance variable is a `SpTreeTablePresenter` that displays the hierarchical list of AI providers and their models.
- The `window` instance variable is a `SpWindowPresenter` that manages the presenter's window.
- The window title is always set to the current LLM model information.

## Extension Points

- The `doubleClick:` method can be extended to handle additional actions when a user double-clicks on an item in the providers tree table.
- The `providerFor:` method can be extended to include additional logic for finding the provider associated with a given model name.
- The `refreshProviders` method can be extended to include additional logic for refreshing the list of providers.

## Known Trade-offs

- The `doubleClick:` method assumes that the selected item is either a class or a model name. If the selected item is neither, the method will not perform any action.
- The `providerFor:` method uses a dictionary to map model names to providers. This approach may not be efficient for a large number of providers and models.

## Usage Example

```smalltalk
AIAProvidersPresenter open
```

This example opens the `AIAProvidersPresenter` window, allowing the user to browse and select AI providers and their models.
"
Class {
	#name : 'AIAProvidersPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'providers',
		'window',
		'ailiensDirectory',
		'toolsToggle'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'examples' }
AIAProvidersPresenter class >> open [
	<example>
	
	^ self new open
]

{ #category : 'accessing' }
AIAProvidersPresenter >> ailiensDirectory [
	^ ailiensDirectory ifNil: [ AIAiliensFile defaultRootDirectory ]
]

{ #category : 'accessing' }
AIAProvidersPresenter >> ailiensDirectory: dir [
	^ ailiensDirectory := dir
]

{ #category : 'event handling' }
AIAProvidersPresenter >> bindCheckShortcut [
    "Bind Command-P to check the selection and
    Command-Shift-P to clear the selection and check all models."

    providers
        bindKeyCombination: $p command asKeyCombination
        toAction: [ self checkSelection ].
	 providers
        bindKeyCombination: $P command asKeyCombination
        toAction: [ providers unselectAll. self checkSelection ]
]

{ #category : 'event handling' }
AIAProvidersPresenter >> checkSelection [
    "Run the LLM tool-capability test for the selected model,
    selected provider, or all providers when nothing is selected."

    | selected provider |

    selected := providers selectedItem.

    selected ifNil: [
        ^ AIAFullLLMTester runAllProviders ].

    selected isClass ifTrue: [
        ^ AIAFullLLMTester runProvider: selected ].

    provider := self providerFor: selected.
    ^ AIAFullLLMTester
        runProvider: provider
        model: selected
]

{ #category : 'layout' }
AIAProvidersPresenter >> defaultLayout [
    "Show the providers tree, global tools toggle and refresh button."
    ^ SpBoxLayout newTopToBottom
        add: providers;
        add: (SpBoxLayout newLeftToRight
            add: toolsToggle;
            addLast: (self newButton
                label: 'Refresh';
                icon: (self iconNamed: #glamorousRefresh);
                action: [ self refreshProviders ];
                yourself)
            expand: false;
            yourself)
        expand: false;
        yourself
]

{ #category : 'accessing' }
AIAProvidersPresenter >> displayNameFor: item [
    "Show the reasoning level index before the model name."

    | provider levels selected index |

    item isString ifFalse: [ ^ item name ].

    provider := self providerFor: item.
    provider ifNil: [ ^ item ].

    levels := provider reasoningLevelsFor: item.
    levels ifEmpty: [ ^ item ].

    selected := AIAReasoningSettings levelForModel: item.
    selected ifNil: [ selected := levels middle ].

    index := levels indexOf: selected asSymbol.
    index = 0 ifTrue: [ ^ item ].

    ^ '[' , index asString , '/', levels size asString , '] ' , item
]

{ #category : 'event handling' }
AIAProvidersPresenter >> doubleClick: selection [
    "Browse a provider class or select a model.
    Warn if Ollama has stopped since the last refresh."

    | item provider llmModelNumber |

    item := selection selectedItem.

    item isClass ifTrue: [
        item browse.
        ^ self ].

    provider := self providerFor: item.

    provider ifNil: [
        self refreshProviders.
        ^ self ].

    (provider = OllamaApi and: [
        OllamaApi models isEmpty ]) ifTrue: [
            self inform: 'Ollama is not running or has no installed models'.
            self refreshProviders.
            ^ self ].

    llmModelNumber := provider modelNames indexOf: item.
    provider defaultModel: llmModelNumber.
    AilienApi provider: provider.
    self setWindowTitle

]

{ #category : 'defaults' }
AIAProvidersPresenter >> iconFor: item [
    "Use the standard icons for providers and models."

    ^ self iconNamed: (item isString
        ifTrue: [ #processBrowser ]
        ifFalse: [ item systemIconName ])
]

{ #category : 'initialization' }
AIAProvidersPresenter >> initializePresenters [
    "Initialize the providers tree, tools toggle and reasoning-level menu."
    providers := self newTreeTable.
    providers
        addColumn: (SpCompositeTableColumn new
            title: 'Providers';
            addColumn: ((SpImageTableColumn evaluated: [ :item |
                self iconFor: item ])
                width: 20;
                yourself);
            addColumn: (SpStringTableColumn evaluated: [ :item |
                self displayNameFor: item ]);
            yourself);
        roots: AilienApi providers;
        children: [ :item |
            item isClass
                ifFalse: [ #() ]
                ifTrue: [
                    item = OllamaApi
                        ifTrue: [ item availableModelNames ]
                        ifFalse: [ item modelNames ] ] ];
        beResizable;
        help: 'Double click a provider to browse it or a model to select it';
        activateOnDoubleClick;
        whenActivatedDo: [ :selection |
            self doubleClick: selection ];
        contextMenu: [ self reasoningContextMenu ].

    toolsToggle := self newToggleButton.
    toolsToggle
        label: 'Tools';
        help: 'Enable or disable tools for all providers';
        state: AilienApi allToolsEnabled;
        whenChangedDo: [ :enabled | AilienApi allToolsEnabled: enabled ].

    self bindCheckShortcut
]

{ #category : 'initialization' }
AIAProvidersPresenter >> initializeWindow: aWindow [
	"Initialises the window for the presenter and sets the window title to the current LLM model information"
    super initializeWindow: aWindow.
	 window := aWindow.
    window title: AilienApi info.
]

{ #category : 'event handling' }
AIAProvidersPresenter >> providerFor: modelName [
	"Returns the provider associated with the given model name, or nil if no such provider exists"

	| dict |
	dict := Dictionary new.
	AilienApi providers do: [ :provider | 
		provider modelNames do: [ :name | dict at: name put: provider ] ].
	^ [dict at: modelName] on: Error do: [ nil ]
]

{ #category : 'accessing' }
AIAProvidersPresenter >> providerRoots [
	^ providers roots
]

{ #category : 'accessing' }
AIAProvidersPresenter >> reasoningContextMenu [
    "Select a reasoning level and refresh the display."

    | model provider levels menu |

    model := providers selectedItem.
    model ifNil: [ ^ nil ].
    model isString ifFalse: [ ^ nil ].

    provider := self providerFor: model.
    provider ifNil: [ ^ nil ].

    levels := provider reasoningLevelsFor: model.
    levels ifEmpty: [ ^ nil ].

    menu := self newMenu.

    menu addGroup: [ :group |
        levels do: [ :level |
            group addItem: [ :item |
                item
                    name: level asString;
                    action: [
                        AIAReasoningSettings
                            level: level
                            forModel: model.
                        providers adapter refreshTree.
                        self setWindowTitle ] ] ] ].

    ^ menu
]

{ #category : 'layout' }
AIAProvidersPresenter >> refreshProviders [
    "Reload model configuration without compiling provider methods.
    Preserve the selected provider if it remains available."
    | ailiens activeProviders |
    ailiens := AIAiliensFile reloadFrom: self ailiensDirectory.

    activeProviders := ailiens providerNames collect: [ :name |
        ailiens providerClassFor: name ].

    (activeProviders includes: AilienApi provider)
        ifFalse: [ AilienApi provider: activeProviders first ].

    providers roots: activeProviders
]

{ #category : 'initialization' }
AIAProvidersPresenter >> setWindowTitle [
	"Sets the window title to the current LLM model information"
	window title: AilienApi info.
]

{ #category : 'accessing' }
AIAProvidersPresenter >> window [
	"Returns the window associated with the presenter, ensuring it is unclosable"
	| windowResult |
	windowResult := super window.
	window window makeUnclosable.
	^ windowResult
]
