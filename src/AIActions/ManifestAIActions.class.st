"
# Package Comment for AIActions

## Overview

The `AIActions` package is designed to provide a robust framework for integrating artificial intelligence (AI) capabilities into Pharo applications. This package leverages various AI models and APIs to enhance the functionality of applications by automating tasks, generating content, and providing intelligent responses. The package is built with a focus on modularity, extensibility, and ease of use, making it suitable for developers of all skill levels.

## Key Features

### 1. **AI Model Integration**
The `AIActions` package supports integration with multiple AI models, including but not limited to:
- **MistralApi**: A versatile API for generating text, answering questions, and performing various natural language processing tasks.
- **OllamaApi**: Another powerful API for AI-driven tasks, offering a wide range of functionalities.

### 2. **Automated Comment Generation**
One of the standout features of the `AIActions` package is its ability to automatically generate comments for classes, methods, and packages. This is achieved through the `AI_CommentBuilding` class, which uses AI models to analyze code and generate meaningful comments. This not only improves code readability but also aids in documentation and maintenance.

### 3. **Experiment Management**
The package includes classes for managing and running experiments with AI models. For example, `MistralApiExperiments` and `OllamaApiExperiments` allow developers to test different prompts and evaluate the performance of AI models. These classes provide a structured way to conduct experiments, track results, and visualize performance metrics.

### 4. **Package and Class Commenting**
The `AIActions` package provides tools for generating comments for entire packages and individual classes. The `AI_PackageComment` and `AI_ClassComment` classes use AI models to analyze the structure and content of packages and classes, generating comprehensive and informative comments.

### 5. **User Interface for Experiments**
The package includes user interface components for managing and visualizing experiments. For instance, `MistralApiExperimentsPresenter` and `OllamaApiExperimentsPresenter` provide a graphical interface for running experiments, monitoring progress, and viewing results. These interfaces are built using the Spec framework, ensuring a consistent and intuitive user experience.

## Detailed Class Descriptions

### **AI_CommentBuilding**
The `AI_CommentBuilding` class is responsible for generating comments for classes and methods. It uses AI models to analyze the code and generate meaningful comments. The class provides methods for setting the system and prompt, as well as for generating and adding comments to the code.

### **MistralApi**
The `MistralApi` class provides an interface for interacting with the Mistral AI API. It supports sending prompts, receiving responses, and managing API tokens. The class is designed to be easy to use and integrate into other parts of the application.

### **OllamaApi**
Similar to `MistralApi`, the `OllamaApi` class provides an interface for interacting with the Ollama AI API. It supports sending prompts, receiving responses, and managing API tokens. The class is designed to be easy to use and integrate into other parts of the application.

### **MistralApiExperiments**
The `MistralApiExperiments` class is used for running experiments with the Mistral AI API. It provides methods for initializing the model, running prompts, and saving results. The class also includes methods for visualizing results and tracking performance metrics.

### **OllamaApiExperiments**
The `OllamaApiExperiments` class is used for running experiments with the Ollama AI API. It provides methods for initializing the model, running prompts, and saving results. The class also includes methods for visualizing results and tracking performance metrics.

### **AI_PackageComment**
The `AI_PackageComment` class is responsible for generating comments for entire packages. It uses AI models to analyze the structure and content of the package, generating comprehensive and informative comments. The class provides methods for setting the package source and generating the comment.

### **AI_ClassComment**
The `AI_ClassComment` class is responsible for generating comments for individual classes. It uses AI models to analyze the structure and content of the class, generating comprehensive and informative comments. The class provides methods for setting the class source and generating the comment.

### **AI_MethodComment**
The `AI_MethodComment` class is responsible for generating comments for individual methods. It uses AI models to analyze the structure and content of the method, generating comprehensive and informative comments. The class provides methods for setting the method source and generating the comment.

## Example Usage

### Generating a Package Comment
To generate a package comment, you can use the `AI_PackageComment` class as follows:
```smalltalk
| packageComment |
packageComment := AI_PackageComment new.
packageComment setComment: 'AIActions'.
```
This will generate a comment for the `AIActions` package and set it as the package comment.

### Running an Experiment
To run an experiment with the Mistral AI API, you can use the `MistralApiExperiments` class as follows:
```smalltalk
| experiment |
experiment := MistralApiExperiments new.
experiment initializeMistralModel.
experiment runModelsWithPrompt: 'What is an Unary Message in Pharo' saveToFile: 'Test02a'.
```
This will initialize the Mistral model, run the prompt, and save the results to a file.

## Conclusion

The `AIActions` package is a powerful tool for integrating AI capabilities into Pharo applications. With its robust framework for AI model integration, automated comment generation, experiment management, and user interface components, it provides a comprehensive solution for developers looking to enhance their applications with AI. Whether you are building a simple application or a complex system, the `AIActions` package offers the tools and flexibility you need to succeed.
"
Class {
	#name : 'ManifestAIActions',
	#superclass : 'PackageManifest',
	#category : 'AIActions-Manifest',
	#package : 'AIActions',
	#tag : 'Manifest'
}
