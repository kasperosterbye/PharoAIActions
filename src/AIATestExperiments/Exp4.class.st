Class {
	#name : 'Exp4',
	#superclass : 'Object',
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'as yet unclassified' }
Exp4 >> exp4method1 [
	^ 99
]

{ #category : 'as yet unclassified' }
Exp4 >> exp4method2: x [
	^ x + self exp4method1 
]
