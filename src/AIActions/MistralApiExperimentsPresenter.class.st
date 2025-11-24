Class {
	#name : 'MistralApiExperimentsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'experiments',
		'modelList',
		'secondsList',
		'currentSecondList',
		'arraySecondsList'
	],
	#category : 'AIActions-ExperimentsOLD',
	#package : 'AIActions',
	#tag : 'ExperimentsOLD'
}

{ #category : 'examples' }
MistralApiExperimentsPresenter class >> open [
	<example>
	
	^ self new open
]

{ #category : 'as yet unclassified' }
MistralApiExperimentsPresenter >> closePresenter [
	"Stop the experiemnter class, and close this Presenter"
	experiments ollamaProcess terminate.
	Transcript show: 'We are closing, but not';cr;flush.
	super window close.
]

{ #category : 'accessing' }
MistralApiExperimentsPresenter >> experiments [

	^ experiments
]

{ #category : 'accessing' }
MistralApiExperimentsPresenter >> experiments: anObject [

	experiments := anObject
]

{ #category : 'initialization' }
MistralApiExperimentsPresenter >> initialize [
	super initialize.
	titleHolder := 'Mistral Experiment Runner'.
]

{ #category : 'initialization' }
MistralApiExperimentsPresenter >> initializePresenters [
    | quitButton |
    
    modelList := SpListPresenter new items: MistralApi modelNames.
    arraySecondsList := Array new: modelList items size.
	 1 to: arraySecondsList size do: [ :i | arraySecondsList at: i put: { 0. 0. 0. 0 }  ].
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
MistralApiExperimentsPresenter >> model: modelIndex experimentIndex: experimentIndex seconds: secs [
	"Index is the index of the model, seconds is how much it has spend on it last."
	(arraySecondsList at: modelIndex) at: experimentIndex put: secs.
	secondsList items: arraySecondsList
	
]
