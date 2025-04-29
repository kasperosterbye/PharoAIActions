Class {
	#name : 'OllamaApiExperimentsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'experiments',
		'modelList',
		'secondsList',
		'currentSecondList',
		'arraySecondsList'
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
	Transcript show: 'We are closing, but not';cr;flush.
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
    arraySecondsList := {{ 0. 0. 0 }. { 0. 0. 0 }. { 0. 0. 0 }. { 0. 0. 0 }. { 0. 0. 0 }.}.
    secondsList := SpListPresenter new items: arraySecondsList .
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
OllamaApiExperimentsPresenter >> model: modelIndex experimentIndex: experimentIndex seconds: secs [
	"Index is the index of the model, seconds is how much it has spend on it last."
	(arraySecondsList at: modelIndex) at: experimentIndex put: secs.
	secondsList items: arraySecondsList " (resultList items copyWith: '0' )"
	
]

{ #category : 'as yet unclassified' }
OllamaApiExperimentsPresenter >> model_old2: modelIndex experimentIndex: experimentIndex seconds: secs [
	"Index is the index of the model, seconds is how much it has spend on it last."
	(arraySecondsList at: modelIndex) at: experimentIndex put: secs.
	secondsList items: arraySecondsList " (resultList items copyWith: '0' )"
	
]

{ #category : 'as yet unclassified' }
OllamaApiExperimentsPresenter >> model_old: modelIndex experimentIndex: experimentIndex seconds: secs [
	"Index is the index of the model, seconds is how much it has spend on it last."
	| list |
	list := secondsList items. "{ {3. 4. 3}. {4. 2} }" 
	modelIndex > list size 
		ifTrue: [ 
			"new item in the list"
			list := list, { {secs} } ]
		ifFalse: [ 
			"new secs element"
			experimentIndex > (list at: modelIndex) size 
				ifTrue:  [ list at: modelIndex put: { secs } ]
				ifFalse: [ (list at: modelIndex) at: experimentIndex put: secs] ].
	secondsList items: list " (resultList items copyWith: '0' )"
	
]

{ #category : 'as yet unclassified' }
OllamaApiExperimentsPresenter >> set_old: index seconds: secs [
	"Index is the index of the model, seconds is how much it has spend on it last."
	| list |
	list := secondsList items. "{ {3. 4. 3}. {4. 2} }" 
	index = (list size + 1) 
		ifTrue: [ list := list, { secs } ]
		ifFalse: [ list at: index put: secs ].
	secondsList items: list " (resultList items copyWith: '0' )"
	
]
