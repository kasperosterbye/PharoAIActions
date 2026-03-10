"
# Class Comment for AIAProvidersPresenter

The `AIAProvidersPresenter` class is responsible for presenting and managing a list of AI providers and their associated models. It allows users to browse and select different AI models for use within the application. The presenter provides a tree table view of the available providers and their models, and handles user interactions such as double-clicking to select a model or browse a provider's class.

## Usage Example

```st
""Open the AIAProvidersPresenter to manage and select AI models.""
AIAProvidersPresenter open
```

This example opens the presenter window, allowing users to interact with the available AI providers and models. Users can double-click on a model to select it as the default, or double-click on a provider to browse its class definition.
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
	"Returns the default layout for the presenter, which is a box layout with the providers tree table and a label."

	^ SpBoxLayout newTopToBottom
		add: providers ;
		add: 'Double click to browse or select' expand: false;
		yourself
]

{ #category : 'event handling' }
AIAProvidersPresenter >> doubleClick: selection [
	"Handles double-click events on the providers tree table. If the selected item is a class, it browses the class. Otherwise, it sets the default model for the selected provider and updates the window title."
	| item |
	item := selection selectedItem.
	item isClass 
		ifTrue: [ item browse ]
		ifFalse: [
			| provider llmModelNumber |
			provider :=  self providerFor:item.
			llmModelNumber := provider modelNames indexOf: item.
			provider defaultModel: llmModelNumber.
			AilienApi provider: provider.
			self setWindowTitle  ]
]

{ #category : 'layout' }
AIAProvidersPresenter >> initializePresenters [
	"Initialises the presenters for the AIAProvidersPresenter class."

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
	"Initialises the window for the AIAProvidersPresenter class."
    super initializeWindow: aWindow.
	 window := aWindow.
    window title: AilienApi info.
]

{ #category : 'event handling' }
AIAProvidersPresenter >> providerFor: modelName [
	"Returns the provider associated with the given model name."
    | dict |
    dict := Dictionary new.
    AilienApi providers do: [ :provider |
			provider modelNames do: [ :name | 
				dict at: name put: provider ] ].
    ^ dict at: modelName 
]

{ #category : 'initialization' }
AIAProvidersPresenter >> setWindowTitle [
	"Sets the window title to the current LLM model information"
	window title: 'LLM: ', AilienApi info.
]

{ #category : 'accessing' }
AIAProvidersPresenter >> window [
	"Returns the window associated with the presenter, ensuring it is unclosable"
	| windowResult |
	windowResult := super window.
	window window makeUnclosable.
	^ windowResult
]
