Class {
	#name : 'TextStyleAITest_02Claude',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest_02Claude >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest_02Claude >> testClearIndents [
	"Test that clearIndents resets all margin settings to 0."
	| textStyle |
	"Create a TextStyle instance with a font array"
	textStyle := TextStyle fontArray: { StandardFonts defaultFont }.
	
	"Set non-zero indent values"
	textStyle firstIndent: 10.
	textStyle restIndent: 20.
	textStyle rightIndent: 30.
	
	"Call clearIndents to reset all margins"
	textStyle clearIndents.
	
	"Verify all indents are now 0"
	self assert: textStyle firstIndent equals: 0.
	self assert: textStyle restIndent equals: 0.
	self assert: textStyle rightIndent equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_02Claude >> testConsolidate [
	"Test that consolidate replaces fonts with matching family names from the default style"
	| defaultStyle testStyle defaultFonts testFonts |
	
	"Get the default text style and its fonts"
	defaultStyle := TextStyle default.
	defaultFonts := defaultStyle fontArray.
	
	"Skip test if no default fonts available"
	defaultFonts ifEmpty: [ ^ self ].
	
	"Create a test style with a copy of the default fonts"
	testFonts := defaultFonts copy.
	testStyle := TextStyle fontArray: testFonts.
	
	"Verify the test style has fonts before consolidation"
	self deny: testStyle fontArray isEmpty.
	
	"Execute consolidate"
	testStyle consolidate.
	
	"After consolidation, fonts with matching family names should be identical objects to default fonts"
	1 to: testStyle fontArray size do: [ :i |
		| testFont |
		testFont := testStyle fontArray at: i.
		1 to: defaultFonts size do: [ :j |
			| defaultFont |
			defaultFont := defaultFonts at: j.
			(testFont familyName asUppercase copyWithout: $ ) = (defaultFont familyName asUppercase copyWithout: $ )
				ifTrue: [ self assert: (testStyle fontArray at: i) identicalTo: defaultFont ] ] ]
]

{ #category : 'AI generated test' }
TextStyleAITest_02Claude >> testLeftMarginTabAt [
	"Test that leftMarginTabAt: returns the correct left margin value for valid indices and 0 for invalid indices."
	| textStyle result |
	"Create a TextStyle instance using the default"
	textStyle := TextStyle default.
	
	"Test with an invalid index of 0, should return 0"
	result := textStyle leftMarginTabAt: 0.
	self assert: result equals: 0.
	
	"Test with a negative index, should return 0"
	result := textStyle leftMarginTabAt: -1.
	self assert: result equals: 0.
]

{ #category : 'AI generated test' }
TextStyleAITest_02Claude >> testVeryDeepCopyWith [
	"Test that veryDeepCopyWith: returns a shallow copy that shares instance variables"
	| original deepCopier copy |
	
	"Create a TextStyle instance to test"
	original := TextStyle default.
	
	"Create a DeepCopier instance"
	deepCopier := DeepCopier new.
	
	"Perform the deep copy"
	copy := original veryDeepCopyWith: deepCopier.
	
	"Verify that the copy is not identical to the original"
	self deny: copy == original.
	
	"Verify that the copy is equal to the original (shallow copy)"
	self assert: copy class equals: original class.
	
	"Verify that calling veryDeepCopyWith: again returns the same cached copy"
	self assert: (original veryDeepCopyWith: deepCopier) == copy.
]
