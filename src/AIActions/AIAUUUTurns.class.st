Class {
	#name : 'AIAUUUTurns',
	#superclass : 'AIAMultiLLMResponseBase',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'markdown' }
AIAUUUTurns >> excludeProviders [
	"This method excludes specific providers from the list of available models."
	^ { MistralApiWithTools. OllamaApi }
]

{ #category : 'as yet unclassified' }
AIAUUUTurns >> markdown0Title [
	MarkDown 
		<< '# Experiment unbalanced turns - multiple user: prompts. On '<< Date today asString << String cr << String cr.
	
]

{ #category : 'markdown' }
AIAUUUTurns >> markdown2LLMResponses [
	MarkDown << '### Responses of `user: user: user:` ' << String cr << String cr.
	
	MarkDown << '| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |' << String cr.
	MarkDown << '| ------------ | ----------- | ----------- | ----------- | ----------- |' << String cr.
	results do: [ :res |
		MarkDown << '| ' << res key asString << ' | ' .
		res value do: [ :resp | MarkDown << resp value asString << ' | '  ].
		MarkDown << String cr].
	^ MarkDown contents
]

{ #category : 'markdown' }
AIAUUUTurns >> resonseOf: aiLLM [

	^ aiLLM asString
]
