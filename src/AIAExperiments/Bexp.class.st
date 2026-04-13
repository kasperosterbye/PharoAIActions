Class {
	#name : 'Bexp',
	#superclass : 'Object',
	#instVars : [
		'aaa',
		'bbb'
	],
	#category : 'AIAExperiments-MicroURLMisc',
	#package : 'AIAExperiments',
	#tag : 'MicroURLMisc'
}

{ #category : 'accessing' }
Bexp >> first: arg [
| temp |
temp := arg * 2.
thisContext copy inspect.
^ temp
]
