Class {
	#name : 'TextStyleAITest_02Gemini',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest_02Gemini >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest_02Gemini >> testClearIndents [
	"This test verifies that the clearIndents method resets all indent settings to 0."
	| style |
	
	"1. Arrange: Create a TextStyle instance and set its indents to non-zero values."
	style := TextStyle new.
	style firstIndent: 10.
	style restIndent: 20.
	style rightIndent: 30.

	"2. Act: Call the method under test."
	style clearIndents.

	"3. Assert: Verify that all indent values have been reset to 0."
	self assert: style firstIndent equals: 0.
	self assert: style restIndent equals: 0.
	self assert: style rightIndent equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_02Gemini >> testConsolidate [
	"Tests that a font in the receiver is replaced by an identical font
	from the default style after consolidation, while other fonts are unaffected.
	This test assumes setUp has created:
	- A default TextStyle with a font we'll call 'replacementFont'.
	- A 'testStyle' (the receiver of consolidate) with two fonts:
		1. A font that has the same family name as replacementFont but is a different object.
		2. A font with a unique family name not in the default style."
	| fontToBeReplaced originalUnmatchedFont |
	
	"Arrange: Capture the original font objects from the test style before consolidation."
	fontToBeReplaced := testStyle fontArray at: 1.
	originalUnmatchedFont := testStyle fontArray at: 2.

	"Act: Run the consolidation process on the test style."
	testStyle consolidate.

	"Assert: Verify the results of the consolidation."
	
	"1. The font with the matching family name should now be the *exact same object* as the one in the default style."
	self assert: (testStyle fontArray at: 1) == replacementFont.
	self deny: (testStyle fontArray at: 1) == fontToBeReplaced.

	"2. The font with no matching family name should remain unchanged."
	self assert: (testStyle fontArray at: 2) == originalUnmatchedFont.

	"3. The total number of fonts in the style should not change."
	self assert: testStyle fontArray size equals: 2.
]

{ #category : 'AI generated test' }
TextStyleAITest_02Gemini >> testLeftMarginTabAt [
	| textStyle |
	textStyle := TextStyle new.
	"The method under test depends on the 'marginTabsArray' instance variable.
	 Since no public setter is available in the provided context, we use reflection 
	 to set the instance variable directly for this test."
	textStyle
		instVarNamed: 'marginTabsArray'
		put: #(#(10 1) #(20 2) #(30 3)).

	"1. Test with valid indices. 
	 The method should return the first element of the tuple at the given index."
	self assert: (textStyle leftMarginTabAt: 1) equals: 10.
	self assert: (textStyle leftMarginTabAt: 2) equals: 20.

	"2. Test boundary conditions which should return 0.
	 The implementation checks for 'marginIndex > 0' and 'marginIndex < size'."
	"An index of 0 fails the first check."
	self assert: (textStyle leftMarginTabAt: 0) equals: 0.
	"An index of 3 (the size of the array) fails the second check."
	self assert: (textStyle leftMarginTabAt: 3) equals: 0.

	"3. Test with out-of-bounds indices which should also return 0."
	"A negative index."
	self assert: (textStyle leftMarginTabAt: -5) equals: 0.
	"An index greater than the size."
	self assert: (textStyle leftMarginTabAt: 100) equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_02Gemini >> testVeryDeepCopyWith [
	| deepCopy |
	"This test verifies the behavior of veryDeepCopyWith:.
	 The implementation indicates that it should behave like a shallow copy,
	 sharing its instance variables rather than copying them deeply."

	"Perform a very deep copy on the textStyle instance variable initialized in setUp."
	deepCopy := textStyle veryDeepCopy.

	"1. Assert that the copied object is a new, distinct instance."
	self assert: deepCopy ~~ textStyle.

	"2. Assert that the copy is considered equal to the original."
	self assert: deepCopy = textStyle.

	"3. Assert that the instance variables are shared, not copied.
	   The fontArray in the copy should be the *same object* as in the original."
	self assert: deepCopy fontArray == textStyle fontArray
]
