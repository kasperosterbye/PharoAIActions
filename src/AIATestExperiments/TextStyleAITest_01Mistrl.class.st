Class {
	#name : 'TextStyleAITest_01Mistrl',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest_01Mistrl >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest_01Mistrl >> testClearIndents [
	"Test that clearIndents resets all indent settings to 0."

	refTextStyle firstIndent: 5.
	refTextStyle restIndent: 3.
	refTextStyle rightIndent: 2.

	refTextStyle clearIndents.

	self assert: refTextStyle firstIndent equals: 0.
	self assert: refTextStyle restIndent equals: 0.
	self assert: refTextStyle rightIndent equals: 0.
]

{ #category : 'AI generated test' }
TextStyleAITest_01Mistrl >> testConsolidate [
	"Test that consolidate replaces fonts with references to the default style's fonts when they match."

	| defFonts font |
	defFonts := TextStyle default fontArray.
	1 to: refTextStyle fontArray size do: [ :i |
		font := refTextStyle fontArray at: i.
		1 to: defFonts size do: [ :j |
			(font familyName asUppercase copyWithout: $ ) = ((defFonts at: j) familyName asUppercase copyWithout: $ )
				ifTrue: [ self assert: (refTextStyle fontArray at: i) == (defFonts at: j) ] ] ].
	refTextStyle consolidate.
	1 to: refTextStyle fontArray size do: [ :i |
		font := refTextStyle fontArray at: i.
		1 to: defFonts size do: [ :j |
			(font familyName asUppercase copyWithout: $ ) = ((defFonts at: j) familyName asUppercase copyWithout: $ )
				ifTrue: [ self assert: (refTextStyle fontArray at: i) == (defFonts at: j) ] ] ]
]

{ #category : 'AI generated test' }
TextStyleAITest_01Mistrl >> testLeftMarginTabAt [
	"Test that leftMarginTabAt: returns the correct margin tab value for valid and invalid indices."

	| validIndex invalidIndex result |

	"Set up a valid index within bounds of marginTabsArray"
	validIndex := 1.
	result := refTextStyle leftMarginTabAt: validIndex.
	self assert: result equals: (refTextStyle marginTabsArray at: validIndex) first.

	"Test with an invalid index (too small)"
	invalidIndex := 0.
	result := refTextStyle leftMarginTabAt: invalidIndex.
	self assert: result equals: 0.

	"Test with an invalid index (too large)"
	invalidIndex := refTextStyle marginTabsArray size + 1.
	result := refTextStyle leftMarginTabAt: invalidIndex.
	self assert: result equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_01Mistrl >> testVeryDeepCopyWith [
	"Test that veryDeepCopyWith: correctly shares instances as per its comment."

	| deepCopier copiedInstance |
	deepCopier := DeepCopier new.
	copiedInstance := refTextStyle veryDeepCopyWith: deepCopier.

	self assert: copiedInstance == refTextStyle.
	self assert: (deepCopier references includesKey: refTextStyle).
]
