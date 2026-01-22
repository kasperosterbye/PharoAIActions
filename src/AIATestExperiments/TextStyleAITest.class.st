Class {
	#name : 'TextStyleAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest >> testClearIndents [
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
TextStyleAITest >> testConsolidate [
	"Test that consolidate replaces fonts with matching family names from the default style"
	| defaultFonts originalFont |
	"Get the default style fonts for comparison"
	defaultFonts := TextStyle default fontArray.
	
	"Skip test if default style has no fonts"
	defaultFonts ifEmpty: [ ^ self ].
	
	"Store original font from refTextStyle for comparison"
	originalFont := refTextStyle fontArray first.
	
	"Execute consolidate on refTextStyle"
	refTextStyle consolidate.
	
	"Verify that fonts with matching family names are replaced with default style fonts"
	refTextStyle fontArray do: [ :font |
		defaultFonts do: [ :defFont |
			(font familyName asUppercase copyWithout: $ ) = (defFont familyName asUppercase copyWithout: $ )
				ifTrue: [ self assert: (defaultFonts includes: font) ] ] ]
]

{ #category : 'AI generated test' }
TextStyleAITest >> testLeftMarginTabAt [
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
TextStyleAITest >> testVeryDeepCopyWith [
	"Test that veryDeepCopyWith: returns a shallow copy that shares all instance variables"
	| deepCopier copy |
	deepCopier := DeepCopier new.
	
	"Perform the deep copy"
	copy := refTextStyle veryDeepCopyWith: deepCopier.
	
	"Verify that a copy was returned"
	self assert: copy isNotNil.
	
	"Verify that the copy is not identical to the original"
	self deny: copy == refTextStyle.
	
	"Verify that the copy is of the same class"
	self assert: copy class equals: refTextStyle class.
	
	"Verify that instance variables are shared (shallow copy behavior)"
	self assert: copy fontArray == refTextStyle fontArray.
	
	"Verify that the copy is stored in the deepCopier references"
	self assert: (deepCopier references at: refTextStyle) equals: copy.
	
	"Verify that calling veryDeepCopyWith: again returns the same cached copy"
	self assert: (refTextStyle veryDeepCopyWith: deepCopier) == copy.
]
