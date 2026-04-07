Extension { #name : 'Text' }

{ #category : '*AIAExperiments' }
Text >> inspectionRichText: aBuilder [
	<inspectorPresentationOrder: -1 title: 'RichText'>

	^ MicTextPresenter new text: self
]
