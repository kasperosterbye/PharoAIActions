Class {
	#name : 'AIAPlantUML',
	#superclass : 'Object',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

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
