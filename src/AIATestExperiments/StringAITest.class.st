Class {
	#name : 'StringAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refString'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
StringAITest >> setUp [
	super setUp.
	refString := String new.
]

{ #category : 'AI generated test' }
StringAITest >> testAsByteArray [
	"Test the asByteArray method of String, which converts the string to a ByteArray of ASCII values."

	"Test empty string"
	self assert: (refString asByteArray isEmpty).

	refString := 'a'.
	self assert: (refString asByteArray = #[97]).

	refString := 'A'.
	self assert: (refString asByteArray = #[65]).

	refString := 'ABA'.
	self assert: (refString asByteArray = #[65 66 65]).

	refString := ' '.
	self assert: (refString asByteArray = #[32]).
]

{ #category : 'AI generated test' }
StringAITest >> testAsInteger [
	"Test that asInteger correctly parses positive integers"

	refString := '123'.
	self assert: refString asInteger equals: 123.
	refString := '-123'.
	self assert: refString asInteger = -123. "Test that asInteger correctly parses zero"
	refString := '0'.
	self assert: refString asInteger = 0. "Test that asInteger trims spaces"
	refString := ' 456 '.
	self assert: refString asInteger = 456. "Test that asInteger returns nil for invalid input"
	refString := 'abc'.
	self assert: refString asInteger isNil. "Test that asInteger returns nil for empty string"
	refString := ''.
	self assert: refString asInteger isNil
]

{ #category : 'AI generated test' }
StringAITest >> testFindLastOccurrenceOfStringStartingAt [
	"Test the findLastOccurrenceOfString:startingAt: method for various cases including multiple occurrences, case sensitivity, and no match."

	refString := 'abcabcabc'.
	"Test finding the last occurrence from the beginning"
	self assert: (refString findLastOccurrenceOfString: 'abc' startingAt: 1) equals: 7.
	"Test finding the last occurrence starting in the middle"
	self assert: (refString findLastOccurrenceOfString: 'abc' startingAt: 5) equals: 7.
	"Test no occurrence starting after the last one"
	self assert: (refString findLastOccurrenceOfString: 'abc' startingAt: 8) equals: 0.

	refString := 'hello world'.
	"Test single occurrence from the beginning"
	self assert: (refString findLastOccurrenceOfString: 'world' startingAt: 1) equals: 7.
	"Test case sensitivity"
	self assert: (refString findLastOccurrenceOfString: 'World' startingAt: 1) equals: 0.
	"Test starting at the occurrence position"
	self assert: (refString findLastOccurrenceOfString: 'world' startingAt: 7) equals: 7.
	"Test starting after the occurrence"
	self assert: (refString findLastOccurrenceOfString: 'world' startingAt: 12) equals: 0.

	refString := 'no match here'.
	"Test when substring is not found"
	self assert: (refString findLastOccurrenceOfString: 'xyz' startingAt: 1) equals: 0.
]

{ #category : 'AI generated test' }
StringAITest >> testFindStringStartingAtCaseSensitive [
	| key start result |
	
	"Set up the reference string for testing"
	refString := 'Hello World hello world'.
	
	"Test case-sensitive match starting at position 1 for 'Hello'"
	key := 'Hello'.
	start := 1.
	result := refString findString: key startingAt: start caseSensitive: true.
	self assert: result equals: 1.
	
	"Test case-insensitive match starting at position 1 for 'hello' (matches 'Hello')"
	key := 'hello'.
	start := 1.
	result := refString findString: key startingAt: start caseSensitive: false.
	self assert: result equals: 1.
	
	"Test case-sensitive match starting at position 1 for 'hello' (finds later occurrence)"
	key := 'hello'.
	start := 1.
	result := refString findString: key startingAt: start caseSensitive: true.
	self assert: result equals: 13.
	
	"Test no match when starting beyond the substring position"
	key := 'World'.
	start := 10.
	result := refString findString: key startingAt: start caseSensitive: true.
	self assert: result equals: 0.
	
	"Test case-insensitive match starting beyond case-sensitive position"
	key := 'world'.
	start := 10.
	result := refString findString: key startingAt: start caseSensitive: false.
	self assert: result equals: 19.
	
	"Test no match when starting beyond the end of the string"
	key := 'xyz'.
	start := 30.
	result := refString findString: key startingAt: start caseSensitive: true.
	self assert: result equals: 0.
]

{ #category : 'AI generated test' }
StringAITest >> testNumArgs [
	"Test the numArgs method for various selector-like strings, including valid unary, binary, keyword selectors and invalid cases."

	| testCases |
	testCases := {
		'' -> -1.  "Empty string is invalid"
		'foo' -> 0.  "Valid unary selector"
		'foo:' -> 1.  "Valid single keyword selector"
		'foo:bar:' -> 2.  "Valid multi-keyword selector"
		'+' -> 1.  "Valid binary selector"
		':' -> -1.  "Starts with colon, invalid for binary"
		'1foo' -> -1.  "Starts with digit, invalid for unary/keyword"
		'foo1' -> 0.  "Digits allowed in unary"
		'foo:1' -> -1.  "Does not end with colon after keyword part"
		'foo:1:' -> -1.  "Colon after digit in keyword"
		':foo' -> -1.  "Colon at start"
		'foo::' -> -1.  "Consecutive colons"
		'foo ~' -> -1.  "Invalid character (tilde in unary)"
		'fooBar' -> 0.  "Valid unary with mixed case"
		'===' -> 1.  "Valid binary with multiple specials"
		'fooBar:' -> 1.  "Valid keyword with camel case"
		'a+' -> -1.  "Mixed unary and binary chars"
		'~' -> 1.  "Valid binary selector with tilde"
	}.

	testCases do: [ :each |
		self assert: (each key numArgs = each value) ]
]

{ #category : 'AI generated test' }
StringAITest >> testTrimBoth [
	"Test trimming separators from both sides of the string."

	"Test with leading and trailing spaces"
	refString := '  hello  '.
	self assert: (refString trimBoth) equals: 'hello'.

	"Test with no spaces"
	refString := 'hello'.
	self assert: (refString trimBoth) equals: 'hello'.

	"Test with empty string"
	refString := ''.
	self assert: (refString trimBoth) equals: ''.
]
