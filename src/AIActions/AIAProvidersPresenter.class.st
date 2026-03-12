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
		'window'
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

{ #category : 'layout' }
AIAProvidersPresenter >> defaultLayout [
	"Configures the layout of the presenter with a tree table and buttons for browsing and refreshing providers"

	^ SpBoxLayout newTopToBottom
		  add: providers;
		  add: (SpBoxLayout newLeftToRight
				   add: (self newButton
						    label: 'Double click to browse or select';
						    yourself);
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

{ #category : 'event handling' }
AIAProvidersPresenter >> doubleClick: selection [
	"Handles double-click events on the providers tree table. If the selected item is a class, it browses the class. If the selected item is a model name, it sets the default model for the provider and updates the window title. If the selected item is neither, it refreshes the list of providers."

	| item |
	item := selection selectedItem.
	item isClass 
		ifTrue: [ item browse ]
		ifFalse: [
			| provider llmModelNumber |
			provider :=  self providerFor:item.
			provider ifNotNil:[
				llmModelNumber := provider modelNames indexOf: item.
				provider defaultModel: llmModelNumber.
				AilienApi provider: provider.
				self setWindowTitle]
			ifNil: [ self refreshProviders ]  ]
]

{ #category : 'layout' }
AIAProvidersPresenter >> initializePresenters [
	"Initializes the presenters for the AIAProvidersPresenter class"

	providers := self newTreeTable.
	providers
		addColumn: (SpCompositeTableColumn new
				 title: 'Providers';
				 addColumn: ((SpImageTableColumn evaluated: [ :item |
								   self iconNamed: (item isString
											    ifTrue: [ #processBrowser ]
											    ifFalse: [ item systemIconName ]) ])
						  width: 20;
						  yourself);
				 addColumn: (SpStringTableColumn evaluated: [ :item |
							  item isString
								  ifTrue: [ item ]
								  ifFalse: [ item name ] ]);
				 yourself);
		roots: AilienApi subclasses;
		children: [ :provider |
				[ provider modelNames ]
					on: Error
					do: [ #(  ) ] ];
		beResizable;
		activateOnDoubleClick;
		whenActivatedDo: [ :selection | self doubleClick: selection ]
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

{ #category : 'layout' }
AIAProvidersPresenter >> refreshProviders [
	"Refreshes the list of AI providers and their models in the tree table"
    providers roots: AilienApi subclasses
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
