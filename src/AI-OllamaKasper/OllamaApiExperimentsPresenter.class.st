Class {
	#name : 'OllamaApiExperimentsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'experiments',
		'modelList',
		'resultList'
	],
	#category : 'AI-OllamaKasper-Eksperiments',
	#package : 'AI-OllamaKasper',
	#tag : 'Eksperiments'
}

{ #category : 'examples' }
OllamaApiExperimentsPresenter class >> open [
	<example>
	
	^ self new open
]

{ #category : 'initialization' }
OllamaApiExperimentsPresenter >> build [
	"^ SpBoxLayout newVertical
		add: (SpTextFieldExample new text: 'Running experiments...') ;
		add: (SpButton new label: 'Stop' action: [ self close ]) ;
		yourself."
]

{ #category : 'as yet unclassified' }
OllamaApiExperimentsPresenter >> closePresenter [
	"Stop the experiemnter class, and close this Presenter"
	modelList items: {'newAAA'. 'newBBB'. 'newCCC'. 'newDDD'}.
	resultList items size < modelList items size 
		ifTrue: [ resultList items: (resultList items copyWith: 'foo' )]
]

{ #category : 'initialization' }
OllamaApiExperimentsPresenter >> initialize [
	super initialize.
	titleHolder := 'Ollama Experiment Runner'.
]

{ #category : 'initialization' }
OllamaApiExperimentsPresenter >> initializePresenters [
    | quitButton |
    
    modelList := SpListPresenter new items: OllamaApi modelNames.
    resultList := SpListPresenter new items: {'17'.'Waiting...'}.
    quitButton := SpButtonPresenter new
        label: 'Stop & Quit';
        action: [ self closePresenter ].  "or whatever stop you want"

    self layout: (SpBoxLayout newTopToBottom
        add: (SpBoxLayout newLeftToRight 
					add: modelList expand: true;
        			add: resultList expand: true)
		  		withConstraints: [ :c | c height: (modelList items size * 25) ];
        add: quitButton expand: false;
        yourself).

    "Save them into instance variables if you want to update dynamically!"
]
