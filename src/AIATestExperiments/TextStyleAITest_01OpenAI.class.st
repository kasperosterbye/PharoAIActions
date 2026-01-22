Class {
	#name : 'TextStyleAITest_01OpenAI',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest_01OpenAI >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest_01OpenAI >> testClearIndents [
	"Test that clearIndents resets all margin (index) settings to 0."

	"Given a TextStyle with non-zero indents"
	refTextStyle
		firstIndent: 10;
		restIndent: 20;
		rightIndent: 30.

	"When we clear the indents"
	refTextStyle clearIndents.

	"Then all indents should be reset to 0"
	self assert: refTextStyle firstIndent equals: 0.
	self assert: refTextStyle restIndent equals: 0.
	self assert: refTextStyle rightIndent equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_01OpenAI >> testConsolidate [
	"Test that consolidate replaces fonts with the ones from the default TextStyle
	 when families match, and leaves other fonts unchanged."

	| defaultFonts otherFonts initialFirstFont initialSecondFont |
	"Get the fonts from the default style and from the style under test"
	defaultFonts := TextStyle default fontArray.
	otherFonts := refTextStyle fontArray.

	"Preconditions: we expect at least two fonts to perform the test meaningfully"
	self assert: defaultFonts size >= 1.
	self assert: otherFonts size >= 2.

	"Record initial fonts from the style under test"
	initialFirstFont := otherFonts first.
	initialSecondFont := otherFonts second.

	"Run the method under test"
	refTextStyle consolidate.

	"After consolidation, fonts that share a family with the default style
	 should be replaced by the corresponding default font instance.
	 For the purposes of this test, we check that any exact family-name match
	 in the first position is now the default font instance."
	(defaultFonts anySatisfy: [ :each | 
		(each familyName asUppercase copyWithout: $ ) 
			= (initialFirstFont familyName asUppercase copyWithout: $ ) ])
		ifTrue: [
			self assert: (refTextStyle fontArray first == 
				(defaultFonts detect: [ :each | 
					(each familyName asUppercase copyWithout: $ ) 
						= (initialFirstFont familyName asUppercase copyWithout: $ ) ])) ].

	"Fonts with a different family should remain unchanged.
	 If the second font has a family not present in the default fonts,
	 it should still be the same instance after consolidation."
	(defaultFonts anySatisfy: [ :each | 
		(each familyName asUppercase copyWithout: $ ) 
			= (initialSecondFont familyName asUppercase copyWithout: $ ) ])
		ifFalse: [
			self assert: refTextStyle fontArray second == initialSecondFont ].
]

{ #category : 'AI generated test' }
TextStyleAITest_01OpenAI >> testLeftMarginTabAt [
	"Test the behavior of #leftMarginTabAt: for valid and invalid margin indexes."

	| result validIndex invalidLowIndex invalidHighIndex |
	"Choose a valid index within the marginTabsArray bounds"
	validIndex := 1.
	"Indexes less than or equal to 0 are invalid"
	invalidLowIndex := 0.
	"Indexes greater than or equal to the size of marginTabsArray are invalid"
	invalidHighIndex := refTextStyle marginTabsArray size.

	"Valid index should return the first element of the tuple at that index"
	result := refTextStyle leftMarginTabAt: validIndex.
	self assert: result equals: ((refTextStyle marginTabsArray at: validIndex) at: 1).

	"Index <= 0 should return 0"
	result := refTextStyle leftMarginTabAt: invalidLowIndex.
	self assert: result equals: 0.

	"Index >= marginTabsArray size should return 0"
	result := refTextStyle leftMarginTabAt: invalidHighIndex.
	self assert: result equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_01OpenAI >> testVeryDeepCopyWith [
	"Test that veryDeepCopyWith: returns a shallow copy remembered in the deepCopier references dictionary,
	and that the copy is a different instance but of the same class and with shared instance variables."

	| deepCopier copy |
	"Create a deepCopier with a references dictionary"
	deepCopier := Dictionary new.
	deepCopier at: #references put: Dictionary new.

	"Call veryDeepCopyWith: on the reference text style"
	copy := refTextStyle veryDeepCopyWith: deepCopier.

	"Assert that the result is a different instance"
	self deny: copy == refTextStyle.

	"Assert that the result has the same class"
	self assert: copy class equals: refTextStyle class.

	"Assert that the deepCopier remembers the copy under the original"
	self assert: (deepCopier at: #references) at: refTextStyle equals: copy.
]
