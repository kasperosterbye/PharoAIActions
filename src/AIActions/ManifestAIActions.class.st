"
# AIActions Package Comment

## Overview

The `AIActions` package provides a comprehensive framework for integrating artificial intelligence capabilities into Pharo Smalltalk applications. It offers a suite of classes and tools designed to facilitate seamless interactions with various AI models, including those from Mistral, Gemini, Claude, and Ollama. The package emphasises modularity, extensibility, and ease of use, enabling developers to build AI-powered features such as automated code commenting, test generation, and conversational interfaces.

## Key Features

- **AI API Integration**: Supports multiple AI providers with dedicated API classes (e.g., `MistralApi`, `GeminiApi`, `ClaudeApi`, `OllamaApi`) for handling authentication, request formatting, and response parsing.
- **Conversation Management**: Includes classes like `AilienApi` and `AIADiscussion` for maintaining structured chat histories and managing multi-turn conversations.
- **Automated Comment Generation**: Features builders such as `AIAMethodComment`, `AIAClassComment`, and `AIAPackageComment` for generating AI-assisted documentation for methods, classes, and packages.
- **Test Generation**: Provides `AIATestBuilder` and its subclasses for creating automated unit tests using AI analysis of source code.
- **Browser Integration**: Offers command classes (e.g., `AIAClyMethodCommentSet`, `AIAClyClassCommentSet`) for integrating AI actions directly into the Pharo system browser.
- **Source Code Analysis**: Includes `AIASourceCodeBuilder` for extracting and formatting class definitions, methods, and dependencies for AI processing.
- **Visualisation Tools**: Supports result visualisation with classes like `AIATestResultIllustration` for displaying test outcomes.
- **Extensibility**: Designed with builder patterns and enhancers to allow customisation and extension for specific AI workflows.

## Usage Examples

### Basic AI Interaction
```smalltalk
""Create and configure a Mistral API instance""
api := MistralApi new.
api system: 'You are a helpful assistant'.
api user: 'Explain polymorphism in object-oriented programming'.
api getResponse.
api response.  ""Inspect the AI's response""
```

### Generating Method Comments
```smalltalk
""Generate an AI-assisted comment for a method""
commenter := AIAMethodComment new.
commenter aiaComment: (Point >> #x).
commenter response.  ""View the generated comment""
```

### Automated Test Generation
```smalltalk
""Build tests for all methods in a class""
builder := AIATestBuilder new.
builder buildAll: Point.  ""Generates tests for Point class methods""
```

### Package Documentation
```smalltalk
""Generate a comment for the current package""
commenter := AIAPackageComment new.
commenter aiaComment: 'AIActions'.
commenter response.  ""View the package comment""
```

## Implementation Notes

- **API Keys**: Requires valid API keys stored in local files (e.g., `mistralcode.txt`, `geminicode.txt`) for authentication with external AI services.
- **Error Handling**: Implements robust error management with fallback responses and logging for failed API calls.
- **Threading**: Uses background processes for non-blocking AI interactions, allowing the UI to remain responsive.
- **Data Formats**: Handles JSON parsing for API responses and supports Markdown formatting for generated content.
- **Dependencies**: Relies on external libraries like `ZnClient` for HTTP requests and `STONJSON` for JSON processing.
- **Testing**: Includes comprehensive test suites in the `AIActions-Tests` subpackage to ensure reliability.

## Design Principles

The package follows several key design principles:
- **Modularity**: Each AI provider has its own class, allowing easy addition of new providers.
- **Fluid Syntax**: Builders support method chaining for intuitive scripting.
- **Separation of Concerns**: API interactions are separated from UI and processing logic.
- **Extensibility**: Uses subclassing and composition to enable customisation.
- **Non-Invasive**: Integrates with Pharo's existing tools without modifying core functionality.

## Future Enhancements

Potential areas for expansion include:
- Support for additional AI providers and models.
- Enhanced visualisation for conversation histories.
- Integration with continuous integration pipelines for automated testing.
- Advanced prompt engineering features.
- Performance optimisation for large-scale code analysis.

## See Also

- `AilienApi`: Base class for AI API interactions.
- `AIABuilder`: Base class for various AI-powered builders.
- `AIASourceCodeBuilder`: For code analysis and formatting.
- `AIATestBuilder`: For automated test generation.
- `AIACommentPresenter`: For displaying generated comments.

This package represents a powerful toolkit for leveraging AI in Pharo development, promoting productivity and code quality through intelligent automation.
"
Class {
	#name : 'ManifestAIActions',
	#superclass : 'PackageManifest',
	#category : 'AIActions-Manifest',
	#package : 'AIActions',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestAIActions class >> ruleCollectionProtocolRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIActions)) #'2025-08-27T08:15:54.641638+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleMethodSourceContainsLinefeedsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#MistralApi #loadResponse #false)) #'2025-09-02T12:22:15.273687+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleReGuardClauseRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#AIATest01)) #'2025-07-23T12:54:26.010851+02:00') #(#(#RGPackageDefinition #(#AIActions)) #'2025-08-15T14:28:36.252093+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleRefersToClassRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMetaclassDefinition #(#'AilienApi class' #AilienApi)) #'2025-09-26T17:41:29.131197+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleSelfSentNotImplementedRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#String #c #false)) #'2025-07-23T09:27:53.369678+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleUnclassifiedMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIActions)) #'2025-07-21T10:30:28.236326+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleWhileTrueRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIActions)) #'2025-10-12T10:01:09.302776-04:00') )
]
