Class {
	#name : 'MicRawBlockAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicRawBlock'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicRawBlockAITest >> setUp [
	super setUp.
	refMicRawBlock := MicRawBlock new.
]

{ #category : 'AI generated test' }
MicRawBlockAITest >> testAccept [
	| dumper |
	"Set a body string for testing the output"
	refMicRawBlock bodyString: 'test'.
	"Create a real dumper visitor to process the raw block"
	dumper := MicRealDumper new.
	"Send accept: to the raw block with the visitor"
	refMicRawBlock accept: dumper.
	"Verify that the visitor's stream contains the expected dumped representation"
	self assert: dumper contents equals: '(MicRawBlock new substring: ''test'')'
]
