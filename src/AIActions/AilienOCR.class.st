"
# AilienOCR

`AilienOCR` is a synchronous adapter for Mistral’s file and OCR endpoints. It uploads PDF files, obtains short-lived signed URLs, submits documents for OCR, and returns the recognised page content as plain text. It also exposes Mistral’s voice listing and speech-generation endpoints; those capabilities share the same API access but are not part of the OCR workflow.

## Design and contract

- API requests use `MistralApi esug` for the `Authorization` header. Credentials and endpoint URLs are not injected, so adapting authentication or the service requires changing or specialising the relevant methods.
- `uploadFile:` uploads the supplied file as `application/pdf` with purpose `ocr` and returns the response’s file ID. The caller is responsible for supplying an appropriate file.
- `getSignedUrl:` requests a URL with a one-hour expiry. `ocrFile:` uses that URL and returns the `markdown` values from the response’s `pages`, joined with carriage returns. This deliberately gives callers text rather than page objects: page metadata and the original response structure are discarded.
- `textFromPDF:` composes upload and OCR. The lower-level methods remain available when callers need to separate those steps or work with an existing file ID.

## Local-file behaviour

The class-side `pdf:` and `webpdf:` conveniences use `/Users/kasper/downloads`. `pdf:in:` allows a different folder for the PDF and resulting text file. `webpdf:` derives local names from the URL’s final path segment, returns an existing `.txt` file without checking whether it is current, and downloads the PDF only when it is absent.

Consequently, the text cache is keyed by filename rather than URL or document contents: same-named PDFs can collide, and cached text is not refreshed automatically. The download directory is also platform- and user-specific. These are convenience choices, not properties of the OCR service.

## Extension and trade-offs

The request stages (`uploadFile:`, `getSignedUrl:`, and `ocrFile:`) are natural seams for specialisation, as are `pdf:in:` and the voice-related methods. However, models, endpoints, expiry, output paths and several response keys are hard-coded. Requests are made directly through `ZnClient`, and responses are assumed to have the expected JSON shape; the class does not provide its own retry, caching invalidation, or structured error policy.

`speakText:` has additional local side effects: it writes an MP3 to the fixed downloads directory and invokes `afplay`. It therefore depends on that path and an available macOS playback command, rather than behaving as a platform-neutral API operation.
"
Class {
	#name : 'AilienOCR',
	#superclass : 'Object',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'pdf' }
AilienOCR class >> pdf: aFileName [
    | folder fileReference text outputReference |
    folder := '/Users/kasper/downloads' asFileReference.
    fileReference := folder / aFileName.
    text := self new textFromPDF: fileReference.
    outputReference := folder / (aFileName copyReplaceAll: '.pdf' with: '.txt').
    outputReference writeStreamDo: [ :stream |
        stream nextPutAll: text ].
    ^ text
]

{ #category : 'pdf' }
AilienOCR class >> pdf: aFileName in: folderFile [
    | folder fileReference text outputReference |
	 folder := folderFile asFileReference.
    fileReference := folder / aFileName.
    text := self new textFromPDF: fileReference.
    outputReference := folder / (aFileName copyReplaceAll: '.pdf' with: '.txt').
    outputReference writeStreamDo: [ :stream |
        stream nextPutAll: text ].
    ^ text
]

{ #category : 'as yet unclassified' }
AilienOCR class >> webpdf: webAddress [
	"Return the saved OCR text or extract it from a local or downloaded PDF."
	| url segments fileName folder pdfReference textReference |
	url := webAddress asZnUrl.
	segments := url pathSegments.
	segments isEmpty ifTrue: [ self error: 'The URL must include a PDF filename' ].
	fileName := segments last.
	((fileName endsWith: '.pdf') and: [ (fileName includes: $/) not ])
		ifFalse: [ self error: 'The URL must include a PDF filename ending in .pdf' ].

	folder := '/Users/kasper/downloads' asFileReference.
	textReference := folder / (fileName copyReplaceAll: '.pdf' with: '.txt').
	textReference isFile ifTrue: [ ^ textReference contents ].

	pdfReference := folder / fileName.
	pdfReference isFile ifFalse: [
		ZnClient new
			url: url;
			enforceHttpSuccess: true;
			downloadTo: pdfReference ].

	^ self pdf: fileName
]

{ #category : 'OCR' }
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

{ #category : 'OCR' }
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

{ #category : 'OCR' }
AilienOCR >> speakText: aString [
    | response parsed audioData tempFile |
    response := ZnClient new
        url: 'https://api.mistral.ai/v1/audio/speech';
        headerAt: 'Authorization' put: MistralApi esug;
        entity: (ZnEntity json: (STONJSON toString: (Dictionary newFrom: {
            'model' -> 'voxtral-mini-tts-2603'. 
            'input' -> aString.
            'voice_id' -> 'gb_jane_sarcasm'.
            'response_format' -> 'mp3' })));
        post;
        contents.
    parsed := STONJSON fromString: response.
    audioData := ZnBase64Encoder new decode: (parsed at: 'audio_data').
    tempFile := '/Users/kasper/downloads' asFileReference / 'ailient-speech.mp3'.
    tempFile binaryWriteStreamDo: [ :s | s nextPutAll: audioData asByteArray ].
    LibC system: 'afplay -r 1.7 ', tempFile fullName
]

{ #category : 'OCR' }
AilienOCR >> textFromPDF: aFileReference [
	"Extracts text from a PDF file using the AilienOCR API."
    | fileId |
    fileId := self uploadFile: aFileReference.
    ^ self ocrFile: fileId
]

{ #category : 'OCR' }
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

{ #category : 'OCR' }
AilienOCR >> voices [
    | response |
    response := ZnClient new
        url: 'https://api.mistral.ai/v1/audio/voices';
        headerAt: 'Authorization' put: MistralApi esug;
        get;
        contents.
    ^ (STONJSON fromString: response) at: 'items'
]
