Class {
	#name : 'AIAHistorySlowTestApi',
	#superclass : 'AilienApi',
	#instVars : [
		'started',
		'workerProcess'
	],
	#category : 'AIActions-Tests-AIApi-Tests',
	#package : 'AIActions-Tests',
	#tag : 'AIApi-Tests'
}

{ #category : 'initialization' }
AIAHistorySlowTestApi >> initialize [
    "Initialize a simulated API with a model name for progress reporting."

    model := 'slow-test-model'.
    started := Semaphore new.
    self responseWaitingInSecs: 1
]

{ #category : 'responses' }
AIAHistorySlowTestApi >> loadResponse: aHistory [
    "Simulate an API request that never completes normally."
    workerProcess := Processor activeProcess.
    started signal.
    Semaphore new wait
]

{ #category : 'as yet unclassified' }
AIAHistorySlowTestApi >> respondImmediately [
    "Simulate a successful API response without contacting an LLM."
    self responseWaitingInSecs: 2
]

{ #category : 'as yet unclassified' }
AIAHistorySlowTestApi >> waitUntilStarted [
    "Wait until the simulated API request has started."
    started wait
]

{ #category : 'accessing' }
AIAHistorySlowTestApi >> workerProcess [
    "Answer the process executing the simulated API request."
    ^ workerProcess
]
