Extension { #name : 'Association' }

{ #category : '*AIActions' }
Association >> inspectionValue: aBuilder [

	<inspectorPresentationOrder: 10 title: 'Microdown'>
	self value isString ifTrue: [
			^ self value inspectionFullString: aBuilder
			"^ (Microdown asRichText: self value) inspectionText: aBuilder"
			"^ self value inspectionMicrodown: aBuilder" ].
	^ self inspectionRaw: aBuilder
]
