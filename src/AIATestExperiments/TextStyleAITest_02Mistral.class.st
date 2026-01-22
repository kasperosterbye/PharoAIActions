Class {
	#name : 'TextStyleAITest_02Mistral',
	#superclass : 'TestCase',
	#instVars : [
		'refTextStyle'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TextStyleAITest_02Mistral >> setUp [
	super setUp.
	refTextStyle := TextStyle new.
]

{ #category : 'AI generated test' }
TextStyleAITest_02Mistral >> testClearIndents [
	"Test that clearIndents resets all margin settings to 0."

	| textStyle |
	textStyle := TextStyle new.
	textStyle firstIndent: 10.
	textStyle restIndent: 5.
	textStyle rightIndent: 3.

	textStyle clearIndents.

	self assert: textStyle firstIndent equals: 0.
	self assert: textStyle restIndent equals: 0.
	self assert: textStyle rightIndent equals: 0.
]

{ #category : 'AI generated test' }
TextStyleAITest_02Mistral >> testConsolidateReplacesMatchingFontsWithDefault [
	"Test that consolidate replaces fonts in the style with matching fonts from the default style."

	| defaultStyle testStyle defaultFonts testFonts fontToReplace |

	"Set up default and test styles"
	defaultStyle := TextStyle default.
	testStyle := TextStyle new.

	"Create a font that will be replaced (same family name as default)"
	fontToReplace := defaultStyle fontArray first copy.
	testStyle fontArray: {fontToReplace}.

	"Consolidate the test style"
	testStyle consolidate.

	"Verify that the font was replaced with the default one"
	defaultFonts := defaultStyle fontArray.
	testFonts := testStyle fontArray.

	self assert: testFonts size equals: defaultFonts size.
	self assert: (testFonts first == defaultFonts first) description: 'Font should be replaced with default font'
]

{ #category : 'Failed generated test' }
TextStyleAITest_02Mistral >> testLeftMarginTabAt [
	self fail: 'Test code could not be generated' 

"testLeftMarginTabAtValidIndex
    ""Test that leftMarginTabAt: returns the correct tab value for a valid margin index.""

    | style marginIndex expectedTab |
    style := TextStyle new.
    marginIndex := 2. ""Assuming marginTabsArray has at least 3 elements""
    expectedTab := 42. ""Arbitrary value for testing""

    ""Set up the marginTabsArray with a known value at marginIndex""
    style marginTabsArray: (Array with: 0 with: expectedTab with: 0).

    ""Verify the method returns the expected tab value""
    self assert: (style leftMarginTabAt: marginIndex) equals: expectedTab
```

```smalltalk
testLeftMarginTabAtInvalidIndex
    ""Test that leftMarginTabAt: returns 0 for an invalid margin index.""

    | style marginIndex |
    style := TextStyle new.
    marginIndex := 5. ""Assuming marginTabsArray has fewer than 6 elements""

    ""Set up the marginTabsArray with a known size""
    style marginTabsArray: (Array with: 0 with: 0).

    ""Verify the method returns 0 for an out-of-bounds index""
    self assert: (style leftMarginTabAt: marginIndex) equals: 0"
]

{ #category : 'AI generated test' }
TextStyleAITest_02Mistral >> testVeryDeepCopyWith [
	| original copy deepCopier |
	original := TextStyle new.
	deepCopier := DeepCopier new.
	copy := original veryDeepCopyWith: deepCopier.
	self assert: copy == original.
	self assert: (deepCopier references includesKey: original)
]
