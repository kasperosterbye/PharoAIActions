Class {
	#name : 'TextStyleAITest_01Gemini',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest_01Gemini >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest_01Gemini >> testClearIndents [
	"Set initial non-zero indent values to ensure the method has an effect"
	refTextStyle firstIndent: 10.
	refTextStyle restIndent: 20.
	refTextStyle rightIndent: 30.

	"Execute the method under test"
	refTextStyle clearIndents.

	"Verify that all indent values are reset to 0"
	self assert: refTextStyle firstIndent equals: 0.
	self assert: refTextStyle restIndent equals: 0.
	self assert: refTextStyle rightIndent equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_01Gemini >> testConsolidate [
	| oldDefault tempDefaultStyle availableFonts fontA fontB fontACopy |
	"Get some existing fonts from the system to work with, assuming at least two are available."
	availableFonts := TextStyle default fontArray.
	self assert: availableFonts size >= 2 description: 'Not enough default fonts to run this test'.
	fontA := availableFonts at: 1.
	fontB := availableFonts at: 2.

	"Create a copy of a font. It will be equal (=) but not identical (==)."
	fontACopy := fontA copy.
	self deny: fontA identicalTo: fontACopy.

	"Remember the original default style to restore it later, preventing side-effects."
	oldDefault := TextStyle default.

	[
		"Setup: Create a temporary default style containing one of our original fonts."
		tempDefaultStyle := TextStyle fontArray: { fontA }.
		TextStyle setDefault: tempDefaultStyle.

		"Setup: Initialize our test style with the copied font and another distinct font."
		refTextStyle newFontArray: { fontACopy. fontB }.
		
		"Pre-condition: Verify the font is the non-identical copy before consolidation."
		self assert: (refTextStyle fontArray at: 1) identicalTo: fontACopy.

		"Action: Run the consolidate method."
		refTextStyle consolidate.

		"Assert: The copied font should have been replaced by the identical one from the default style."
		self assert: (refTextStyle fontArray at: 1) identicalTo: fontA.
		
		"Assert: The other font, which was not in the default style, should remain unchanged."
		self assert: (refTextStyle fontArray at: 2) identicalTo: fontB.

	] ensure: [
		"Teardown: Always restore the original default style to not affect other tests."
		TextStyle setDefault: oldDefault.
	].
]

{ #category : 'AI generated test' }
TextStyleAITest_01Gemini >> testLeftMarginTabAt [
	"Test the leftMarginTabAt: method for valid and invalid indices."

	"Setup: Populate the marginTabsArray with known values.
	The method addFirstLineIndent:restOfLineIndent: adds an array of the form #(rest first)
	to the marginTabsArray instance variable."
	refTextStyle addFirstLineIndent: 10 restOfLineIndent: 20.	"at index 1, the entry is #(20 10)"
	refTextStyle addFirstLineIndent: 30 restOfLineIndent: 40.	"at index 2, the entry is #(40 30)"
	"The marginTabsArray is now #( #(20 10) #(40 30) ) with a size of 2."

	"Test case 1: A valid index (1).
	The condition is 'marginIndex < marginTabsArray size', so 1 < 2 is true.
	It should return the first element of the tuple at index 1, which is 20."
	self assert: (refTextStyle leftMarginTabAt: 1) equals: 20.

	"Test case 2: An invalid index that is too low (0)."
	self assert: (refTextStyle leftMarginTabAt: 0) equals: 0.

	"Test case 3: An edge case invalid index, equal to the size of the array.
	The condition '2 < 2' is false, so it should return the default value of 0."
	self assert: (refTextStyle leftMarginTabAt: 2) equals: 0.

	"Test case 4: An invalid index that is too high."
	self assert: (refTextStyle leftMarginTabAt: 3) equals: 0.

]

{ #category : 'AI generated test' }
TextStyleAITest_01Gemini >> testVeryDeepCopyWith [
	| deepCopier copy |
	"Initialize a DeepCopier to handle the copy process."
	deepCopier := DeepCopier new.

	"Perform the 'very deep copy' operation. For TextStyle, this is a shallow copy because its instance variables are shared."
	copy := refTextStyle veryDeepCopyWith: deepCopier.

	"1. Assert that the copied object is not the same instance as the original."
	self assert: copy ~~ refTextStyle.

	"2. Assert that the copied object is equal in value to the original."
	self assert: copy = refTextStyle.

	"3. The method comment states 'All inst vars are meant to be shared'.
	Therefore, we assert that the fontArray instance variable is the same object (identity check), not a new copy."
	self assert: copy fontArray == refTextStyle fontArray.

	"4. Verify that primitive instance variables like 'leading' are also equal."
	self assert: copy leading = refTextStyle leading.
]
