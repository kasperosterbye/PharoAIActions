"
# AIATestBuilderExperiments

A utility class for generating and comparing AI-generated test cases across different model configurations. This class facilitates the creation of multiple test variants using different AI builders (e.g., Mistral and Gemini) and provides visualisation of test results.

## Key Features

- Generates multiple test variants with different AI model configurations
- Compares test results across different model versions
- Provides visualisation of test outcomes
- Supports both class and instance-side test generation

## Usage Example

```smalltalk
""Example usage in Playground""
| testBuilder testClass |
testClass := Object subclass: #TestExample
    instanceVariableNames: 'value'
    classVariableNames: ''
    package: 'AI-Tests'.

testBuilder := AIATestBuilderExperiments new.
testBuilder testClass: testClass. ""Generates and compares tests across 3 configurations of each AI model""
testBuilder. ""Returns the builder instance for inspection""
```

## Design Notes

- Maintains a dictionary of test results keyed by model configuration
- Uses `AIATestResultIllustration` for visualising comparison results
- Follows the builder pattern for test generation
- Designed for interactive use in development environments

## Implementation Notes

- Results are stored in an ordered dictionary for consistent ordering
- Visualisation is handled by a separate illustration class
- Each test variant is generated with a unique postfix identifier
"
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
	mistral := AIATest01.
	gemini := AIATest03.
	testResultsDictionary := OrderedDictionary new.
	1 to: 3 do: [ :y | 
		AIATestBuilder aITestClassPostfix: 'AITest_m', y asString.
		mistral buildTestClass: aClass.
		testResults:= mistral buildAll: aClass.
		testResultsDictionary at: 'M', y asString put: testResults. 
		
		AIATestBuilder aITestClassPostfix: 'AITest_g', y asString.
		gemini buildTestClass: aClass.
		testResults := gemini buildAll: aClass.
		testResultsDictionary at: 'G', y asString put: testResults 
		 ].
	self showTestResults 
]
