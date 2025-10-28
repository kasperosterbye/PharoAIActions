Class {
	#name : 'TraitChangeAITest_Gem',
	#superclass : 'TestCase',
	#instVars : [
		'refTraitChange'
	],
	#category : 'AIATestExperiments',
	#package : 'AIATestExperiments'
}

{ #category : 'initialization' }
TraitChangeAITest_Gem >> setUp [
	super setUp.
	refTraitChange := TraitChange new.
]

{ #category : 'AI generated test' }
TraitChangeAITest_Gem >> testAddSelectorIntoClassChanges [
	| aClass aSelector changes originalMethod |
	"Set up: Create a class, a selector, and a changes object."
	aClass := self newClass.
	aSelector := #aMethod.
	changes := self newChanges.
	originalMethod := aClass compile: 'aMethod ^ 1'.

	"Exercise: Add the selector to the class using the method under test."
	self add: aSelector into: aClass changes: changes.

	"Verify: Check if the method is in the local method dictionary and if the changes were updated."
	self assert: (aClass localMethodDict includesKey: aSelector).
	self assert: (changes updatedSelectors includes: aSelector).
	self assert: (aClass methodDict at: aSelector) == originalMethod.
	"Clean up: Remove the added method."
	aClass removeSelector: aSelector.

]

{ #category : 'AI generated test' }
TraitChangeAITest_Gem >> testAddedSelectors [
	| change |
	"Set up: Create a TraitChange instance."
	change := TraitChange new.
	
	"Test: addedSelectors should return the addedSelectors instance variable."
	self assert: change addedSelectors equals: nil.
	
	"Test: Ensure that the instance variable is initialized correctly."
	change addedSelectors: #('aSelector').
	self assert: change addedSelectors equals: #('aSelector').

]

{ #category : 'AI generated test' }
TraitChangeAITest_Gem >> testApplyOn [
	| aClass aTraitChange aSelector |
	"Set up: Create a class and a TraitChange instance."
	aClass := self newClass.
	aTraitChange := TraitChange new.
	aSelector := #aMethod.

	"Test: Apply the changes to the class."
	aTraitChange
		addSelector: aSelector
		on: aClass.
	aTraitChange applyOn: aClass.

	"Verify: Check if the selector was added to the class."
	self assert: (aClass includesSelector: aSelector).
	"Verify: Check that the trait users are also updated (this part is hard to test without mocks, so we'll check the basic setup)."
	self assert: aClass traitUsers isEmpty. "Assuming no trait users initially"

]

{ #category : 'AI generated test' }
TraitChangeAITest_Gem >> testInitialize [
	| aTraitChange |
	"Set up: Create an instance of TraitChange"
	aTraitChange := self class new.

	"Execute: Call initialize"
	aTraitChange initialize.

	"Verify: Check that the instance variables are initialized correctly"
	self assert: aTraitChange updatedSelectors notNil.
	self assert: aTraitChange updatedSelectors isEmpty.
	self assert: aTraitChange addedSelectors notNil.
	self assert: aTraitChange addedSelectors isEmpty.
	self assert: aTraitChange removedSelectors notNil.
	self assert: aTraitChange removedSelectors isEmpty.

]

{ #category : 'AI generated test' }
TraitChangeAITest_Gem >> testRemoveIntoChangesLocalMethod [
	| aClass aSelector results initialSelectors |
	"Setup: Create a class, a selector, and a TraitChangeResults instance."
	aClass := self newClass.
	aSelector := #aMethod.
	results := TraitChangeResults new.
	initialSelectors := aClass localSelectors copy.

	"Add a method locally to simulate the scenario."
	aClass compile: 'aMethod ^ 1'.

	"Exercise: Call the method under test."
	self remove: aSelector into: aClass changes: results.

	"Verify: Check that the method is not removed and results are not changed."
	self assert: aClass localSelectors equals: initialSelectors.
	self assert: results addedSelectors isEmpty.
	self assert: results removedSelectors isEmpty.
	self assert: results updatedSelectors isEmpty.
	self assert: aClass includesSelector: aSelector.

	"Cleanup: Remove the class"
	self removeClass: aClass.

]

{ #category : 'AI generated test' }
TraitChangeAITest_Gem >> testRemovedSelectors [
	| change |
	"Set up: Create a TraitChange instance."
	change := TraitChange new.

	"Test: Verify that removedSelectors returns the receiver (self) when no removed selectors are set."
	self assert: change removedSelectors = change.

]

{ #category : 'AI generated test' }
TraitChangeAITest_Gem >> testUpdateSelectorIntoClassChanges [
	| aClass aSelector changes traitComposition originalMethod |
	"Set up the test environment"
	aSelector := #aMethod.
	aClass := self newClassWithTrait.
	changes := OrderedCollection new.
	traitComposition := aClass traitComposition.
	originalMethod := aClass compiledMethodAt: aSelector ifAbsent: [ nil ]. "Store the original method if it exists"

	"Ensure the selector is not initially in the class"
	aClass removeSelector: aSelector.

	"Simulate a change (e.g., from another trait)"
	traitComposition installSelector: aSelector into: aClass.

	"Call the method under test"
	self update: aSelector into: aClass changes: changes.

	"Verify the results"
	self assert: (aClass includesSelector: aSelector).
	self assert: (changes includes: aSelector).

	"Clean up: Restore the original state"
	aClass removeSelector: aSelector.
	originalMethod ifNotNil: [ aClass addSelector: aSelector withMethod: originalMethod ].
	"If the method was aliased, it should be updated also"
	(aClass traitComposition reverseAlias: aSelector)
		do: [ :aliased |
			aClass traitComposition installSelector: aliased into: aClass.
			changes updatedSelectors add: aliased ]

]

{ #category : 'AI generated test' }
TraitChangeAITest_Gem >> testUpdatedSelectors [
	| aTraitChange aSelector |
	"Set up: Create an instance of TraitChange and a selector."
	aTraitChange := TraitChange new.
	aSelector := #aMethod.

	"Execute: Call updatedSelectors: with a selector."
	aTraitChange updatedSelectors: {aSelector}.

	"Verify: Check if the updatedSelectors instance variable is correctly set."
	self assert: aTraitChange updatedSelectors first = aSelector.
	self assert: aTraitChange updatedSelectors size = 1.

]
