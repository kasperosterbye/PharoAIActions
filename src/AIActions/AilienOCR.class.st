"
# AilienOCR

AilienOCR is a client for the Ailien OCR API, designed to extract text from PDF documents using advanced optical character recognition (OCR) capabilities. This class provides a simple interface to upload PDF files, process them through the Ailien API, and retrieve the extracted text in Markdown format.

## Usage Example

```smalltalk
""AilienOCR usage example in the Playground""

| fileReference text |
fileReference := 'path/to/your/document.pdf' asFileReference.
text := AilienOCR new textFromPDF: fileReference.
text inspect
```

## Key Features

- **PDF Upload**: Uploads PDF files to the Ailien OCR API for processing.
- **OCR Processing**: Extracts text from PDF documents using the Ailien API.
- **Markdown Output**: Returns the extracted text in Markdown format for easy formatting and display.

## Design Notes

- The class follows a fluent interface for easy integration with other tools.
- All API interactions are handled internally, requiring only the file reference for operation.
- Designed to be used interactively in the Playground for quick text extraction tasks.

"
Class {
	#name : 'AilienOCR',
	#superclass : 'Object',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
AilienOCR >> getSignedUrl: fileId [
	"Retrieves a signed URL for the specified file ID with a 1-hour expiry"
    | response parsed |
    response := ZnClient new
        url: 'https://api.mistral.ai/v1/files/', fileId, '/url?expiry=1';
        headerAt: 'Authorization' put: MistralApi esug;
        get;
        contents.
    parsed := STONJSON fromString: response.
    ^ parsed at: 'url'
]

{ #category : 'as yet unclassified' }
AilienOCR >> ocrFile: fileId [
	"Extracts text from a PDF file using the AilienOCR API, processing the file identified by fileId."
    | signedUrl response parsed |
    signedUrl := self getSignedUrl: fileId.
    response := ZnClient new
        url: 'https://api.mistral.ai/v1/ocr';
        headerAt: 'Authorization' put: MistralApi esug;
        entity: (ZnEntity json: (STONJSON toString: (Dictionary newFrom: {
            'model' -> 'mistral-ocr-latest'.
            'document' -> (Dictionary newFrom: {
                'type' -> 'document_url'.
                'document_url' -> signedUrl }) })));
        post;
        contents.
    parsed := STONJSON fromString: response.
    ^ ((parsed at: 'pages') collect: [ :page | page at: 'markdown' ])
        joinUsing: String cr
]

{ #category : 'as yet unclassified' }
AilienOCR >> textFromPDF: aFileReference [
	"Extracts text from a PDF file using the AilienOCR API."
    | fileId |
    fileId := self uploadFile: aFileReference.
    ^ self ocrFile: fileId
]

{ #category : 'as yet unclassified' }
AilienOCR >> uploadFile: aFileReference [
	"Uploads a PDF file to the AilienOCR API for OCR processing"
    | entity part response parsed |
    part := ZnMimePart 
        fieldName: 'file' 
        fileName: aFileReference basename 
        entity: (ZnEntity 
		    with: aFileReference binaryReadStream contents
    		type: (ZnMimeType fromString: 'application/pdf')).
    entity := ZnMultiPartFormDataEntity new.
    entity 
        addPart: part;
        addPart: (ZnMimePart fieldName: 'purpose' value: 'ocr').
    response := ZnClient new
        url: 'https://api.mistral.ai/v1/files';
        headerAt: 'Authorization' put: MistralApi esug;
        entity: entity;
        post;
        contents.
    parsed := STONJSON fromString: response.
    ^ parsed at: 'id'
]
