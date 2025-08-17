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
	grid alignTop.
	grid alignLeft.
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
	(self checkSafety: {
			 rows.
			 cols.
			 values }) ifFalse: [ ^ Error signal ].

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
