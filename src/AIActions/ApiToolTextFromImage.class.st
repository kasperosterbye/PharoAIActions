"
{
  ""name"": ""extractTextFromImage"",
  ""description"": ""Performs OCR on an image URL (PNG, JPG, etc.) and returns the extracted plain text. Optimized for screenshots of code, error messages, Pharo inspectors, GitHub issues, or Smalltalk output. Handles syntax like <<, slots:, #symbols, and stack traces well. If the image is blurry or has syntax highlighting, it still tries to reconstruct clean text."",
  ""parameters"": {
    ""properties"": {
      ""url"": {
        ""type"": ""string"",
        ""description"": ""The direct URL to the image (must be publicly accessible, e.g. GitHub user-images.githubusercontent.com or raw.githubusercontent.com)""
      },
      ""instructions"": {
        ""type"": ""string"",
        ""description"": ""Optional hint for the OCR engine. Example: 'Extract only the Pharo code and any error messages, ignore UI elements'. Default is to extract everything as cleanly as possible."",
        ""default"": ""Extract all visible text, preserve code formatting, symbols, and line breaks as accurately as possible.""
      }
    },
    ""required"": [""url""]
  }
}
"
Class {
	#name : 'ApiToolTextFromImage',
	#superclass : 'AilienApiTool',
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'as yet unclassified' }
ApiToolTextFromImage >> evaluateTool [
	| desc desc1 |
	desc := 'Performs OCR on an image URL (PNG, JPG, etc.) and returns the extracted plain text. Optimized for screenshots of code, error messages, Pharo inspectors, GitHub issues, or Smalltalk output. Handles syntax like <<, slots:, #symbols, and stack traces well. If the image is blurry or has syntax highlighting, it still tries to reconstruct clean text.'.
	desc1 := 'The direct URL to the image (must be publicly accessible, e.g. GitHub user-images.githubusercontent.com or raw.githubusercontent.com)'.

    ^ self evaluateTool: { desc. desc1 }
]

{ #category : 'initialization' }
ApiToolTextFromImage >> executeTool: args [

	| url response |
	super executeTool: args.
	url := args at: required.
	response := self imageFromUrl: url.
	^ response 
	
]

{ #category : 'as yet unclassified' }
ApiToolTextFromImage >> getImageFromUrl: url [
	
	| image llmTempFile type responseText|
	image := ZnClient new get: url.
	type := (url splitOn: $.) last.
	llmTempFile := 'llmTempFile'.
	(llmTempFile , '.', type) asFileReference binaryWriteStreamDo: [ :stream | stream nextPutAll: image ].
	LibC system: ('tesseract {1}.{2} {1}' format: {llmTempFile . type}).
	responseText := (llmTempFile , '.txt') asFileReference contents.
	^ responseText 

]

{ #category : 'as yet unclassified' }
ApiToolTextFromImage >> imageFromUrl: url [
	
	| image llmTempFile type responseText|
	image := ZnClient new get: url.
	type := (url splitOn: $.) last.
	llmTempFile := 'llmTempFile'.
	(llmTempFile , '.', type) asFileReference binaryWriteStreamDo: [ :stream | stream nextPutAll: image ].
	LibC system: ('tesseract {1}.{2} {1}' format: {llmTempFile . type}).
	responseText := (llmTempFile , '.txt') asFileReference contents.
	^ responseText 

]

{ #category : 'initialization' }
ApiToolTextFromImage >> initialize [
	name := 'extractTextFromImage'.
	required := 'url'
]

{ #category : 'as yet unclassified' }
ApiToolTextFromImage >> old_build20ExternalPdfText [
	"Fetches external PDF text, converts it to a readable format, and stores it for comparison purposes"
	| myPdf directory pdfFile textFile  command  externalPdfText|
	directory := FileSystem workingDirectory.
	pdfFile := directory / ('reportFile.pdf').
	textFile := directory / ('reportFile.txt').
	pdfFile exists ifTrue: [ pdfFile delete ].
	textFile exists ifTrue: [ textFile delete ].
	pdfFile binaryWriteStreamDo: [ :stream | stream nextPutAll: myPdf ].
	command := 'pdftotext {1} {2}' format: { pdfFile fullName. textFile fullName}.
	LibC system: command.
	"read the textFile..."
	externalPdfText := textFile readStream contents.
	^ externalPdfText 
]

{ #category : 'as yet unclassified' }
ApiToolTextFromImage >> old_evaluateTool: descs [
	"Evaluates the tool with the given descriptions and returns a dictionary representation of the tool's configuration."
	| desc desc1 desc2 |
	desc := descs first.
	desc1 := descs second.
	desc2 := descs third.
    ^ Dictionary newFrom: {
        'type' -> 'function'.
        'function' -> (Dictionary newFrom: {
            'name' -> name.
            'description' -> desc.
            'parameters' -> (Dictionary newFrom: {
                'type' -> 'object'.
                'properties' -> (Dictionary newFrom: {
                    required -> (Dictionary newFrom: {
                        'type' -> 'string'.
                        'description' -> desc1
                    })
                }).
                'required' -> {required} 
            })
        })
    }
]
