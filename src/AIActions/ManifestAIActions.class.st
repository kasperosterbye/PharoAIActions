"
# Package: AIActions

## Overview

The `AIActions` package is a comprehensive framework designed to integrate AI capabilities into the Pharo environment. This package provides a suite of tools and utilities to facilitate AI interactions, including conversation management, API integration, and comment generation. It is part of the broader `AIActions` ecosystem, which aims to enhance Pharo's capabilities with AI-driven features.

## Key Features

### AI API Integration

The package includes a robust set of classes for interacting with various AI APIs, such as Mistral, Ollama, and Gemini. These classes handle the configuration, message management, and response processing for different AI models. The `AilienApi` class serves as a base class for specific API implementations, providing common functionalities and ensuring a consistent interface.

### Conversation Management

The `AIAHistory` class is designed to manage and maintain conversation history between a user and an AI assistant. It provides functionality to store, retrieve, and format messages exchanged in a chat session, while also supporting contextual roles such as system messages and response types. This class is crucial for maintaining the context of conversations and ensuring a coherent interaction experience.

### Comment Generation

The package includes several classes dedicated to generating AI-driven comments for classes, methods, and packages. These classes, such as `AIAClassComment`, `AIAMethodComment`, and `AIAPackageComment`, leverage AI models to create concise and relevant comments. The `AIACommentBuilding` class serves as a helper for generating these comments, orchestrating the prompts and retrieving the generated text.

### User Interface Components

The package provides user interface components to interact with AI models and view the results. The `AIAHistoryPresenter` class displays and manages AI interaction history, allowing users to view past conversations, prompts, and responses. The `AIAProvidersPresenter` class manages and displays AI providers and their associated models, enabling users to select and configure different AI models.

### Utility Classes

The package includes various utility classes to support AI interactions and comment generation. These classes, such as `AIASourceCode`, `AIAPlantUML`, and `AilienOCR`, provide functionalities for generating source code descriptions, creating PlantUML diagrams, and performing OCR on images, respectively. These utilities enhance the overall functionality of the package and provide additional tools for developers.

## Design Considerations

The `AIActions` package is designed with a focus on modularity and extensibility. Each class is designed to perform a specific function, and the package provides a flexible framework for integrating AI capabilities into Pharo. The classes are well-documented, and the package includes a comprehensive set of tests to ensure reliability and correctness.

## Conclusion

The `AIActions` package is a powerful tool for integrating AI capabilities into the Pharo environment. It provides a robust set of classes and utilities to facilitate AI interactions, conversation management, and comment generation. The package is designed with a focus on modularity and extensibility, ensuring that it can be easily integrated into existing Pharo applications and enhanced with additional features as needed.
"
Class {
	#name : 'ManifestAIActions',
	#superclass : 'PackageManifest',
	#category : 'AIActions-Manifest',
	#package : 'AIActions',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestAIActions class >> ruleBadMessageRule2V1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIActions)) #'2026-01-02T20:04:20.718316+01:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleCascadedNextPutAllsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIActions)) #'2026-01-26T16:16:27.479822+01:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleCollectionProtocolRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIActions)) #'2025-08-27T08:15:54.641638+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleInconsistentMethodClassificationRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIActions)) #'2026-01-26T16:16:20.86571+01:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleMethodSourceContainsLinefeedsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#MistralApi #loadResponse #false)) #'2025-09-02T12:22:15.273687+02:00') )
]

{ #category : 'code-critics' }
ManifestAIActions class >> ruleModifiesCollectionRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIActions)) #'2025-12-08T09:44:16.373482+01:00') )
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
ManifestAIActions class >> ruleStringConcatenationRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#AIActions)) #'2025-12-08T09:44:27.589623+01:00') )
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
