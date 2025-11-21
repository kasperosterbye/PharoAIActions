# Package: AIActions

The `AIActions` package is designed to facilitate the generation and management of comments for various elements within a Pharo environment, leveraging AI-driven tools. This package includes classes and methods that interact with external AI APIs to automatically generate comments for classes, methods, and packages. The primary goal is to enhance code documentation by providing meaningful and context-aware comments, thereby improving code readability and maintainability.

## Key Features

### AI-Driven Comment Generation
The package utilises AI models to generate comments for classes, methods, and packages. This is achieved through the `AIACommentBuilding` class, which interfaces with AI APIs to generate appropriate comments based on the context of the code elements.

### Flexible and Extensible
The `AIActions` package is built with flexibility and extensibility in mind. It can be easily extended to support additional AI models or to integrate with different AI APIs. The core classes and methods are designed to be modular, allowing developers to customise the comment generation process to suit their specific needs.

### Integration with Pharo Environment
The package is tightly integrated with the Pharo environment, making it seamless to generate and update comments directly within the development environment. This integration ensures that the generated comments are always up-to-date with the latest changes in the codebase.

### Support for Multiple AI Models
The package supports multiple AI models, including Mistral and Ollama. This allows developers to choose the AI model that best fits their requirements, ensuring that the generated comments are of high quality and relevance.

## Classes and Their Responsibilities

### AIAClassComment
The `AIAClassComment` class is responsible for generating comments for classes. It interacts with the `AIASourceCodeBuilder` to build a formatted string describing the class and its methods, which is then used to generate the comment.

### AIASourceCodeBuilder
The `AIASourceCodeBuilder` class is a utility class that generates formatted strings describing classes, methods, and packages. It is used by other classes in the package to build the context required for generating comments.

### MistralApi
The `MistralApi` class is responsible for interacting with the Mistral AI API. It handles the creation of API requests, sending them to the API, and processing the responses. This class is used by the `AIACommentBuilding` class to generate comments.

### AIACommentBuilding
The `AIACommentBuilding` class is the core class responsible for building comments using AI. It interacts with the `MistralApi` or `OllamaModelsApi` to generate comments based on the context provided by the `AIASourceCodeBuilder`.

### AIAMethodComment
The `AIAMethodComment` class is responsible for generating comments for methods. It interacts with the `AIASourceCodeBuilder` to build a formatted string describing the method and its usage, which is then used to generate the comment.

### AIAPackageComment
The `AIAPackageComment` class is responsible for generating comments for packages. It interacts with the `AIASourceCodeBuilder` to build a formatted string describing the package and its contents, which is then used to generate the comment.

### AilienApi
The `AilienApi` class is a base class for interacting with AI APIs. It provides common functionality for creating API requests, sending them to the API, and processing the responses. This class is extended by the `MistralApi` and `OllamaModelsApi` classes.

### OllamaModelsApi
The `OllamaModelsApi` class is responsible for interacting with the Ollama AI API. It handles the creation of API requests, sending them to the API, and processing the responses. This class is used by the `AIACommentBuilding` class to generate comments.

## Usage

To use the `AIActions` package, developers can simply call the appropriate methods on the classes provided by the package. For example, to generate a comment for a class, developers can use the `AIAClassComment` class as follows:

```smalltalk
| commentBuilder |
commentBuilder := AIAClassComment new.
commentBuilder setComment: MyClass.
```

Similarly, to generate a comment for a method, developers can use the `AIAMethodComment` class:

```smalltalk
| commentBuilder |
commentBuilder := AIAMethodComment new.
commentBuilder setComment: MyClass >> #myMethod.
```

The package also provides methods for generating comments for packages, allowing developers to easily document their entire codebase.

## Conclusion

The `AIActions` package is a powerful tool for enhancing code documentation in a Pharo environment. By leveraging AI-driven tools, it provides meaningful and context-aware comments that improve code readability and maintainability. With its flexible and extensible design, the package can be easily customised to suit the specific needs of developers.
