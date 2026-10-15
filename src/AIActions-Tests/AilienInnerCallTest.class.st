Class {
	#name : 'AilienInnerCallTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'tests' }
AilienInnerCallTest >> testProcessToolCallRecordsHistory [
    "A tool execution must preserve its arguments and result
    in the conversation history for subsequent LLM turns."

    | history api inner call result recorded |

    history := AIAHistory new.
    history fileStore rootDirectory:
        FileSystem memory root / 'tool-test'.

    api := AilienApi provider new.
    "history api: api."

    inner := AilienInnerCall on: api turn: 1.

    call := Dictionary newFrom: {
        'id' -> 'call123'.
        'function' -> (Dictionary newFrom: {
            'name' -> 'getClassInfo'.
            'arguments' -> '{"className":"AilienApiTool"}' })
    }.

    result := inner processToolCall: call history: history.

    self assert: result key equals: 'tool'.
    self assert: history messages size equals: 1.

    recorded := history messages first.
    self assert: recorded key equals: 'assistant'.
    self assert:
        (recorded value includesSubstring: 'getClassInfo').
    self assert:
        (recorded value includesSubstring: 'AilienApiTool').
    self assert:
        (recorded value includesSubstring: '[tool_response]').
]

{ #category : 'tests' }
AilienInnerCallTest >> testSubclassesDoNotOverrideProcessToolCall [
    "Tool execution and history recording must be handled
    centrally rather than overridden by individual providers."

    | overridingClasses |

    overridingClasses := AilienInnerCall allSubclasses select: [ :class |
        class methodDict includesKey: #processToolCall: ].

    self assert: overridingClasses isEmpty
        description: 'Classes overriding processToolCall: ',
            (', ' join: (overridingClasses collect: [ :each |
                each name asString ]))
]
