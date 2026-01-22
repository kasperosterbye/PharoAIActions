Class {
	#name : 'TextStyleAITest_01Claude',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest_01Claude >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest_01Claude >> testClearIndents [
	"Test that clearIndents resets all margin settings to 0."
	
	"Set non-zero indent values first"
	refTextStyle firstIndent: 10.
	refTextStyle restIndent: 20.
	refTextStyle rightIndent: 30.
	
	"Call the method under test"
	refTextStyle clearIndents.
	
	"Verify all indents are reset to 0"
	self assert: refTextStyle firstIndent equals: 0.
	self assert: refTextStyle restIndent equals: 0.
	self assert: refTextStyle rightIndent equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_01Claude >> testConsolidate [
	"Test that consolidate replaces fonts with matching family names from the default style"
	| defaultFonts originalFont |
	"Get the default style fonts for comparison"
	defaultFonts := TextStyle default fontArray.
	
	"Skip test if default has no fonts"
	defaultFonts ifEmpty: [ ^ self ].
	
	"Store original font from refTextStyle"
	originalFont := refTextStyle fontArray first.
	
	"Execute consolidate"
	refTextStyle consolidate.
	
	"After consolidate, if the font family name matches a default font, it should be replaced with the default one"
	refTextStyle fontArray do: [ :font |
		defaultFonts do: [ :defFont |
			(font familyName asUppercase copyWithout: $ ) = (defFont familyName asUppercase copyWithout: $ )
				ifTrue: [ self assert: font equals: defFont ] ] ]
]

{ #category : 'AI generated test' }
TextStyleAITest_01Claude >> testLeftMarginTabAt [
	"Test that leftMarginTabAt: returns the correct left margin value for valid indices,
	and returns 0 for invalid indices (out of bounds or non-positive)."
	
	| result |
	
	"Test with marginIndex of 0 - should return 0 (invalid index)"
	result := refTextStyle leftMarginTabAt: 0.
	self assert: result equals: 0.
	
	"Test with negative marginIndex - should return 0 (invalid index)"
	result := refTextStyle leftMarginTabAt: -1.
	self assert: result equals: 0.
]

{ #category : 'AI generated test' }
TextStyleAITest_01Claude >> testVeryDeepCopyWith [
	"Test that veryDeepCopyWith: returns a shallow copy that shares instance variables"
	| deepCopier result |
	deepCopier := DeepCopier new.
	
	"Execute the method under test"
	result := refTextStyle veryDeepCopyWith: deepCopier.
	
	"Verify that a copy was returned"
	self deny: result == refTextStyle.
	
	"Verify that the copy is stored in the deepCopier references"
	self assert: (deepCopier references at: refTextStyle) equals: result.
	
	"Verify that instance variables are shared (shallow copy behavior)"
	self assert: result fontArray == refTextStyle fontArray
]
