"
# AIAPlantUML

A utility class for converting PlantUML text to images using the PlantUML command-line tool. This class provides a simple interface to generate UML diagrams from PlantUML code and display them as images in the Pharo environment.

## Usage

The class can be used to convert PlantUML code to images and display them. It supports various UML diagram types through example methods that query an AI model for PlantUML code examples.

### Example in Playground

```st
""AIAPlantUML exampleClassDiagram""
```

This will generate a class diagram example by querying an AI model for PlantUML code, convert it to an image, and display it.

## Key Features

- Converts PlantUML text to PNG images using the `plantuml` command-line tool
- Provides example methods for various UML diagram types
- Handles both raw PlantUML code and code enclosed in markdown code blocks
- Displays the resulting image in a new window

## Design Notes

The class is designed to be simple and focused on the conversion task. It doesn't modify or install any classes in the system. The actual conversion is done by calling the external PlantUML tool and reading the resulting PNG file.

For more complex class building needs, consider using the `ShiftClassInstaller` or other class building utilities in the system.
"
Class {
	#name : 'AIAPlantUML',
	#superclass : 'Object',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'examples' }
AIAPlantUML class >> example1ReadMe [
	AIAPresenter onText: '# ReadMe
The examples are done by the selected AI. 

The selection is taken from https://creately.com/blog/diagrams/uml-diagram-types-examples/.

The various examples are highly dependable on the selected AI, some might make something else than intended, others make errors'
]

{ #category : 'examples' }
AIAPlantUML class >> exampleActivityDiagram [

	| uml type |
	type := '**Activity Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleClassDiagram [
	"Generates a PlantUML class diagram example by querying an AI model."

	| uml type |
	type := '**Class Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleCommunicationDiagram [
	| uml type |
	type := '**Communication Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleComponentDiagram [

	| uml type |
	type := '**Component Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleCompositeStructureDiagram [

	| uml type |
	type := '**Composite Structure Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.
	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleDeploymentDiagram [

	| uml type |
	type := '**Deployment Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleInteractionOverviewDiagram [
	| uml type |
	type := '**Interaction Overview Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleObjectDiagram [

	| uml type |
	type := '**Object Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> examplePackageDiagram [

	| uml type |
	type := '**Package Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> examplePlantUML [

	| uml |
	uml := 'Write a PlantUML code for "Alice say hello to Bob. [RESONSETYPE]Please just return the PlantUML code. No comments' q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleProfileDiagram [
	| uml type |
	type := '**Profile Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleSequenceDiagram [

	| uml type |
	type := '**Sequence Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleStateMachineDiagram [

	| uml type |
	type := '**State Machine Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleTimingDiagram [
	| uml type |
	type := '**Timing Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'examples' }
AIAPlantUML class >> exampleUseCaseDiagram [

	| uml type |
	type := '**Use Case Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'UML' }
AIAPlantUML class >> umlToImage: uml [
	self new umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML >> uml: uml [
	(uml beginsWith: '```') 
		ifTrue:[ ^ String cr join: uml lines allButFirst allButLast] 
		ifFalse: [ ^ uml ].
]

{ #category : 'UML' }
AIAPlantUML >> umlToImage: uml [
	"Converts PlantUML text to an image using the plantuml command line tool."
	| directory pumlFile pngFile  command form |
	directory := FileSystem workingDirectory.
	pumlFile := directory / 'plantUMLtemp.puml'.
	pngFile := directory / 'plantUMLtemp.png'.
	pumlFile writeStreamDo: [ :stream | stream nextPutAll: (self uml: uml) ].
	command := 'plantuml -tpng "{1}" -o "{2}"' 
		format: {pumlFile fullName. directory fullName}.
	LibC system: command.
	form := PNGReadWriter formFromFileNamed: pngFile fullName.
	SpImagePresenter new
		image: form;
		open.
]
