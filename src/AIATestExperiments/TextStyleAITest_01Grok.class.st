"
### Class Comment: TextStyleAITest_01Grok
#### Overview

This class is a test case for the `TextStyle` class, specifically designed to verify its behavior and functionality. It provides a set of tests to ensure that the `TextStyle` class works as expected.

#### Purpose

The purpose of this class is to provide a comprehensive testing framework for the `TextStyle` class, covering various aspects such as:

* Margin tab at index
* Clearing indents
* Consolidation of fonts
* Deep copying with sharing

#### Key Features

* Provides a set of tests to verify the behavior of the `TextStyle` class
* Covers various aspects of the class, including margin tabs, clearing indents, consolidation of fonts, and deep copying
* Uses Pharo's testing framework to write and run tests

#### Example Usage

To use this class, you would typically create an instance of it and run its tests using a testing framework such as Pharo's built-in `TestCase` class.

```markdown
| test |
test := TextStyleAITest_01Grok new.
test setUp.
test run.
```

This example creates a new instance of the `TextStyleAITest_01Grok` class, sets up the test environment using the `setUp` method, and runs the tests using the `run` method.
"
Class {
	#name : 'TextStyleAITest_01Grok',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest_01Grok >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest_01Grok >> testClearIndents [
	| originalFirst originalRest originalRight |
	
	"Set non-zero indent values to verify reset"
	originalFirst := 10.
	originalRest := 20.
	originalRight := 30.
	refTextStyle firstIndent: originalFirst.
	refTextStyle restIndent: originalRest.
	refTextStyle rightIndent: originalRight.
	
	"Verify the values were set correctly before clearing"
	self assert: refTextStyle firstIndent equals: originalFirst.
	self assert: refTextStyle restIndent equals: originalRest.
	self assert: refTextStyle rightIndent equals: originalRight.
	
	"Call the method under test"
	refTextStyle clearIndents.
	
	"Assert all indents are reset to 0"
	self assert: refTextStyle firstIndent equals: 0.
	self assert: refTextStyle restIndent equals: 0.
	self assert: refTextStyle rightIndent equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_01Grok >> testConsolidate [
	| defaultFonts testFontArray |
	defaultFonts := TextStyle default fontArray.
	"Create a test font array by copying the first two default fonts to have different instances but same families"
	testFontArray := defaultFonts first two collect: [ :eachFont | eachFont copy ].
	"Set the font array on the reference text style"
	refTextStyle fontArray: testFontArray.
	"Perform consolidation"
	refTextStyle consolidate.
	"Verify that both positions now reference the last default font due to overwriting on family match"
	self assert: refTextStyle fontArray first == defaultFonts last.
	self assert: refTextStyle fontArray second == defaultFonts last
]

{ #category : 'AI generated test' }
TextStyleAITest_01Grok >> testLeftMarginTabAt [
	| testMarginTabs |
	
	"Set up a sample marginTabsArray with two tuples for testing valid and invalid indices"
	testMarginTabs := { {10. 20}. {30. 40} }.
	refTextStyle instVarNamed: #marginTabsArray put: testMarginTabs.
	
	"Test valid index 1 returns the first element of the first tuple"
	self assert: (refTextStyle leftMarginTabAt: 1) equals: 10.
	
	"Test valid index 2 returns the first element of the second tuple"
	self assert: (refTextStyle leftMarginTabAt: 2) equals: 30.
	
	"Test invalid index 0 returns 0"
	self assert: (refTextStyle leftMarginTabAt: 0) equals: 0.
	
	"Test invalid index beyond size (3) returns 0"
	self assert: (refTextStyle leftMarginTabAt: 3) equals: 0
]

{ #category : 'AI generated test' }
TextStyleAITest_01Grok >> testVeryDeepCopyWith [
	| deepCopier copy fontArray |
	
	"Create a complex instance variable to test sharing"
	fontArray := OrderedCollection new.
	refTextStyle newFontArray: fontArray.
	
	"Perform the deep copy using a DeepCopier"
	deepCopier := DeepCopier new.
	copy := refTextStyle veryDeepCopyWith: deepCopier.
	
	"Assert that a new copy was created"
	self assert: copy ~= refTextStyle.
	
	"Assert that instance variables are shared (shallow copy behavior)"
	self assert: copy fontArray == fontArray.
	
	"Modify the shared instance variable to confirm sharing"
	fontArray add: 42.
	self assert: copy fontArray size equals: 1.
	self assert: refTextStyle fontArray size equals: 1
]
