"
# AileinProvider

`AileinProvider` is an abstract base class for managing AI API providers in the AIActions framework. It provides a centralized way to register, access, and configure different AI service providers (e.g., Mistral, OpenAI, etc.).

## Responsibilities
- Maintain a registry of available AI providers
- Manage the default provider selection
- Provide access to provider-specific functionality

## Usage Example

```smalltalk
""List all available providers (returns a sorted collection)""
AileinProvider providers inspect

""Set the default provider by class name""
AileinProvider provider: MistralApi.
AileinProvider provider inspect  ""Should return MistralApi""

""Set the default provider by index (1-based)""
AileinProvider provider: 1.
AileinProvider provider inspect  ""Should return the first provider in the list""

""Get the current default provider""
AileinProvider provider inspect  ""Returns the currently configured provider""
```

## Design Notes
- Follows the Singleton pattern for default provider management
- Uses class-side methods for provider registration and access
- Provides both symbolic (class name) and numeric (index) provider selection
- Defaults to MistralApi if no provider is explicitly set

## Implementation Notes
- Subclasses should implement specific provider functionality
- The `providers` method returns a sorted collection of available providers
- The `provider:` method handles both direct class references and numeric indices
- The class maintains its state in the `defaultProvider` class variable

## Example Class Creation (for reference)

```smalltalk
""Example of how to create a new provider class (not part of the AileinProvider functionality)""
Object << #NewAIProvider
    slots: {};
    tag: 'AIApi';
    package: 'AIActions'.
NewAIProvider compile: 'name ^ ''New Provider'''.
NewAIProvider compile: 'apiEndpoint ^ ''https://api.newprovider.com'''.
NewAIProvider compile: 'apiKey: aKey ^ ''Configured with: '' , aKey'.
NewAIProvider subclass: #NewAIProviderV2.
NewAIProviderV2 compile: 'name ^ ''New Provider V2'''.
NewAIProviderV2 inspect  ""Inspect the newly created class""
```

The example shows how to:
1. List available providers (returns a collection that can be inspected)
2. Set and verify the default provider by class name
3. Set and verify the default provider by numeric index
4. Retrieve the current default provider
5. Includes a reference example of how to create new provider classes
"
Class {
	#name : 'AileinProvider',
	#superclass : 'Object',
	#classInstVars : [
		'defaultProvider'
	],
	#category : 'AIActions-AIApi',
	#package : 'AIActions',
	#tag : 'AIApi'
}

{ #category : 'accessing' }
AileinProvider class >> defaultProvider [
	^ MistralApi 
]

{ #category : 'class initialization' }
AileinProvider class >> initialize [
	defaultProvider := self defaultProvider 
]

{ #category : 'accessing' }
AileinProvider class >> provider [
	defaultProvider ifNil: [ self initialize ].
	^ defaultProvider 
]

{ #category : 'accessing' }
AileinProvider class >> provider: aProvider [

	| providers |
	providers := self providers.
	(providers includes: aProvider) ifTrue: [
			defaultProvider := aProvider.
			^ self ].
	(aProvider isInteger and: [ aProvider > 0 and: [ aProvider < self providers size ] ]) ifTrue: [
			defaultProvider := providers at: aProvider.
			^ self ].
	defaultProvider := MistralApi
]

{ #category : 'accessing' }
AileinProvider class >> providers [
	^ (AilienApi subclasses sort: [:a :b | a name < b name])
]
