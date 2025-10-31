"
## Package: AIActions

# Overview

The `AIActions` package is a comprehensive framework designed to facilitate AI-driven development and interaction within the Pharo Smalltalk environment. It provides tools for generating and managing AI-generated comments, tests, and other development artifacts, leveraging various AI models and APIs.

## Key Components

### AI Comment Builders
- **AIACommentBuilding**: Base class for generating AI-driven comments
- **AIAClassComment**: Generates class-level documentation
- **AIAMethodComment**: Creates method-specific documentation
- **AIAPackageComment**: Produces package-level documentation
- **AIASlotComment**: Generates comments for instance variables

### AI Test Generation
- **AIATestBuilder**: Core framework for AI-generated test creation
- **AIATestBuilderExperiments**: Specialized test generation for experimental purposes
- **AIATestResultIllustration**: Visualizes test results

### AI API Integration
- **AilienApi**: Abstract base class for AI provider integration
- **MistralApi**: Implementation for Mistral AI models
- **GeminiApi**: Implementation for Google's Gemini models
- **ClaudeApi**: Implementation for Anthropic's Claude models
- **OllamaApi**: Implementation for local Ollama models
- **OpenAIApi**: Implementation for OpenAI models

### Browser Integration
- **AIAClyCommentShow**: Displays AI comments in the browser
- **AIAClyClassCommentShow**: Shows class comments in the browser
- **AIAClyMethodCommentShow**: Displays method comments in the browser
- **AIAClyPackageCommentShow**: Presents package comments in the browser

## Usage Scenarios

1. **Automated Documentation**:
   - Generate class, method, and package comments using AI
   - Maintain consistent documentation style across projects

2. **Test Generation**:
   - Create unit tests automatically based on method implementations
   - Generate test suites for entire packages

3. **AI Interaction**:
   - Interact with multiple AI models through a unified interface
   - Maintain conversation history for context-aware interactions

## Design Considerations

- **Modular Architecture**: Components are designed to be independent and composable
- **Extensible**: New AI providers and builders can be added easily
- **Non-Invasive**: Works alongside existing Pharo development tools
- **Context-Aware**: Maintains conversation history for coherent interactions

## Future Directions

- Integration with additional AI models and services
- Enhanced test generation capabilities
- Improved documentation generation with more sophisticated prompts
- Better visualization tools for test results and code analysis

The `AIActions` package represents a significant advancement in AI-assisted development within Pharo, providing developers with powerful tools to enhance productivity and maintain code quality.
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
