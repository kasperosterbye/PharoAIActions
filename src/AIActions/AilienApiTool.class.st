Class {
	#name : 'AilienApiTool',
	#superclass : 'Object',
	#instVars : [
		'name',
		'required'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
AilienApiTool >> evaluateTool: descs [
	| desc desc1|
	desc := descs first.
	desc1 := descs second.
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> name.
            'description' -> desc.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    required -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> desc1
                    })
                }).
                'required' -> {required} 
            })
        })
    }
]

{ #category : 'initialization' }
AilienApiTool >> executeTool: args [
	Transcript << self class name asString << ': ' << (args values first) << String cr.
]

{ #category : 'accessing' }
AilienApiTool >> name [
	^ name
]

{ #category : 'accessing' }
AilienApiTool >> required [
	^ required
]
