Class {
	#name : 'AIAModelAvailabilityEvaluator',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'accessing' }
AIAModelAvailabilityEvaluator >> evaluate: histories [
    ^ histories collect: [ :history |
        history -> (self statusFor: history) ]
]

{ #category : 'as yet unclassified' }
AIAModelAvailabilityEvaluator >> problemDescriptions: histories [
    ^ (self problems: histories) collect: [ :assoc |
        assoc key printString, ' -> ', assoc key response ]
]

{ #category : 'as yet unclassified' }
AIAModelAvailabilityEvaluator >> problems: histories [
    ^ (self evaluate: histories)
        reject: [ :assoc | assoc value = #ok ]
]

{ #category : 'accessing' }
AIAModelAvailabilityEvaluator >> statusFor: history [
    | response |

    (history messages anySatisfy: [ :message |
        message key = 'comment'
            and: [ message value beginsWith: 'EXCEPTION:' ] ])
        ifTrue: [ ^ #exception ].

    response := history response.

    response ifNil: [ ^ #noResponse ].
    response trimBoth ifEmpty: [ ^ #empty ].

    (response beginsWith: 'API Error:')
        ifTrue: [ ^ #apiError ].

    ^ #ok
]

{ #category : 'as yet unclassified' }
AIAModelAvailabilityEvaluator >> summary: histories [
    | statuses counts |

    statuses := histories collect: [ :history |
        self statusFor: history ].

    counts := Dictionary new.

    statuses do: [ :status |
        counts
            at: status
            put: ((counts at: status ifAbsent: [ 0 ]) + 1) ].

    ^ counts
]
