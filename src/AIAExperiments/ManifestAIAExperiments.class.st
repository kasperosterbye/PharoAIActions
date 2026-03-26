"
# Package Comment for AIAExperiments

The `AIAExperiments` package is a comprehensive framework designed to facilitate experiments and research in the field of Large Language Models (LLMs) and their applications. This package provides a suite of tools and utilities to interact with various LLM APIs, generate test cases, and analyse the responses from these models. It is particularly focused on understanding the behaviour of LLMs under different conversational patterns and structural constraints.

## Key Features

- **Multi-LLM Support**: The package includes classes to interact with multiple LLM providers, such as OpenAI, Mistral, Grok, and others. This allows for comparative analysis of responses from different models.

- **Test Generation**: The package includes tools to generate test cases for LLM responses. This is crucial for ensuring the reliability and correctness of the models' outputs.

- **Response Analysis**: Utilities are provided to analyse and compare the responses from different LLMs. This helps in understanding the strengths and weaknesses of each model.

- **Conversation Pattern Testing**: The package includes classes to test different conversation patterns, such as user-assistant interactions and assistant-only responses. This is essential for understanding how LLMs behave under different structural constraints.

- **Related Work Synthesis**: Tools are provided to synthesise information from multiple external papers. This helps in generating cohesive related work sections for research papers.

## Usage Examples

### Interacting with LLMs

```smalltalk
| api response |
api := OpenAIApi newOnModel: 1.
response := api getResponseForPrompt: 'Explain the concept of recursion in programming'.
response inspect.
```

### Generating Test Cases

```smalltalk
| testBuilder testResults |
testBuilder := AIATestBuilder new.
testResults := testBuilder build: (Object >> #yourMethod).
testResults inspect.
```

### Analysing Responses

```smalltalk
| storage writer markdown |
storage := AIA2MultiLLMStorage default.
writer := AIA2MultiLLMWriter new.
writer writeStorage: storage storeRows.
markdown := writer markdownResponse.
markdown inspect.
```

### Testing Conversation Patterns

```smalltalk
| builder storeLine |
builder := AIA2MultiLLMBuilder new.
storeLine := AIA2MultiLLMStoreLine new
    provider: OpenAIApi;
    llmNo: 1;
    turnPattern: #UAUAU;
    yourself.
builder buildResponseText: storeLine.
storeLine responseText inspect.
```

### Synthesising Related Work

```smalltalk
| synthesizer relatedWork |
synthesizer := AIA2RelatedWorkSynthesizer default.
relatedWork := synthesizer buildSynthesizerForGroup: #(1 2 3).
relatedWork inspect.
```

## Design Considerations

- **Modularity**: The package is designed with a modular approach, allowing for easy extension and modification of existing functionality.

- **Reproducibility**: The package includes tools to ensure that experiments are reproducible, which is crucial for research purposes.

- **Flexibility**: The package is designed to be flexible, allowing for the testing of a wide range of scenarios and models.

## Future Enhancements

- **API Refinement**: Align with Pharo's class default values and reduce conversion overhead.

- **Builder Enhancement**: Support for custom builder enhancers to extend functionality.

- **Additional LLM Providers**: Incorporate more LLM providers to broaden the scope of comparative analysis.

The `AIAExperiments` package is a valuable resource for researchers and developers working with LLMs, providing a comprehensive set of tools to facilitate experimentation and analysis.
"
Class {
	#name : 'ManifestAIAExperiments',
	#superclass : 'PackageManifest',
	#category : 'AIAExperiments-Manifest',
	#package : 'AIAExperiments',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestAIAExperiments class >> ruleUncommonMessageSendRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#AIATeacup)) #'2026-03-15T17:18:16.138401+01:00') )
]
