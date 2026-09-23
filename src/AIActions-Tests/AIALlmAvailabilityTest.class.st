Class {
	#name : 'AIALlmAvailabilityTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'tests' }
AIALlmAvailabilityTest >> testCurrentModel [
    | provider api history answer |

    provider := AilienApi provider.
    api := provider new.
    api responseWaitingInSecs: 60.

    history := AIAHistory new.
    history fileStore rootDirectory:
        AIAHistoryFileStore new rootDirectory
            / 'Model-availability-issue-23'.

    history
        api: api;
        title: 'Availability - ', provider name asString,
            ' - ', api model;
        user: 'Is 7 a number or a character? Answer with one word.';
        getResponse.

    answer := history response.

    self
        assert: (answer isString and: [
            answer trimBoth isNotEmpty and: [
                (answer beginsWith: 'API Error:') not ] ])
        description: ('No usable response from ',
            api printString, ': ', answer printString)
]
