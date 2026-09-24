Class {
	#name : 'AilienApiReasoningTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'tests' }
AilienApiReasoningTest >> testAstraGetsDefaultReasoningLevel [
    | api |

    api := OpenAIApi new.
    api model: 'gpt-6-astra'.

    self
        assert: (api reasoningLevels includes: api reasoningLevel)
]

{ #category : 'tests' }
AilienApiReasoningTest >> testAstraReasoningLevels [
    | api |

    api := OpenAIApi new.
    api model: OpenAIApi modelNames last.

    self
        assert: api reasoningLevels
        equals: #( low medium high xhigh max )


]

{ #category : 'tests' }
AilienApiReasoningTest >> testDefaultReasoningLevel [
    | api |

    api := OpenAIApi new.

    self assert: api reasoningLevel isNil
]

{ #category : 'tests' }
AilienApiReasoningTest >> testNonReasoningRequestDoesNotContainReasoningEffort [
    | api entity model |

    model := (OpenAIApi modelNamesAndReasoning
        detect: [ :each | each value isEmpty ]) key.

    api := OpenAIApi new.
    api
        model: model;
        messageList: #().

    entity := api znClientEntity asDictionary.

    self deny: (entity includesKey: 'reasoning_effort')
]

{ #category : 'tests' }
AilienApiReasoningTest >> testOpenAIRequestContainsReasoningLevel [
    | api entity |

    api := OpenAIApi new.
    api
        model: OpenAIApi modelNames last;
        reasoningLevel: 'high';
        messageList: #().

    entity := api znClientEntity.

    self
        assert: (entity asDictionary at: 'reasoning_effort')
        equals: 'high'
]

{ #category : 'tests' }
AilienApiReasoningTest >> testReasoningModelHasReasoningLevels [
    | api |

    api := OpenAIApi new.
    api model: OpenAIApi modelNames last.

    self assert: api reasoningLevels isNotEmpty
]
