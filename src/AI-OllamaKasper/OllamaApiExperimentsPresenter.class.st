Class {
	#name : 'OllamaApiExperimentsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'experiments',
		'modelList',
		'secondsList'
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

{ #category : 'as yet unclassified' }
OllamaApiExperimentsPresenter >> closePresenter [
	"Stop the experiemnter class, and close this Presenter"
	experiments ollamaProcess terminate.
	super window close.
]

{ #category : 'accessing' }
OllamaApiExperimentsPresenter >> experiments [

	^ experiments
]

{ #category : 'accessing' }
OllamaApiExperimentsPresenter >> experiments: anObject [

	experiments := anObject
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
    secondsList := SpListPresenter new items: {0}.
    quitButton := SpButtonPresenter new
        label: 'Stop & Quit';
        action: [ self closePresenter ].  "or whatever stop you want"

    self layout: (SpBoxLayout newTopToBottom
        add: (SpBoxLayout newLeftToRight 
					add: modelList expand: true;
        			add: secondsList expand: true)
		  		withConstraints: [ :c | c height: (modelList items size * 25) ];
        add: quitButton expand: false;
        yourself).

    "Save them into instance variables if you want to update dynamically!"
]

{ #category : 'as yet unclassified' }
OllamaApiExperimentsPresenter >> set: index seconds: secs [
	| list |
	list := secondsList items.
	index = (list size + 1) 
		ifTrue: [ list := list, { secs } ]
		ifFalse: [ list at: index put: secs ].
	secondsList items: list " (resultList items copyWith: '0' )"
	
]
