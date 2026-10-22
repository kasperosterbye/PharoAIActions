Class {
	#name : 'AIAFullLLMTesterTest',
	#superclass : 'TestCase',
	#instVars : [
		'savedResults'
	],
	#category : 'AIActions-Tests-AIActions-LiveTests',
	#package : 'AIActions-Tests',
	#tag : 'AIActions-LiveTests'
}

{ #category : 'adding' }
AIAFullLLMTesterTest class >> simulateFailure [
	"Simulate a test that raises an error."

	| newInstance |
	newInstance := self new.

	100 milliSeconds wait.
	newInstance error: 'Simulated test failure'
]

{ #category : 'adding' }
AIAFullLLMTesterTest class >> simulateSlow [
    "Simulate a long-running test that can be interrupted."

    5 seconds wait
]

{ #category : 'adding' }
AIAFullLLMTesterTest class >> simulateSuccess [
    "Simulate a successful test."

    100 milliSeconds wait
]

{ #category : 'running' }
AIAFullLLMTesterTest >> setUp [
    "Preserve existing experiment results before testing."

    super setUp.
    savedResults := AIAFullLLMTester testResults.
    AIAFullLLMTester initialize
]

{ #category : 'running' }
AIAFullLLMTesterTest >> tearDown [
    "Restore experiment results after testing."

    AIAFullLLMTester testResults: savedResults.
    super tearDown
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testCancellation [
    "Verify that cancellation stops the current workload and preserves completed results."

    | process results |

    process := AIAFullLLMTester
        runTests: #(simulateSuccess simulateSlow simulateSuccess)
        on: self class.

    500 milliSeconds wait.

    AIAFullLLMTester stop.
    self waitFor: process.

    results := AIAFullLLMTester testResults last.

    self assert: results size equals: 1.
    self assert: (results first at: #test) equals: #simulateSuccess.
    self assert: (results first at: #status) equals: #passed
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testFailedExecution [
    "Verify that failures are recorded and subsequent tests continue."

    | process results |

    process := AIAFullLLMTester
        runTests: #(simulateFailure simulateSuccess)
        on: self class.

    self waitFor: process.

    results := AIAFullLLMTester testResults last.

    self assert: results size equals: 2.

    self assert: (results first at: #test) equals: #simulateFailure.
    self assert: (results first at: #status) equals: #failed.
    self assert: ((results first at: #details)
        includesSubstring: 'Simulated test failure').

    self assert: (results second at: #test) equals: #simulateSuccess.
    self assert: (results second at: #status) equals: #passed
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testMultipleRuns [
    "Verify that successive experiments preserve separate result collections."

    | firstProcess secondProcess runs |

    firstProcess := AIAFullLLMTester
        runTests: #(simulateSuccess)
        on: self class.

    self waitFor: firstProcess.

    secondProcess := AIAFullLLMTester
        runTests: #(simulateFailure)
        on: self class.

    self waitFor: secondProcess.

    runs := AIAFullLLMTester testResults.

    self assert: runs size equals: 2.
    self assert: (runs first first at: #status) equals: #passed.
    self assert: (runs second first at: #status) equals: #failed
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testResultsAreGroupedByRun [
    "Verify that separate runs retain their own results."

    AIAFullLLMTester startNewRun.
    AIAFullLLMTester addTestResult: 'Foo completed'.

    AIAFullLLMTester startNewRun.
    AIAFullLLMTester addTestResult: 'Bar completed'.

    self assert: AIAFullLLMTester testResults size equals: 2.
    self
        assert: AIAFullLLMTester testResults first asArray
        equals: #('Foo completed').
    self
        assert: AIAFullLLMTester testResults second asArray
        equals: #('Bar completed')
]

{ #category : 'tests' }
AIAFullLLMTesterTest >> testSuccessfulExecution [
    "Verify that a successful workload produces a structured result."

    | process result |

    process := AIAFullLLMTester
        runTests: #(simulateSuccess)
        on: self class.

    self waitFor: process.

    self assert: AIAFullLLMTester testResults size equals: 1.

    result := AIAFullLLMTester testResults last first.

    self assert: (result at: #test) equals: #simulateSuccess.
    self assert: (result at: #status) equals: #passed.
    self assert: (result at: #duration) >= 0.
    self assert: (result at: #details) equals: ''
]

{ #category : 'helpers' }
AIAFullLLMTesterTest >> waitFor: aProcess [
    "Wait for a background process to terminate, with a safety timeout."

    | deadline |

    deadline := DateAndTime now + 10 seconds.

    [ aProcess isTerminated or: [
        DateAndTime now >= deadline ] ] whileFalse: [
            10 milliSeconds wait ].

    self assert: aProcess isTerminated
        description: 'Experiment did not finish within ten seconds'
]
