Class {
	#name : 'AilienApiToolsTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'tests' }
AilienApiToolsTest >> testInstanceOverrideDoesNotChangeProviderSetting [
    | original api |

    original := OpenAIApi toolsEnabled.

    [
        OpenAIApi toolsEnabled: false.
        api := OpenAIApi new.

        self deny: api toolsEnabled.

        api toolsEnabled: true.

        self assert: api toolsEnabled.
        self deny: OpenAIApi toolsEnabled
    ]
    ensure: [
        OpenAIApi toolsEnabled: original ]
]

{ #category : 'tests' }
AilienApiToolsTest >> testInstanceUsesProviderToolsSetting [
    | original api |

    original := OpenAIApi toolsEnabled.

    [
        OpenAIApi toolsEnabled: false.
        api := OpenAIApi new.

        self deny: api toolsEnabled
    ]
    ensure: [
        OpenAIApi toolsEnabled: original ]
]

{ #category : 'tests' }
AilienApiToolsTest >> testProviderToolsAreEnabledByDefault [
    self assert: OpenAIApi toolsEnabled
]

{ #category : 'tests' }
AilienApiToolsTest >> testReasoningModelDisablesToolsByDefault [
    | api model |

    model := (OpenAIApi modelNames
        detect: [ :each |
            (OpenAIApi reasoningLevelsFor: each) isNotEmpty ]).

    api := OpenAIApi new.
    api model: model.

    self deny: api toolsEnabled
]

{ #category : 'tests' }
AilienApiToolsTest >> testReasoningModelsProduceRequestWithoutTools [
    OpenAIApi modelNamesAndReasoning
        select: [ :each | each value isNotEmpty ]
        thenDo: [ :each |
            | api entity |

            api := OpenAIApi new.
            api
                model: each key;
                messageList: #().

            entity := api znClientEntity asDictionary.

            self deny: (entity includesKey: 'tools').
            self
                assert: (entity at: 'reasoning_effort')
                equals: api reasoningLevel ]
]

{ #category : 'tests' }
AilienApiToolsTest >> testRequestContainsToolsWhenEnabled [
    | api entity |

    api := OpenAIApi new.
    api
        toolsEnabled: true;
        messageList: #().

    entity := api znClientEntity asDictionary.

    self assert: (entity includesKey: 'tools')
]

{ #category : 'tests' }
AilienApiToolsTest >> testRequestOmitsToolsWhenDisabled [
    | api entity |

    api := OpenAIApi new.
    api
        toolsEnabled: false;
        messageList: #().

    entity := api znClientEntity asDictionary.

    self deny: (entity includesKey: 'tools')
]

{ #category : 'tests' }
AilienApiToolsTest >> testToolsCanBeDisabledForInstance [
    | api |

    api := OpenAIApi new.
    api toolsEnabled: false.

    self deny: api toolsEnabled
]
