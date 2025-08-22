"
# Class Comment for AIATestResultIllustration

The `AIATestResultIllustration` class is designed to visualise test results in a grid layout, with coloured text shapes to indicate pass/fail outcomes. It utilises the Roassal2 framework to create an interactive canvas displaying test results in a structured manner.

## Key Features

- **Grid Layout**: Organises test results in a tabular format for easy interpretation.
- **Colour Coding**: Even numbers are displayed in green (pass), while odd numbers are shown in red (fail).
- **Dynamic Rendering**: Automatically adjusts the canvas size based on the number of test results.
- **Interactive Visualisation**: Allows users to inspect individual test outcomes within the visualised grid.

## Usage Example

```st
""Create and display a test result illustration in the Playground""
| illustration rows columns values |

""Define test data""
rows := #('Test 1' 'Test 2' 'Test 3' 'Test 4').
columns := #('Result' 'Time (ms)' 'Status').
values := {
    { 1. 100. 'Pass' }.
    { 2. 150. 'Fail' }.
    { 3. 200. 'Pass' }.
    { 4. 250. 'Fail' }
}.

""Create and configure the illustration""
illustration := AIATestResultIllustration new.
illustration resultsRows: rows collumns: columns values: values.

""Open the visualisation and inspect the illustration""
illustration open.
illustration
```

## Design Decisions

- **Roassal2 Integration**: Leverages Roassal2 for flexible and interactive visualisations.
- **Colour Scheme**: Uses green for passing tests and red for failing tests to provide immediate visual feedback.
- **Dynamic Layout**: Automatically adjusts the grid layout based on the number of test results.
- **Inspection Support**: Designed to work well with Pharo's inspection mechanism, allowing users to easily inspect the visualisation object.

This class is particularly useful for developers and testers who need to quickly assess the outcomes of multiple test cases in a visual format.
```
"
Class {
	#name : 'AIATestResultIllustration',
	#superclass : 'Object',
	#instVars : [
		'results',
		'canvas',
		'grid'
	],
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'as yet unclassified' }
AIATestResultIllustration >> checkSafety: input [
	"should be checked later. input is on the form {rows. collumns. values}"
	^true
]

{ #category : 'initialization' }
AIATestResultIllustration >> initialize [
	"Initialize a new AIATestResultIllustration with a canvas and grid layout for visualizing test results."
	super initialize.
	canvas := RSCanvas new.
	grid := RSGridLayout new.
]

{ #category : 'as yet unclassified' }
AIATestResultIllustration >> open [
	"Opens a canvas displaying test results in a grid layout with colored text shapes for even and odd numbers."
	| allShapes numberOfColumns |
	
	"Saml alle elementer fra alle rækker i én samling"
	numberOfColumns := results first size.
	allShapes := results flatCollect: [:row | row].

	grid lineItemsCount: numberOfColumns.
	grid on: allShapes.
	canvas addAll: allShapes.
	allShapes do: [:shape |
		shape translateBy: (canvas extent / -2) + (shape extent / 2) + (5@5)].



	canvas open.
]

{ #category : 'accessing' }
AIATestResultIllustration >> resultsRows: rows collumns: cols values: values [
	"Returns a 2D array of test results with name-value pairs. Even numbers are green, odd numbers are red. Used for visualizing test outcomes in a grid layout."

	| rowShape |
	(self checkSafety: { rows. cols. values }) ifFalse: [ ^ Error signal ].

	rowShape := OrderedCollection new.
	rowShape add:
		{ (self textShapeFor: ' ') } , (self textShapeForArray: cols).
	1 to: values size do: [ :index |
			rowShape add: { (self textShapeFor: (rows at: index)) }
				, (self textShapeForArray: (values at: index)) ].
	results := rowShape.
	^ rowShape
]

{ #category : 'as yet unclassified' }
AIATestResultIllustration >> textShapeFor: value [
	"Creates a styled text shape for a given value coloring it green if even and red if odd with a font size of 20."

	| textShape |
	textShape := RSLabel new.
	textShape text: value asString.
	value isNumber ifTrue: [
			value even
				ifTrue: [ textShape color: Color green ]
				ifFalse: [ textShape color: Color red ] ].
	textShape fontSize: 20.
	^ textShape
]

{ #category : 'as yet unclassified' }
AIATestResultIllustration >> textShapeForArray: valueArray [

	| textShapes |
	textShapes := OrderedCollection new.
	1 to: valueArray size do: [ :index |
			textShapes add: (self textShapeFor: (valueArray at: index)) ].
	^ textShapes
]
