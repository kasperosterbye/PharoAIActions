"
# Class Comment for AIAkroki

`AIAkroki` is a utility class for converting PlantUML text to images using the Kroki.io service. It provides a simple interface to generate and display UML diagrams directly from textual descriptions.

## Usage Example

```st
""AIAkroki umlToImage: 'class Example { + method() }'""
```

This will generate and display a PNG image of the specified UML diagram.

## Design Decisions

- **Service Integration**: Utilises the Kroki.io API for reliable diagram rendering.
- **Presenter Integration**: Displays the generated image using `SpImagePresenter`.
- **Error Handling**: Implicitly handles network requests and image conversion.

## Dependencies

- `ZnClient` for HTTP requests.
- `PNGReadWriter` for image processing.
- `SpImagePresenter` for visualisation.

## Future Considerations

- Support for additional diagram types beyond PlantUML.
- Caching mechanisms for frequently used diagrams.
- Enhanced error handling and user feedback.
"
Class {
	#name : 'AIAkroki',
	#superclass : 'Object',
	#category : 'AIActions-CommentBuilder',
	#package : 'AIActions',
	#tag : 'CommentBuilder'
}

{ #category : 'UML' }
AIAkroki class >> umlToImage: uml [
	self new umlToImage: uml
]

{ #category : 'UML' }
AIAkroki >> fibbe [
	^ '<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
  <circle cx="100" cy="100" r="80" stroke="black" stroke-width="4" fill="yellow"/>
  <text x="60" y="110" font-size="30" fill="blue">Pharo</text>
</svg>'
]

{ #category : 'UML' }
AIAkroki >> foo [

	| svgString canvas path |
	svgString := '<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
  <circle cx="100" cy="100" r="80" stroke="black" stroke-width="4" fill="yellow"/>
  <text x="60" y="110" font-size="30" fill="blue">Pharo</text>
</svg>'.
	canvas := RSCanvas new.
	path := RSSVGPath new
		        svgPath: svgString;
		        scaleBy: 1.5;
		        "Valgfri skalering"yourself.
	canvas add: path.
	canvas zoomToFit.
	canvas open
]

{ #category : 'UML' }
AIAkroki >> old_umlToImage: uml [
	"Converts PlantUML text to an image using Kroki.io and displays it in a presenter."

	| url umlClean response |
	url := 'https://kroki.io/plantuml/png'.
	umlClean := self uml: uml.
	1 to: 3 do: [ :foo |
			response := ZnClient new
				            url: 'https://kroki.io/plantuml/png';
				            entity: (ZnEntity text: umlClean);
				            contentType: 'text/plain';
				            accept: 'image/png';
				            post;
				            contents.
			((response first: 5) = 'Error') ifFalse: [
					SpImagePresenter new
						image: (PNGReadWriter formFromStream: response readStream);
						open.
					^ response ] ].
	self error
]

{ #category : 'as yet unclassified' }
AIAkroki >> uml: uml [
	(uml beginsWith: '```') 
		ifTrue:[ ^ String cr join: uml lines allButFirst allButLast] 
		ifFalse: [ ^ uml ].
]

{ #category : 'UML' }
AIAkroki >> umlToImage: uml [
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

{ #category : 'UML' }
AIAkroki >> umlToSVG: uml [

	| url umlClean response |
	url := 'https://kroki.io/plantuml/svg'.
	umlClean := self uml: uml.
	response := ZnClient new
		            url: url;
		            entity: (ZnEntity text: umlClean);
		            contentType: 'text/plain';
		            accept: 'image/svg+xml';
		            post;
		            contents.
	^ response 
]
