Class {
	#name : 'AIAAAATurns',
	#superclass : 'AIAMultiLLMResponseBase',
	#category : 'AIActions-Experiments',
	#package : 'AIActions',
	#tag : 'Experiments'
}

{ #category : 'markdown' }
AIAAAATurns >> excludeProviders [
	"This method excludes specific providers from the list of available models."
	^ { MistralApiWithTools. OllamaApi. GeminiApi }
]

{ #category : 'as yet unclassified' }
AIAAAATurns >> markdown0Title [
	MarkDown 
		<< '# Experiment unbalanced turns - multiple user: prompts. On '<< Date today asString << String cr << String cr.
	
]

{ #category : 'markdown' }
AIAAAATurns >> markdown2LLMResponses [
	MarkDown << '### Responses of `user: user: user:` ' << String cr << String cr.
	
	MarkDown << '| **provider** | **Model 1** | **Model 2** | **Model 3** | **Model 4** |' << String cr.
	MarkDown << '| ------------ | ----------- | ----------- | ----------- | ----------- |' << String cr.
	self results do: [ :res |
		MarkDown << '| ' << res key asString << ' | ' .
		res value do: [ :resp | MarkDown << resp value asString << ' | '  ].
		MarkDown << String cr].
	^ MarkDown contents
]

{ #category : 'markdown' }
AIAAAATurns >> responseOf: aiLLM [
	| hist |
	hist := AIAHistory new.
	hist 
		api: aiLLM;
		user: 'aaa is 2';
		user: 'bbb is 3';
		user: 'what is the sum of aaa and bbb';
		getResponse.
	^ hist response maxFirst: 15
]
