Class {
	#name : 'TextStyleAITest_01DeepSeek',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest_01DeepSeek >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest_01DeepSeek >> testClearIndents [
	"Test that clearIndents resets all margin settings to 0."

	"Set initial non-zero indents"
	refTextStyle firstIndent: 10.
	refTextStyle restIndent: 20.
	refTextStyle rightIndent: 30.

	"Clear the indents"
	refTextStyle clearIndents.

	"Verify all indents are reset to 0"
	self assert: refTextStyle firstIndent equals: 0.
	self assert: refTextStyle restIndent equals: 0.
	self assert: refTextStyle rightIndent equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_01DeepSeek >> testConsolidate [
	"Test that the consolidate method replaces fonts with those from the default style when they match by family name."

	| consolidatedStyle defaultFonts |
	"Execute the method under test"
	refTextStyle consolidate.
	
	"Verify the result: The fontArray should now reference the default style's font objects for matching family names"
	consolidatedStyle := refTextStyle.
	defaultFonts := TextStyle default fontArray.
	
	"Check each font in the consolidated style"
	consolidatedStyle fontArray doWithIndex: [ :font :index |
		"Find a font in the default style with the same family name (case and space insensitive)"
		defaultFonts do: [ :defaultFont |
			(font familyName asUppercase copyWithout: $ ) = (defaultFont familyName asUppercase copyWithout: $ )
				ifTrue: [
					"Assert that the font in the style is now the exact same object as the one in the default style"
					self assert: font == defaultFont
				]
		]
	]
]

{ #category : 'AI generated test' }
TextStyleAITest_01DeepSeek >> testLeftMarginTabAt [
	"Test the leftMarginTabAt: method for various marginIndex values."

	| result |
	"Test with a valid margin index within the bounds of marginTabsArray"
	result := refTextStyle leftMarginTabAt: 1.
	self assert: result equals: (refTextStyle marginTabsArray at: 1) at: 1.

	"Test with a margin index of 0, which is out of bounds and should return 0"
	result := refTextStyle leftMarginTabAt: 0.
	self assert: result equals: 0.

	"Test with a margin index equal to the size of marginTabsArray, which is out of bounds and should return 0"
	result := refTextStyle leftMarginTabAt: refTextStyle marginTabsArray size.
	self assert: result equals: 0.

	"Test with a margin index larger than the size of marginTabsArray, which is out of bounds and should return 0"
	result := refTextStyle leftMarginTabAt: refTextStyle marginTabsArray size + 1.
	self assert: result equals: 0
]

{ #category : 'Failed generated test' }
TextStyleAITest_01DeepSeek >> testVeryDeepCopyWith [
	self fail: 'Test code could not be generated' 

"testVeryDeepCopyWith
	""Test that veryDeepCopyWith: returns a shallow copy and uses the deepCopier's references dictionary to avoid duplication.""

	| deepCopier originalCopy |
	""Set up a deepCopier with an empty references dictionary""
	deepCopier := DeepCopier new.
	deepCopier references: (Dictionary new).

	""Execute the method under test""
	originalCopy := refTextStyle veryDeepCopyWith: deepCopier.

	""Verify the returned object is a shallow copy of the original""
	self assert: originalCopy class equals: refTextStyle class.
	self assert: originalCopy ~~ refTextStyle.

	""Verify the deepCopier's references dictionary now contains the original object mapping to the copy""
	self assert: (deepCopier references at: refTextStyle) equals: originalCopy.

	""Call the method again with the same deepCopier to test the 'ifAbsentPut' block is not executed""
	| secondCopy |
	secondCopy := refTextStyle veryDeepCopyWith: deepCopier.
	
	""Verify the same copy is returned from the references dictionary, not a new one""
	self assert: secondCopy equals: originalCopy."
]
