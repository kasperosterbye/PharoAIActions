Class {
	#name : 'Bexp',
	#superclass : 'Object',
	#instVars : [
		'aaa',
		'bbb'
	],
	#category : 'AIAExperiments-MicroUML',
	#package : 'AIAExperiments',
	#tag : 'MicroUML'
}

{ #category : 'accessing' }
Bexp >> first: arg [
| temp |
temp := arg * 2.
thisContext copy inspect.
^ temp
]
