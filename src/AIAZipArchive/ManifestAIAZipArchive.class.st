"
# Package Comment for AIAZipArchive

The `AIAZipArchive` package is a comprehensive collection of classes and tools designed to facilitate interaction with various Large Language Model (LLM) providers and to conduct experiments with these models. This package is particularly focused on testing and comparing the responses from different LLMs, particularly in the context of Pharo Smalltalk.

## Key Features

- **LLM Interaction**: Provides a unified interface to interact with multiple LLM providers, including OpenAI, Mistral, Grok, and others.
- **Experiment Framework**: Includes classes and methods to design, execute, and analyse experiments with LLMs.
- **Response Management**: Tools to manage and compare responses from different LLMs, including handling conversation history and tool calls.
- **Testing Infrastructure**: A robust framework for testing and validating the responses from LLMs, including test builders and test cases.
- **Utility Classes**: Various utility classes to support the core functionality, such as history management, source code analysis, and API tool integration.

## Core Classes

- **AilienApi**: The base class for interacting with various LLM providers, managing conversation history, and handling API requests.
- **AIAHistory**: Manages the conversation history for interactions with LLMs, including system messages, user prompts, and assistant responses.
- **AIA1MultiLLMResponseBase**: A base class for managing and comparing responses from multiple LLM providers, including methods for generating Markdown reports.
- **AIATestBuilder**: A builder class for generating test methods for Pharo classes, using LLMs to assist in the test generation process.
- **AIAToolsExperiment**: A class for conducting experiments with LLM tools, including evaluating Pharo expressions and retrieving class information.
- **PForth**: A Forth interpreter implemented in Pharo Smalltalk, providing a stack-based programming environment.

## Usage Examples

```smalltalk
""Example of creating and using an LLM API instance""
api := OpenAIApi new.
api model: 'gpt-5.1'.
api messageList: {('user' -> 'Hello, how are you?')}.
api loadResponse.
api responseOf: api lastResponse.

""Example of running an experiment with multiple LLMs""
experiment := AIA1MultiLLMResponseBase new.
experiment getResponses.
experiment markdownResponse.

""Example of generating a test method using an LLM""
testBuilder := AIATestBuilder new.
testBuilder sourceMethod: (Object >> #at:put:).
testMethod := testBuilder generateTest.
```

## Design Considerations

- **Modularity**: The package is designed with a modular architecture, allowing for easy extension and customisation.
- **Extensibility**: The core classes are designed to be extended by subclasses to tailor specific experiment configurations and reporting formats.
- **Error Handling**: Includes mechanisms for identifying and flagging LLM response errors and handling API errors gracefully.

The `AIAZipArchive` package is part of the broader `AIActions` package, supporting AI-driven experimentation and analysis workflows within the Pharo Smalltalk environment.
"
Class {
	#name : 'ManifestAIAZipArchive',
	#superclass : 'PackageManifest',
	#category : 'AIAZipArchive-Manifest',
	#package : 'AIAZipArchive',
	#tag : 'Manifest'
}
