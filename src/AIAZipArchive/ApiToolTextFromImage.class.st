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
	#category : 'AIAZipArchive-AIApiTools',
	#package : 'AIAZipArchive',
	#tag : 'AIApiTools'
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
