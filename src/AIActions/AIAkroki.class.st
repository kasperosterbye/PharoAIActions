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
AIAkroki >> uml: uml [
	^ String cr join: uml lines allButFirst allButLast   .
]

{ #category : 'UML' }
AIAkroki >> umlToImage: uml [
	"Converts PlantUML text to an image using Kroki.io and displays it in a presenter."
	
	|  url umlClean response  |
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
