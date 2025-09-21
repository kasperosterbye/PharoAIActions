Extension { #name : 'Association' }

{ #category : '*AIAExperiments' }
Association >> inspectionValue: aBuilder [

	<inspectorPresentationOrder: 10 title: 'Speech'>
	self value isString ifTrue: [
			^ self value inspectionMicrodown: aBuilder ].
	^ self inspectionRaw: aBuilder
]
