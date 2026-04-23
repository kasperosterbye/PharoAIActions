Class {
	#name : 'Exp6',
	#superclass : 'Exp5',
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'as yet unclassified' }
Exp6 >> subtractTwo: n [

	self value: n - 2.
	self lessThanTwo ifTrue: [ ^ value ].
	^ self class new subtractTwo: value.
	
	
]
