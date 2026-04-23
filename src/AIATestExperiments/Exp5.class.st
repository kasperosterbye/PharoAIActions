Class {
	#name : 'Exp5',
	#superclass : 'Object',
	#instVars : [
		'value'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'accessing' }
Exp5 >> lessThanTwo [
	^ value < 2
]

{ #category : 'accessing' }
Exp5 >> value: v [
	value := v.
]
