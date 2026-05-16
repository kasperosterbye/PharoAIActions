"
# Class Comment for GrockieWasHere

## Purpose and Role in the System

The `GrockieWasHere` class serves as a placeholder or utility class within the `AIATestExperiments` package. Its primary purpose is to demonstrate or test specific functionalities or behaviours in a controlled environment. It is not intended for production use but rather for experimental purposes.

## Main Collaborators or Dependencies

The `GrockieWasHere` class does not have any significant collaborators or dependencies. It is a standalone class designed to operate independently of other classes in the system.

## Important Invariants or Design Constraints

There are no specific invariants or design constraints associated with the `GrockieWasHere` class. It is a simple class with minimal functionality, designed to be flexible and adaptable for various testing scenarios.

## Illustrative Usage Examples

### Example 1: Creating an Instance and Accessing Variables

```smalltalk
instance := GrockieWasHere new.
instance aaa: 10.
instance yzx: 20.
sum := instance sum. ""Returns the sum of aaa and yzx, which is 30""
```

### Example 2: Using the Class in a Test Scenario

```smalltalk
testInstance := GrockieWasHere new.
testInstance aaa: 5.
testInstance yzx: 15.
self assert: testInstance sum equals: 20.
```

In this example, the `GrockieWasHere` class is used to create an instance, set the values of its instance variables, and then verify the sum of these values in a test scenario.
"
Class {
	#name : 'GrockieWasHere',
	#superclass : 'Object',
	#instVars : [
		'aaa',
		'yzx'
	],
	#category : 'AIATestExperiments-Grockie',
	#package : 'AIATestExperiments',
	#tag : 'Grockie'
}

{ #category : 'as yet unclassified' }
GrockieWasHere >> setAaaTo1001 [
   aaa := 1001
]

{ #category : 'as yet unclassified' }
GrockieWasHere >> sum [
	^aaa   yzx
]
