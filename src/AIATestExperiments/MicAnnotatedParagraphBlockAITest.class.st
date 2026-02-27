Class {
	#name : 'MicAnnotatedParagraphBlockAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refMicAnnotatedParagraphBlock'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
MicAnnotatedParagraphBlockAITest >> setUp [
	super setUp.
	refMicAnnotatedParagraphBlock := MicAnnotatedParagraphBlock new.
]

{ #category : 'AI generated test' }
MicAnnotatedParagraphBlockAITest >> testAccept [
	"Test that accept: delegates to the visitor's visitAnnotated: method 
	and returns the result of visiting the body elements, which is the body collection itself"

	| visitor result |
	refMicAnnotatedParagraphBlock instVarNamed: #body put: OrderedCollection new.
	visitor := MicrodownVisitor new.
	result := refMicAnnotatedParagraphBlock accept: visitor.
	self assert: result equals: refMicAnnotatedParagraphBlock body
]

{ #category : 'AI generated test' }
MicAnnotatedParagraphBlockAITest >> testCloseMe [
	"Test that #closeMe closes the block, verifies the label, and updates body via inline parsing."

	"Prepare: set a body value that can be parsed."
	refMicAnnotatedParagraphBlock instVarNamed: #body put: 'Some *inline* text'.

	"Exercise."
	refMicAnnotatedParagraphBlock closeMe.

	"Assert: the block is marked closed (instance variable exists on the hierarchy)."
	self assert: ((refMicAnnotatedParagraphBlock instVarNamed: #isClosed) = true).

	"Assert: body was rewritten by #closeMe (it assigns: body := self inlineParse: body)."
	self assert: ((refMicAnnotatedParagraphBlock instVarNamed: #body) ~= 'Some *inline* text')
]

{ #category : 'AI generated test' }
MicAnnotatedParagraphBlockAITest >> testDefaultLabel [
	"Test the default label of the annotated paragraph block"

	| label |
	label := refMicAnnotatedParagraphBlock defaultLabel.
	self assert: (label = 'note').
]

{ #category : 'AI generated test' }
MicAnnotatedParagraphBlockAITest >> testInitialize [
	"Test the initialization of the MicAnnotatedParagraphBlock instance."

	"Ensure the instance is initialized."
	refMicAnnotatedParagraphBlock initialize.

	"Check that validLabels is initialized correctly."
	self assert: (refMicAnnotatedParagraphBlock instVarNamed: #validLabels) equals: #('note' 'important' 'todo') asArray
]

{ #category : 'AI generated test' }
MicAnnotatedParagraphBlockAITest >> testLineMarkup [
	"Test the lineMarkup method to ensure it returns the correct markup for the annotated paragraph line."

	| markup |
	markup := refMicAnnotatedParagraphBlock lineMarkup.
	self assert: (markup = '>[!')
]

{ #category : 'AI generated test' }
MicAnnotatedParagraphBlockAITest >> testText [
	"Test that #text concatenates the #plainText of all elements returned by #textElements (which answers the #body ivar)."

	| t1 t2 result |
	"Build two real Microdown text elements (no mocks) by setting their internal bodyString slot."
	t1 := MicTextBlock new.
	t1 instVarNamed: #bodyString put: 'Hello'.

	t2 := MicTextBlock new.
	t2 instVarNamed: #bodyString put: ' world'.

	"Inject them into the annotated paragraph's body (textElements)."
	refMicAnnotatedParagraphBlock
		instVarNamed: #body
		put: (OrderedCollection with: t1 with: t2).

	"Exercise"
	result := refMicAnnotatedParagraphBlock text.

	"Verify"
	self assert: (result isKindOf: String).
	self assert: (result = 'Hello world').
]

{ #category : 'AI generated test' }
MicAnnotatedParagraphBlockAITest >> testTextElements [
	"Test the textElements method of MicAnnotatedParagraphBlock"

	| textBlock elements textElements |
	textBlock := MicTextBlock new.
	textBlock bodyString: 'Hello World'.
	elements := OrderedCollection with: textBlock.
	refMicAnnotatedParagraphBlock instVarNamed: #body put: elements.
	textElements := refMicAnnotatedParagraphBlock textElements.
	self assert: textElements equals: elements.
	self assert: (textElements first plainText = 'Hello World')
]

{ #category : 'AI generated test' }
MicAnnotatedParagraphBlockAITest >> testVerifyLabel [
	"Test the verifyLabel method to ensure it correctly validates and sets the label to lowercase if valid, otherwise uses the default label."

	"Test with a valid label in uppercase"
	refMicAnnotatedParagraphBlock instVarNamed: #label put: 'Note'.
	refMicAnnotatedParagraphBlock verifyLabel.
	self assert: (refMicAnnotatedParagraphBlock label = 'note').

	"Test with an invalid label"
	refMicAnnotatedParagraphBlock instVarNamed: #label put: 'invalid'.
	refMicAnnotatedParagraphBlock verifyLabel.
	self assert: (refMicAnnotatedParagraphBlock label = refMicAnnotatedParagraphBlock defaultLabel).
]
