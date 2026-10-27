Class {
	#name : 'AIAFullLLMTesterLiveTest',
	#superclass : 'TestCase',
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'testing' }
AIAFullLLMTesterLiveTest class >> testClassInfo: aProvider model: aModel [
    "Verify that the LLM invokes getClassInfo and correctly retrieves
    the kilroy sentence from the Pharo class comment."

    | api history answer toolCalled |

    api := aProvider new.
    api
        model: aModel;
        toolsEnabled: true;
        responseWaitingInSecs: 60.

    history := AIAHistory new.
    history
        api: api;
        user: 'Use the Pharo class-information tool to retrieve the current class comment of ApiToolClassInfo. Extract the exact sentence containing the word "kilroy". Do not answer from memory.';
        getResponse.

    toolCalled := history messages anySatisfy: [ :message |
        message key = 'assistant'
            and: [
                (message value beginsWith: '[tool_call]')
                    and: [
                        message value includesSubstring: 'name: getClassInfo' ] ] ].

    toolCalled ifFalse: [
        self error: 'LLM did not call getClassInfo' ].

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
