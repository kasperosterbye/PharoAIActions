Class {
	#name : 'AIATestBuilderExperiments',
	#superclass : 'Object',
	#instVars : [
		'classSource',
		'aiBuilder'
	],
	#classInstVars : [
		'testResultsDictionary'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'tests' }
AIATestBuilderExperiments class >> example1 [ 
	self showTestResults
]

{ #category : 'tests' }
AIATestBuilderExperiments class >> showTestResults [
	| rows cols values illustration |
	cols := testResultsDictionary keys.
	rows := (testResultsDictionary at: (cols first)) keys.
	values := OrderedCollection new.
	rows do: [ :row | |valRow |
		valRow := OrderedCollection new.
		cols do: [ :col |
			valRow add: ((testResultsDictionary at: col) at: row) value
			 ].
		values add: valRow.
		 ].
	illustration := AIATestResultIllustration new.
	illustration resultsRows: rows collumns: cols values: values.
	illustration open.
]

{ #category : 'tests' }
AIATestBuilderExperiments class >> testClass: aClass [
	"Generate test method 'aClassNameAITest_xy' where x is either 'G'emini or 'M'istral, and y is 1-5"
	| mistral gemini testResults |
	mistral := AIAMistralTestBuilder.
	gemini := AIAGeminiTestBuilder.
	testResultsDictionary := OrderedDictionary new.
	7 to: 9 do: [ :y | 
		AIATestBuilder aITestClassPostfix: 'AITest_m', y asString.
		mistral buildTestClass: aClass.
		testResults:= mistral buildAll: aClass.
		testResultsDictionary at: 'M', y asString put: testResults. 
		
		"AIATestBuilder aITestClassPostfix: 'AITest_g', y asString.
		gemini buildTestClass: aClass.
		testResults := gemini buildAll: aClass.
		testResultsDictionary at: 'G', y asString put: testResults "
		 ].
	self showTestResults 
]
