Class {
	#name : 'AIAPlantUML',
	#superclass : 'Object',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleActivityDiagram [

	| uml type |
	type := '**Activity Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleClassDiagram [
	"Generates a PlantUML class diagram example by querying an AI model."

	| uml type |
	type := '**Class Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleCommunicationDiagram [
	| uml type |
	type := '**Communication Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleComponentDiagram [

	| uml type |
	type := '**Component Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleCompositeStructureDiagram [

	| uml type |
	type := '**Composite Structure Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleDeploymentDiagram [

	| uml type |
	type := '**Deployment Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleInteractionOverviewDiagram [
	| uml type |
	type := '**Interaction Overview Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleObjectDiagram [

	| uml type |
	type := '**Object Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> examplePackageDiagram [

	| uml type |
	type := '**Package Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> examplePlantUML [

	| uml |
	uml := 'Write a PlantUML code for "Alice say hello to Bob. [RESONSETYPE]Please just return the PlantUML code. No comments' q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleProfileDiagram [
	| uml type |
	type := '**Profile Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleSequenceDiagram [

	| uml type |
	type := '**Sequence Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleStateMachineDiagram [

	| uml type |
	type := '**State Machine Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
AIAPlantUML class >> exampleTimingDiagram [
	| uml type |
	type := '**Timing Diagram**'.
	uml := ('Can you give an example of a {1} in PlantUML. [RESONSETYPE]Please just return the PlantUML code. No comments' format: { type }) q0.

	AIAPlantUML umlToImage: uml
]

{ #category : 'as yet unclassified' }
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
	"Converts PlantUML text to an image using Kroki.io and displays it in a presenter."

	| url umlClean response |
	url := 'https://kroki.io/plantuml/png'.
	umlClean := self uml: uml.
	response := ZnClient new
		            url: 'https://kroki.io/plantuml/png';
		            entity: (ZnEntity text: umlClean);
		            contentType: 'text/plain';
		            accept: 'image/png';
		            post;
		            contents.
	SpImagePresenter new
		image: (PNGReadWriter formFromStream: response readStream);
		open
]
