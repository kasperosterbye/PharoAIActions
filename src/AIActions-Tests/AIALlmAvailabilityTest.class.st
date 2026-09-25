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

{ #category : 'tests' }
AIALlmAvailabilityTest >> testLastOpenAIModelReturnsUsableResponse [
    | originalProvider originalModelIndex answer |

    originalProvider := AilienApi provider.
    originalModelIndex :=
        OpenAIApi modelNames indexOf: OpenAIApi defaultModel.

    [
        AilienApi provider: OpenAIApi.
        OpenAIApi defaultModel: OpenAIApi modelNames size.
        answer := (AIAHistory new
				user: 'Who is Kilroy';
				getResponse; 
				response).

        self assert: answer isString.
        self assert: answer trimBoth isNotEmpty.
        self deny: (answer beginsWith: 'API Error:')
    ]
    ensure: [
        AilienApi provider: originalProvider.
        OpenAIApi defaultModel: originalModelIndex ]
]
