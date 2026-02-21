"
# AIATestClassBuilder

A utility class for dynamically generating test classes for existing classes within the AIAExperiments package. This builder facilitates the creation of test classes with appropriate instance variables and setup methods, adhering to Pharo's testing conventions.

## Key Features

- **Dynamic Test Class Generation**: Automatically constructs test classes for given source classes, handling both regular and meta-classes.
- **Instance Variable Management**: Creates meaningful instance variable names for test class references.
- **Setup Method Generation**: Compiles a `setUp` method to initialise the test subject.
- **Fluid Interface**: Uses a builder pattern for flexible class configuration.

## Usage Example

```st
""Example: Create a test class for an existing class""
| testClass |
testClass := AIATestClassBuilder ensureTestClass: Point.
testClass inspect  ""Inspect the newly created test class""
```

## Design Considerations

- **Non-Invasive**: The builder does not modify existing classes or install the test class by default.
- **ShiftClassBuilder Integration**: Utilises `ShiftClassBuilder` for class construction, ensuring compatibility with Pharo's class management system.
- **Package Organisation**: Places generated test classes in the `AIATestExperiments` package.

## Future Enhancements

- **API Refinement**: Align with Pharo's class default values and reduce conversion overhead.
- **Builder Enhancement**: Support for custom builder enhancers to extend functionality.
"
Class {
	#name : 'AIATestClassBuilder',
	#superclass : 'Object',
	#category : 'AIAExperiments-TestBuiler',
	#package : 'AIAExperiments',
	#tag : 'TestBuiler'
}

{ #category : 'local methods' }
AIATestClassBuilder class >> buildShifter: sourceClass for: instanceVarName [
	"Builds a ShiftClassBuilder for creating a test class with specified superclass, name, and instance variables"
	| shifter |
	shifter := ShiftClassBuilder new.
	shifter
		superclassName: TestCase name;
		name: (self newTestClassName: sourceClass) asSymbol;
		slots: { instanceVarName asSymbol };
		package: 'AIATestExperiments'.
	^ shifter
]

{ #category : 'local methods' }
AIATestClassBuilder class >> buildTestClass: sourceClass [
	"Builds a test class for a given source class, creating a new test class with appropriate instance variables and setup methods"

	|  testClass  shifter instanceVarName |
	"The name of the instance variable to hold the reference to the test class."
	instanceVarName := self instanceVarNameFor: sourceClass . 
	"Check if a super test class exists (e.g., AIDijkstraTest)."
	shifter := self buildShifter: sourceClass for: instanceVarName.
	
	testClass := shifter install. 
	"Compile an initialize method to set up the instance variable."
	testClass
		compile:
		'setUp' , String cr , '	super setUp.' , String cr , '	' , instanceVarName , ' := ' , sourceClass name asString , ' new.'
		classified: 'initialization'.

	^ testClass
]

{ #category : 'builder' }
AIATestClassBuilder class >> ensureTestClass: sourceClass [ 
	"Ensures a test class exists for the given source class, creating it if necessary"

    |  testClass   |
    testClass := Smalltalk globals 
			at: (self newTestClassName: sourceClass ) asSymbol 
			ifAbsent: [ nil ].
    
    testClass ifNil: [ 
			testClass := self buildTestClass: sourceClass ].
    
    ^ testClass
]

{ #category : 'local methods' }
AIATestClassBuilder class >> instanceVarNameFor: sourceClass [
	"Returns the instance variable name for a test class, handling meta classes appropriately"
	| instanceVarName |
	instanceVarName := 'ref' , sourceClass name asString.
	sourceClass isMeta ifTrue: [ instanceVarName := instanceVarName allButLast: 6 " class" ]. 
	^ instanceVarName 
]

{ #category : 'local methods' }
AIATestClassBuilder class >> newTestClassName: sourceClass [
	"Returns the name of the test class for a given source class, appending 'AITest' to the class name or 'ClassAITest' for metaclasses"
	^ sourceClass isMeta 
		ifFalse: [sourceClass name asString, self testClassPostfix .]
 		ifTrue: [ sourceClass soleInstance name asString, 'Class', self testClassPostfix ].

 
]

{ #category : 'local methods' }
AIATestClassBuilder class >> testClassPostfix [
	"Returns the postfix string used for test class names"
	^ 'AITest'
]
