Class {
	#name : 'TraitChangeAITest',
	#superclass : 'TestCase',
	#instVars : [
		'refTraitChange'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'AI generated test' }
TraitChangeAITest >> Data [ receive timed out.
]

{ #category : 'initialization' }
TraitChangeAITest >> setUp [
	super setUp.
	refTraitChange := TraitChange new.
]

{ #category : 'AI generated test' }
TraitChangeAITest >> testAddedSelectors [
	| traitChange aSelector expectedCollection |
	aSelector := #testSelector.
	expectedCollection := {aSelector}.
	traitChange := TraitChange new.
	traitChange addedSelectors: expectedCollection.
	self assert: traitChange addedSelectors equals: expectedCollection
	"Verify that addedSelectors returns the collection set via the setter"

]

{ #category : 'AI generated test' }
TraitChangeAITest >> testInitialize [
	| traitChange |
	
	"Test that initialize sets the selector collections to empty sets"
	traitChange := TraitChange new.
	
	self assert: traitChange updatedSelectors isEmpty.
	self assert: traitChange addedSelectors isEmpty.
	self assert: traitChange removedSelectors isEmpty

]

{ #category : 'AI generated test' }
TraitChangeAITest >> testRemovedSelectors [
	| aSelector |
	aSelector := #testMethod.
	self traitChange removedSelectors: { aSelector }.
	"Verify that the accessor returns the set value"
	self assert: self traitChange removedSelectors equals: { aSelector }.
	"Verify that it is a collection containing the selector"
	self assert: (self traitChange removedSelectors includes: aSelector)

]

{ #category : 'AI generated test' }
TraitChangeAITest >> testUpdateSelectorFromTraitToClass [
	| trait aClass changes selector traitChange |
	selector := #propagateMe.
	
	"Setup a trait with a method"
	trait := Trait named: #TPropagationTrait.
	trait compile: 'propagateMe ^ true'.
	
	"Setup a class that uses the trait but has no local implementation of the selector"
	aClass := Object subclass: #CPropagationUser
		instanceVariableNames: ''
		classVariableNames: ''
		package: 'Traits-Tests'.
	aClass uses: trait asTraitComposition.
	aClass removeSelector: selector ifAbsent: [  ].
	
	"Setup changes object - assuming TraitChange has updatedSelectors as a Set"
	changes := TraitChange new.
	
	"Create the TraitChange instance to test"
	traitChange := TraitChange new.
	
	"Perform the update - should propagate from trait to class"
	traitChange update: selector into: aClass changes: changes.
	
	"Assert the selector is now installed in the class from the trait"
	self assert: (aClass includesSelector: selector).
	self assert: (aClass compiledMethodAt: selector) equals: (trait compiledMethodAt: selector).
	
	"Assert the selector was added to changes"
	self assert: (changes updatedSelectors includes: selector).
	self assert: changes updatedSelectors size equals: 1.
	
	"Cleanup"
	Smalltalk globals removeKey: #TPropagationTrait ifAbsent: [  ].
	Smalltalk globals removeKey: #CPropagationUser ifAbsent: [  ].

]

{ #category : 'AI generated test' }
TraitChangeAITest >> testUpdatedSelectors [
	| traitChange updatedSelectorsValue |
	"Create a new instance of TraitChange"
	traitChange := TraitChange new.
	"Prepare a collection of selectors as the value to set"
	updatedSelectorsValue := { #method1. #method2 }.
	"Set the updatedSelectors instance variable"
	traitChange updatedSelectors: updatedSelectorsValue.
	"Verify that the getter returns the set value"
	self assert: traitChange updatedSelectors equals: updatedSelectorsValue

]
