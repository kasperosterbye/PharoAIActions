Class {
	#name : 'AIAReasoningSettingsTest',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'savedSelections'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'running' }
AIAReasoningSettingsTest >> setUp [
    super setUp.
    model := 'gpt-6-luna'.
    savedSelections := AIAReasoningSettings selections copy.
    AIAReasoningSettings reset
]

{ #category : 'running' }
AIAReasoningSettingsTest >> tearDown [
    AIAReasoningSettings reset.
    savedSelections keysAndValuesDo: [ :modelName :level |
        AIAReasoningSettings
            level: level
            forModel: modelName ].
    super tearDown
]

{ #category : 'tests' }
AIAReasoningSettingsTest >> testChangingDefaultAffectsExistingInstance [
    | api  |

    AIAReasoningSettings level: 'low' forModel: model.

    api := OpenAIApi new.
    api model: model.

    self assert: api reasoningLevel equals: 'low'.

    AIAReasoningSettings level: 'high' forModel: model.

    self assert: api reasoningLevel equals: 'high'
]

{ #category : 'tests' }
AIAReasoningSettingsTest >> testConfiguredReasoningLevel [
    | api  |

    AIAReasoningSettings level: 'low' forModel: model.

    api := OpenAIApi new.
    api model: model.

    self assert: api reasoningLevel equals: 'low'
]

{ #category : 'tests' }
AIAReasoningSettingsTest >> testExplicitLevelOverridesConfiguredLevel [
    | api |

    AIAReasoningSettings level: 'low' forModel: model.

    api := OpenAIApi new.
    api model: model.
    api reasoningLevel: 'high'.

    self assert: api reasoningLevel equals: 'high'
]

{ #category : 'tests' }
AIAReasoningSettingsTest >> testExplicitReasoningLevel [
    | api |

    api := OpenAIApi new.
    api reasoningLevel: 'high'.

    self assert: api reasoningLevel equals: 'high'
]

{ #category : 'tests' }
AIAReasoningSettingsTest >> testRemovingSelectionRestoresFallback [
	"Removing a configured reasoning level restores the fallback for the model"
    | api expected |

    api := OpenAIApi new.
    api model: model.

    expected := api reasoningLevels
        ifEmpty: [ nil ]
        ifNotEmpty: [ :levels | levels middle ].

    AIAReasoningSettings level: 'high' forModel: model.
    self assert: api reasoningLevel equals: 'high'.

    AIAReasoningSettings level: nil forModel: model.

    self assert: api reasoningLevel equals: expected
]
