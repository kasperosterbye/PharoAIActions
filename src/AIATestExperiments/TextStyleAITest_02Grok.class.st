Class {
	#name : 'TextStyleAITest_02Grok',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest_02Grok >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest_02Grok >> testClearIndents [
	"Test that clearIndents resets all indent settings to 0 regardless of previous values."

	textStyle firstIndent: 10.  "Set a non-zero first indent"
	textStyle restIndent: 20.   "Set a non-zero rest indent"
	textStyle rightIndent: 30.  "Set a non-zero right indent"
	
	textStyle clearIndents.     "Invoke the method under test"
	
	self assert: textStyle firstIndent equals: 0.   "Verify first indent is reset"
	self assert: textStyle restIndent equals: 0.    "Verify rest indent is reset"
	self assert: textStyle rightIndent equals: 0    "Verify right indent is reset"
]

{ #category : 'AI generated test' }
TextStyleAITest_02Grok >> testConsolidateReplacesMatchingFontsWithDefaultReferences [
	| defStyle defFonts nyStyle nyFonts matchingFont nonMatchingFont myStyle |
	"Get the default style and its fonts"
	defStyle := TextStyle default.
	defFonts := defStyle fontArray.
	self assert: defFonts notEmpty.
	
	"Get fonts from another known style for non-matching family"
	nyStyle := TextStyle named: 'NewYork'.
	self assert: nyStyle notNil.
	nyFonts := nyStyle fontArray.
	self assert: nyFonts notEmpty.
	
	"Create a copy of a default font (different object, same family)"
	matchingFont := defFonts first copy.
	self deny: matchingFont == defFonts first.
	
	"Create a copy of a non-default font (different family)"
	nonMatchingFont := nyFonts first copy.
	
	"Create a new TextStyle with both fonts"
	myStyle := TextStyle fontArray: { matchingFont. nonMatchingFont }.
	
	"Verify initial state: matching font is different object from default's"
	self deny: (myStyle fontArray at: 1) == (defFonts at: defFonts size).
	self assert: (myStyle fontArray at: 2) == nonMatchingFont.
	
	"Perform consolidation"
	myStyle consolidate.
	
	"Verify matching font replaced with reference to default's last font (due to loop overwriting)"
	self assert: (myStyle fontArray at: 1) == (defFonts at: defFonts size).
	
	"Verify non-matching font unchanged"
	self assert: (myStyle fontArray at: 2) == nonMatchingFont.
]

{ #category : 'AI generated test' }
TextStyleAITest_02Grok >> testLeftMarginTabAt [
	| array |
	array := Array 
		with: #(10 20)
		with: #(30 40).
	self textStyle instVarNamed: 'marginTabsArray' put: array.
	"Test that a valid index returns the first element of the tuple at that index"
	self assert: (self textStyle leftMarginTabAt: 1) equals: 10.
	self assert: (self textStyle leftMarginTabAt: 2) equals: 30.
	"Test that an invalid index (below 1) returns 0"
	self assert: (self textStyle leftMarginTabAt: 0) equals: 0.
	"Test that an invalid index (at or above size) returns 0"
	self assert: (self textStyle leftMarginTabAt: 3) equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_02Grok >> testVeryDeepCopyWithSharesInstanceVariables [
	| original copy copier sharedCollection secondCopy |
	sharedCollection := OrderedCollection new.
	original := TextStyle new.
	original instVarNamed: 'fontArray' put: { sharedCollection }.
	copier := DeepCopier new.
	copy := original veryDeepCopyWith: copier.
	"Verify that the copy is not the original but shares instance variables"
	self deny: copy == original.
	self assert: (original instVarNamed: 'fontArray') == (copy instVarNamed: 'fontArray').
	"Mutate the shared collection via original and verify copy sees the change"
	sharedCollection add: #shared.
	self assert: ((copy instVarNamed: 'fontArray') first includes: #shared).
	"Verify memoization: second call returns the same copy"
	secondCopy := original veryDeepCopyWith: copier.
	self assert: copy == secondCopy
]
