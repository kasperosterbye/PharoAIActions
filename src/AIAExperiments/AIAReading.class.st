Class {
	#name : 'AIAReading',
	#superclass : 'SpPresenter',
	#instVars : [
		'nextButton',
		'readingText',
		'answerInput',
		'resultText'
	],
	#category : 'AIAExperiments-Reading',
	#package : 'AIAExperiments',
	#tag : 'Reading'
}

{ #category : 'examples' }
AIAReading class >> open [
	
	<example>
	^ self new open
]

{ #category : 'as yet unclassified' }
AIAReading >> answerChanged: aString [
	Transcript show: aString; cr.
]

{ #category : 'initialization' }
AIAReading >> connectPresenters [
	super connectPresenters.
	answerInput whenTextChangedDo: [ :newText |
		self answerChanged: newText ]
]

{ #category : 'initialization' }
AIAReading >> defaultLayout [
	^SpBoxLayout newTopToBottom
			add: nextButton expand: false;
			add: readingText ;
			add: answerInput;
			add: resultText;
		yourself.
]

{ #category : 'initialization' }
AIAReading >> initializePresenters [
	super initializePresenters.
	nextButton := self newButton.
	nextButton
		label: 'next reader';
		action: [ self nextReader ].
		
	readingText := self newText.
	
	answerInput := self newText.
	
	resultText:= self newLabel.
	
	readingText text: 'AAA' , String lf, 'BBB'.
	answerInput text: ''.
	self connectPresenters.
	resultText label: 'Later'
]

{ #category : 'initialization' }
AIAReading >> initializeWindow: aWindowPresenter [
	"Set the window title."
	super initializeWindow: aWindowPresenter.
	aWindowPresenter 
		title: 'Reading test';
		initialExtent: 400 @ 250.
]

{ #category : 'as yet unclassified' }
AIAReading >> nextReader [
	readingText label: 'hund grøn stol kaffe'.
	answerInput text: ''.
	resultText label: ''
]
