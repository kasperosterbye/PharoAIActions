Class {
	#name : 'AIAMethodCommentExperiment',
	#superclass : 'AIAMethodComment',
	#category : 'AIAExperiments',
	#package : 'AIAExperiments'
}

{ #category : 'internals' }
AIAMethodCommentExperiment >> getComment_A: aCompiledMethod [
	| mistral |
	compiledMethod := aCompiledMethod.
	
	methodSource := (self commentSourceFor: compiledMethod) .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 60 chacters, and only letters'.
	mistral := MistralApi new.
	mistral system: (self commentSourceFor: compiledMethod).
	response := mistral getResponseForPrompt: prompt.
	^ {'A'. response. prompt. mistral system }
]

{ #category : 'internals' }
AIAMethodCommentExperiment >> getComment_B: aCompiledMethod [
	| mistral |
	compiledMethod := aCompiledMethod.
	
	methodSource := (self commentSourceFor: compiledMethod) .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 60 chacters, and only letters'.
	mistral := MistralApi new.
	mistral system: (AIASourceCodeBuilder new forMethod: aCompiledMethod ).
	response := mistral getResponseForPrompt: prompt.
	^ {'B'. response. prompt. mistral system }
]

{ #category : 'internals' }
AIAMethodCommentExperiment >> getComment_C: aCompiledMethod [
	| mistral |
	compiledMethod := aCompiledMethod.
	
	methodSource := (self commentSourceFor: compiledMethod) .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		aCompiledMethod name, 
			'. Your response should be 60 chacters, and only letters'.
	mistral := MistralApi new.
	mistral system: (self commentSourceFor: compiledMethod), String cr, (AIASourceCodeBuilder new forMethod: aCompiledMethod ).
	response := mistral getResponseForPrompt: prompt.
	^ {'C'. response. prompt. mistral system }
]

{ #category : 'internals' }
AIAMethodCommentExperiment >> getComment_D: aCompiledMethod [
	| mistral |
	compiledMethod := aCompiledMethod.
	
	methodSource := (self commentSourceFor: compiledMethod) .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		(self commentSourceFor: compiledMethod), 
			'. Your response should be 60 chacters, and only letters'.
	mistral := MistralApi new.
	mistral system: (self commentSourceFor: compiledMethod).
	response := mistral getResponseForPrompt: prompt.
	^ {'D'. response. prompt. mistral system }
]

{ #category : 'internals' }
AIAMethodCommentExperiment >> getComment_E: aCompiledMethod [
	| mistral |
	compiledMethod := aCompiledMethod.
	
	methodSource := (self commentSourceFor: compiledMethod) .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		(self commentSourceFor: compiledMethod), 
			'. Your response should be 60 chacters, and only letters'.
	mistral := MistralApi new.
	mistral system: (AIASourceCodeBuilder new forMethod: aCompiledMethod ).
	response := mistral getResponseForPrompt: prompt.
	^ {'E'. response. prompt. mistral system }
]

{ #category : 'internals' }
AIAMethodCommentExperiment >> getComment_F: aCompiledMethod [
	| mistral |
	compiledMethod := aCompiledMethod.
	
	methodSource := (self commentSourceFor: compiledMethod) .
	prompt := 'This is a Pharo question. Can your give a method comment for ' , 
		(self commentSourceFor: compiledMethod), 
			'. Your response should be 60 chacters, and only letters'.
	mistral := MistralApi new.
	mistral system: (self commentSourceFor: compiledMethod), String cr, (AIASourceCodeBuilder new forMethod: aCompiledMethod ).
	response := mistral getResponseForPrompt: prompt.
	^ {'F'. response. prompt. mistral system }
]
