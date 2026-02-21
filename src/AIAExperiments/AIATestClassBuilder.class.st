Class {
	#name : 'AIATestClassBuilder',
	#superclass : 'Object',
	#classVars : [
		'AITestClassPostfixXX',
		'AITestClassXX'
	],
	#category : 'AIAExperiments-TestBuiler',
	#package : 'AIAExperiments',
	#tag : 'TestBuiler'
}

{ #category : 'builder' }
AIATestClassBuilder >> buildTestClass: infoArray [
	"Creates or retrieves a test class for a given method, compiling setup code and handling instance variables. Returns the test class."

	| sourceClass testClass newTestClassName shifter instanceVarName |
	sourceClass := infoArray first.
	newTestClassName := infoArray second.
	testClass := infoArray third. 
	"The name of the instance variable to hold the reference to the test class."
	instanceVarName := 'ref' , sourceClass name asString.
	sourceClass isMeta ifTrue: [ instanceVarName := instanceVarName allButLast: 6 " class" ]. 
	"Check if a super test class exists (e.g., AIDijkstraTest)."
	shifter := ShiftClassBuilder new.
	shifter
		superclassName: TestCase name;
		name: newTestClassName asSymbol;
		slots: { instanceVarName asSymbol };
		package: 'AIATestExperiments'.

	testClass := shifter install. 
	"Compile an initialize method to set up the instance variable."
	testClass
		compile:
		'setUp' , String cr , '	super setUp.' , String cr , '	' , instanceVarName , ' := ' , sourceClass name asString , ' new.'
		classified: 'initialization'.

	^ testClass
]

{ #category : 'builder' }
AIATestClassBuilder >> ensureTestClass: sourceClass [ 
	"Creates or retrieves a test class for a given method, compiling setup code and handling instance variables. Returns the test class."

    | newTestClassName testClass   |
    "Identify the name of the new test class based on the method's class."
	 newTestClassName := sourceClass isMeta 
		ifFalse: [sourceClass name asString, self testClassPostfix .]
 		ifTrue: [ sourceClass soleInstance name asString, 'Class', self testClassPostfix ].
    
    
    "Try to find an existing test class."
    testClass := Smalltalk globals at: newTestClassName asSymbol ifAbsent: [ nil ].
    
    "If the test class does not exist, create a new one."
    testClass ifNil: [ testClass := self buildTestClass: {sourceClass. newTestClassName . testClass } ].
    
    ^ testClass
]

{ #category : 'tests' }
AIATestClassBuilder >> testClassPostfix [
	^ 'AITest'
]
