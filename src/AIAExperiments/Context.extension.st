Extension { #name : 'Context' }

{ #category : '*AIAExperiments' }
Context >> isReturn [
	^ (InstructionStream on: method pc: pc) willReturn
]
