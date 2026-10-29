Class {
	#name : 'AIAHistoryTimeoutTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'tests' }
AIAHistoryTimeoutTest >> testGetResponsePreservesSuccessfulResponse [
    "A successful API response must not be replaced by a timeout message."

    | history api |

    history := AIAHistory new.
    api := AIAHistorySuccessfulTestApi new.

    history
        api: api;
        user: 'Test successful response'.

    history getResponse.

    self
        assert: history response
        equals: 'Successful test response'.

    self
        deny: (history messages anySatisfy: [ :message |
            message key = 'assistant'
                and: [ message value = 'AI based response timed out' ] ])
]

{ #category : 'tests' }
AIAHistoryTimeoutTest >> testGetResponseTerminatesProcessOnTimeout [
    "A timed-out API request must not leave its worker running."

    | history api |

    history := AIAHistory new.
    api := AIAHistorySlowTestApi new.

    history
        api: api;
        user: 'Test timeout'.

    history getResponse.

    self assert: api workerProcess notNil.
    self assert: api workerProcess isTerminated.
    self
        assert: history response
        equals: 'AI based response timed out'
]
