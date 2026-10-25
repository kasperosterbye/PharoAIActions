Class {
	#name : 'AIAFullLLMTesterLiveTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'tests' }
AIAFullLLMTesterLiveTest >> testClassInfo: aProvider model: aModel [
    "Verify that the LLM can retrieve information from a Pharo class comment."

    | api history answer |

    api := aProvider new.
    api
        model: aModel;
        toolsEnabled: true;
        responseWaitingInSecs: 60.

    history := AIAHistory new.
    history
        api: api;
        user: 'Use ApiToolClassInfo to read the class comment of ApiToolClassInfo. What is the kilroy sentence? Answer with only that sentence.';
        getResponse.

    answer := history response.

    answer ifNil: [
        self error: 'No response from LLM' ].

    (answer asLowercase includesSubstring: 'kilroy left here')
        ifFalse: [
            self error: 'Expected sentence not found: ', answer ].

    (answer asLowercase includesSubstring: 'kilroy was here')
        ifTrue: [
            self error: 'Incorrect sentence found: ', answer ]
]

{ #category : 'tests' }
AIAFullLLMTesterLiveTest >> testKilroy [

AIAFullLLMTester
    runTests: #(testClassInfo:model:)
    on: AIAFullLLMTesterLiveTest
    providersAndModels: {
        { MistralApi. #('codestral-latest') } }
]
