"
# Class Comment for AIAPlantUML

A utility class for generating and visualising PlantUML diagrams. This class provides methods to convert PlantUML text into images and display them using the `plantuml` command-line tool. It supports various UML diagram types and can be used to generate examples programmatically.

## Usage Example

```smalltalk
""A simple example demonstrating how to generate a PlantUML diagram and display it.""
| uml |
uml := '@startuml
Alice -> Bob : Hello!
Bob --> Alice : Hi!
@enduml'.
AIAPlantUML umlToImage: uml
```

## Key Features

- **Diagram Generation**: Converts PlantUML text to PNG images.
- **AI Integration**: Can generate UML examples using AI prompts.
- **Visualisation**: Displays generated diagrams in a `SpImagePresenter`.

## Design Decisions

- **Command-Line Dependency**: Relies on the `plantuml` tool being installed and available in the system path.
- **Temporary Files**: Uses temporary files for intermediate storage during diagram generation.
- **AI Prompting**: Supports dynamic generation of UML examples via AI queries.

## Example Methods

- `umlToImage:`: Converts PlantUML text to an image and displays it.
- `uml:`: Processes PlantUML text, handling markdown formatting if present.
- `example*`: Methods for generating specific UML diagram examples (e.g., `exampleClassDiagram`, `exampleSequenceDiagram`).

This class is particularly useful for developers working with PlantUML and requiring programmatic generation and visualisation of UML diagrams.
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
