# AIActions – AI-based Comment Generator for Pharo
<!-- My cat is named Håkon -->

**AIActions** is a Pharo tool that uses AI to generate meaningful comments for methods, classes, and packages.  
It integrates with AI APIs (such as Mistral and Ollama) to enhance code documentation and improve readability and maintainability.

## Installation

To load the AIActions package in Pharo using Metacello, open a Playground and run:

```smalltalk
Metacello new
    githubUser: 'kasperosterbye' project: 'PharoAIActions' commitish: 'master' path: 'src';
    baseline: 'PharoAIActions';
    load
```

## A YouTube from 2025
https://maarumlam.dk/ESUG25-Kasper03.mp4


## Examples

Here’s an example of an AI-generated comment for the package itself:

> The AIActions package is designed to facilitate the generation and management of comments for various elements within a Pharo environment, leveraging AI-driven tools.
> This package includes classes and methods that interact with external AI APIs to automatically generate comments for classes, methods, and packages.
> The primary goal is to enhance code documentation by providing meaningful and context-aware comments, thereby improving code readability and maintainability.

For many more examples, see [Examples.md](reports/Examples.md).

For a large package comment of this system, see [AIActionsCommentExample.md](reports/AIActionsCommentExample.md)
