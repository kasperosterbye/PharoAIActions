Class {
	#name : 'AIAFullLLMTester',
	#superclass : 'Object',
	#classVars : [
		'CurrentJob',
		'TestResults'
	],
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'adding' }
AIAFullLLMTester class >> addTestResult: aResult [
    "Record a result in the current run and report it."

    self testResults isEmpty ifTrue: [
        self error: 'No test run has been started' ].

    self testResults last add: aResult.
    Transcript
        show: aResult printString;
        cr
]

{ #category : 'adding' }
AIAFullLLMTester class >> initialize [
    "Clear all recorded test runs."

    TestResults := OrderedCollection new
]

{ #category : 'adding' }
AIAFullLLMTester class >> resetTestResults [
    "Clear all recorded test runs."

    TestResults := OrderedCollection new
]

{ #category : 'tests' }
AIAFullLLMTester class >> run [
    <example>
    "Execute the configured LLM experiments."

    ^ self
        runTests: self testSelectors
        on: self
]

{ #category : 'tests' }
AIAFullLLMTester class >> runTests: selectors on: aTestClass [
    "Execute workloads in a background Job, recording results and supporting cancellation."

    | job |

    self startNewRun.

    job := [ :j |
        j interruptBlock: [
            Transcript show: 'Experiment stopped'; cr.
            j terminate ].

        [
            selectors withIndexDo: [ :selector :index |
                | started status details duration |

                j
                    progress: index / selectors size
                    title: 'Running ', selector asString.

                started := DateAndTime now.
                status := #passed.
                details := ''.

                [ aTestClass perform: selector ]
                    on: Error
                    do: [ :error |
                        status := #failed.
                        details := error printString ].

                duration := (DateAndTime now - started)
                    asMilliSeconds / 1000.0.

                self addTestResult: (Dictionary new
                    at: #test put: selector;
                    at: #provider put: nil;
                    at: #model put: nil;
                    at: #status put: status;
                    at: #duration put: duration;
                    at: #timestamp put: DateAndTime now;
                    at: #details put: details;
                    yourself)
            ]
        ] ensure: [
            CurrentJob == j ifTrue: [
                CurrentJob := nil ] ]
    ] asJob.

    CurrentJob := job.

    ^ [ job run ] forkAt: Processor userBackgroundPriority
]

{ #category : 'adding' }
AIAFullLLMTester class >> startNewRun [
    "Create a new collection for the results of this run."

    self testResults add: OrderedCollection new
]

{ #category : 'accessing' }
AIAFullLLMTester class >> stop [
    "Interrupt the currently running experiment."

    CurrentJob ifNotNil: [ :job |
        job interrupt ]
]

{ #category : 'adding' }
AIAFullLLMTester class >> testResults [
    "Answer the results of all test runs."

    ^ TestResults ifNil: [
        TestResults := OrderedCollection new ]
]

{ #category : 'tests' }
AIAFullLLMTester class >> testResults: aCollection [
    "Replace the current experiment results collection."

    TestResults := aCollection
]

{ #category : 'tests' }
AIAFullLLMTester class >> testSelectors [
    "Answer the tests to execute, in execution order."
    ^ #()
]
